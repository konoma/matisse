//
//  MatisseContext.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// The context object that schedules and executes image loading requests.
///
/// This is the central class coordinating image loading, creating and caching.
/// It also takes care of request coalescing, so that multiple requests for the same
/// image only need to do the download and creation once.
///
///
/// ## Caching
///
/// Caching in Matisse is done on two levels: fast and slow.
///
/// The fast cache is read/written directly on the main thread and therefore
/// must retrieve and store images fast (as the name indicates). This is
/// usually implemented using some kind of in-memory cache (like `NSCache`).
/// The default Matisse instance uses the `MemoryImageCache` for this if not
/// explicitely configured.
///
/// The second level is the slow cache. This cache will only be accessed from the sync
/// queue which is in the background. The slow cache may take more time to retrieve
/// cache images, and will often involve file IO. The default Matisse instance uses the
/// `DiskImageCache` for this if not explicitely configured.
///
/// You provide the fast and slow cache in the initializer as classes implementing
/// `ImageCache`. You may disable one or both chaches by passing `nil` instead of
/// a cache object.
///
///
/// ## Request Handling
///
/// When an image request is submitted, the context first tries to find a matching
/// image in the slow cache, and if this fails the fast cache. If that fails, it
/// tries to find a currently executed request that is equivalent to the submitted
/// request. If such a request is found then the result of the running request will
/// be used for this request too. In case no such request can be found then the
/// contexts `ImageRequestHandler` is asked to fullfill the image request. The result
/// is then cached if possible and returned for all equivalent requests.
///
/// If you want to customize downloading or image creation behavior, pass a custom
/// `ImageRequestHandler` instance when creating the context.
///
public class MatisseContext {

    private let fastCache: ImageCache?
    private let slowCache: ImageCache?
    private let requestQueue: CoalescingTaskQueue<RequestWorker>
    private let syncQueue: DispatchQueue


    // MARK: - Initialization

    /// Create a custom matisse context with the given caches and request handler.
    ///
    /// You only need to create a custom `MatisseContext` if you want to create your own DSL object.
    /// If you want to configure the main DSL object you can do so directly using class methods on
    /// the DSL class (see the respective class documentation for Swift/Objective-C).
    ///
    /// - Parameters:
    ///   - fastCache:      The cache to use as fast cache (on the main thread). Pass `nil` to disable the fast cache.
    ///   - slowCache:      The cache to use as slow cache (in the background). Pass `nil` to disable the slow cache.
    ///   - requestHandler: The `ImageRequestHandler` that is used to resolve `ImageRequest`s
    ///
    public convenience init(fastCache: ImageCache?, slowCache: ImageCache?, requestHandler: ImageRequestHandler) {
        self.init(
            fastCache: fastCache,
            slowCache: slowCache,
            requestHandler: requestHandler,
            syncQueue: DispatchQueue(label: "ch.konoma.matisse/syncQueue", attributes: [])
        )
    }

    /// The internal constructor that also allows to pass the dispatch queue to act as sync queue. Used for testing.
    ///
    /// - Parameters:
    ///   - fastCache:      The cache to use as fast cache (on the main thread). Pass `nil` to disable the fast cache.
    ///   - slowCache:      The cache to use as slow cache (in the background). Pass `nil` to disable the slow cache.
    ///   - requestHandler: The `ImageRequestHandler` that is used to resolve `ImageRequest`s
    ///
    internal init(fastCache: ImageCache?, slowCache: ImageCache?, requestHandler: ImageRequestHandler, syncQueue: DispatchQueue) {
        self.fastCache = fastCache
        self.slowCache = slowCache
        self.syncQueue = syncQueue
        self.requestQueue = CoalescingTaskQueue(worker: RequestWorker(requestHandler: requestHandler), syncQueue: self.syncQueue)
    }


    // MARK: - Handling Image Requests

    /// Executes the given `ImageRequest` and returns the result asynchronously.
    ///
    /// First the request is attempted to resolve using the fast cache on the main
    /// thread. If an image is found, it's returned from this method and the completion
    /// Block is called asynchronously. If this cache misses or no fast cache is set,
    /// `nil` is returned and the request will be tried to resolve in the background.
    ///
    /// First in the background, the slow cache is checked for a match. If successful,
    /// the completion block is called with the result. If that fails too, the request
    /// is passed to a queue that manages equivalent requests such that the work of
    /// downloading and creating the image only needs to be done once. If no equivalent
    /// request is already being resolved, then this request is resovled using the
    /// `ImageRequestHandler`. The result of this operation is reported using the
    /// completion block.
    ///
    /// - Note:
    ///   This method must be called from the main thread
    ///
    /// - Parameters:
    ///   - request:    The image request to resolve.
    ///   - completion: The completion handler that will be called with the result. This
    ///                 block is always called asynchronously, even if the request was
    ///                 resolved using the fast cache.
    ///
    /// - Returns:
    ///   If the request could be resolved using the fast cache, this returns the resolved
    ///   image. Otherwise `nil` is returned.
    ///
    @discardableResult public func execute(request: ImageRequest, completion: @escaping (UIImage?, NSError?) -> Void) -> UIImage? {
        assert(Thread.isMainThread, "You must call this method on the main thread")

        // first try to get an image from the fastCache, without going to a background queue
        if let image = self.fastCache?.retrieveImage(forRequest: request) {
            DispatchQueue.main.async { completion(image, nil) }
            return image
        }

        // if we can't get an image out of the fast cache, go to background
        self.syncQueue.async {

            // secondly try to get an image from the slow cache
            if let image = self.slowCache?.retrieveImage(forRequest: request) {
                DispatchQueue.main.async {
                    // store it also in the fast cache
                    self.fastCache?.store(image: image, forRequest: request, withCost: 0)
                    completion(image, nil)
                }
                return
            }

            // if we can't get a cached image, try to retrieve it from the handler and cache it in turn
            self.requestQueue.submit(task: request,

                requestCompletion: { image, error in
                    if let image = image {
                        self.cache(image: image, forRequest: request)
                    }
                },

                taskCompletion: { image, error in
                    DispatchQueue.main.async {
                        completion(image, error)
                    }
                }
            )
        }

        // return nil for all requests resolved in background
        return nil
    }


    // MARK: - Helper

    // Cache an image both in the fast and the slow cache
    private func cache(image: UIImage, forRequest request: ImageRequest) {
        let cost = 0 // to be calculated, e.g. using the time it took to create the image

        // cache the result in the slow cache on the background sync queue
        self.syncQueue.async {
            self.slowCache?.store(image: image, forRequest: request, withCost: cost)
        }

        // cache the result in the fast cache on the main queue
        DispatchQueue.main.async {
            self.fastCache?.store(image: image, forRequest: request, withCost: cost)
        }
    }


    // Worker implementation for the image request handler to support task coalescing.
    private class RequestWorker: CoalescingTaskQueueWorker {

        let requestHandler: ImageRequestHandler

        init(requestHandler: ImageRequestHandler) {
            self.requestHandler = requestHandler
        }

        func handle(task: ImageRequest, completion: @escaping (UIImage?, NSError?) -> Void) {
            self.requestHandler.retrieveImage(forRequest: task, completion: completion)
        }

        func canCoalesce(task newTask: ImageRequest, withTask currentTask: ImageRequest) -> Bool {
            return newTask.descriptor == currentTask.descriptor
        }
    }
}
