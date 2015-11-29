//
//  MatisseContext.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/**
 * The context object which schedules and executes image loading requests.
 *
 * This is the main object you interact with to fetch images. Usually
 * this is done via the class method itself. A simple example would be
 *
 *     Matisse.load(imageURL).into(myImageView)
 *
 * The Matisse class itself actually only provides the means to execute an
 * ImageRequest. DSL related methods can be found on `ImageRequestBuilder`.
 
 */
@objc(MTSMatisse)
public class Matisse : NSObject {
    
    // MARK: - Initialization
    
    private let fastCache: ImageCache?
    private let slowCache: ImageCache?
    private let requestHandler: ImageRequestHandler
    private let syncQueue: DispatchQueue
    
    /**
     * Create a custom instance of Matisse.
     *
     * If for some reason you need a second Matisse instance you can create
     * one yourself. You need to specify the fast cache, the slow cache and
     * the image request handler. Optionally you can also pass a queue to be
     * used as the synchronization queue, though this is mostly intended for
     * testing purposes.
     * 
     * If you pass `nil` for either of the caches, caching at that level is
     * disabled.
     *
     * You should not have to use this very often, instead you would configure
     * the shared Matisse instance using e.g. `Matisse.useFastCache(myCache)`
     * at the beginning of your program.
     *
     * - Parameters:
     *   - fastCache:      The cache to use on the main thread. Pass `nil` to disable.
     *   - slowCache:      The cache that is used from the background. Pass `nil` to disable.
     *   - requestHandler: The ImageRequestHandler that is used to resolve
     *                     requests that were not cached.
     *
     * - Returns:
     *   A custom Matisse instance.
     */
    public init(fastCache: ImageCache?, slowCache: ImageCache?, requestHandler: ImageRequestHandler, syncQueue: dispatch_queue_t = dispatch_queue_create("ch.konoma.matisse.syncQueue", DISPATCH_QUEUE_SERIAL)) {
        self.fastCache = fastCache
        self.slowCache = slowCache
        self.requestHandler = requestHandler
        self.syncQueue = DispatchQueue(dispatchQueue: syncQueue)
    }
    
    
    // MARK: - Loading Images
    
    /**
     * Executes the given image request and returns the result asynchronously.
     *
     * This method first tries to fetch the image from the `fastCache`,
     * directly on the main thread. If this fails, the `slowCache` is tried on
     * the background in turn. If this cache too has no image, then the
     * `requestHandler` is called to fetch and prepare the request. The result
     * is stored in the caches if successful and delivered via the passed
     * completion block.
     *
     * The completion block is always called asynchronous on the main thread.
     * If the request can be resolved via the fast cache, then the image is
     * also returned from the method, allowing you to act on it without delay.
     *
     * - Note:
     *   This method must be called from the main thread.
     *
     * - Parameters:
     *   - request:    The image request to resolve.
     *   - completion: The completion handler that will be called with the result
     *
     * - Returns:
     *   If the request could be resolved using the fast cache, this returns the
     *   resolved image. Otherwise `nil` is returned.
     */
    public func executeRequest(request: ImageRequest, completion: (UIImage?, NSError?) -> Void) -> UIImage? {
        assert(NSThread.isMainThread(), "You must call this method on the main thread")

        // first try to get an image from the fastCache, without going to a background queue
        if let image = fastCache?.retrieveImageForRequest(request) {
            DispatchQueue.main.async { completion(image, nil) }
            return image
        }
        
        // if we can't get an image out of the fast cache, go to background
        syncQueue.async {
            
            // secondly try to get an image from the slow cache
            if let image = self.slowCache?.retrieveImageForRequest(request) {
                DispatchQueue.main.async {
                    completion(image, nil)
                }
                return
            }
            
            // if we can't get a cached image, try to retrieve it from the handler and cache it in turn
            self.requestHandler.retrieveImageForRequest(request) { image, error in
                if let image = image {
                    self.cacheImage(image, forRequest: request)
                }
                
                DispatchQueue.main.async {
                    completion(image, error)
                }
            }
        }
        
        // return nil for all requests resolved in background
        return nil
    }
    
    private func cacheImage(image: UIImage, forRequest request: ImageRequest) {
        let cost = 0 // to be calculated, e.g. using the time it took to create the image
        
        // cache the result in the slow cache on the background sync queue
        self.syncQueue.async {
            self.slowCache?.storeImage(image, forRequest: request, withCost: cost)
        }
        
        // cache the result in the fast cache on the main queue
        DispatchQueue.main.async {
            self.fastCache?.storeImage(image, forRequest: request, withCost: cost)
        }
    }
}


// MARK: - Shared Matisse Instance

public extension Matisse {
    
    // MARK: - Shared Context
    
    private static var _sharedContext: Matisse?
    private static var _fastCache: ImageCache? = MemoryImageCache()
    private static var _slowCache: ImageCache? = MemoryImageCache()
    private static var _requestHandler: ImageRequestHandler = DefaultImageRequestHandler(imageLoader: DefaultImageLoader())
    
    public class func sharedContext() -> Matisse {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: Matisse? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = Matisse(fastCache: _fastCache, slowCache: _slowCache, requestHandler: _requestHandler)
        }
        
        return Static.instance!
    }
}
