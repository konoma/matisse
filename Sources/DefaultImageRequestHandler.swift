//
//  DefaultImageRequestHandler.swift
//  Matisse
//
//  Created by Markus Gasser on 28.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// The request handler that is used by the shared `Matisse`/`MTSMatisse` DSL instance if not specified differently.
///
/// To use a `DefaultImageRequestHandler` with a different `ImageLoader` on the shared DSL instance you
/// don't need to create a new object yourself. Instead you can use `useImageLoader(_:)` on the shared
/// DSL class to set the `ImageLoader` directly.
///
@objc(MTSDefaultImageRequestHandler)
public class DefaultImageRequestHandler: NSObject, ImageRequestHandler {

    private let imageLoader: ImageLoader
    private let imageCreator: DefaultImageCreator
    private let workerQueue: DispatchQueue


    // MARK: - Initialization

    /// Create a new `DefaultImageRequestHandler` with a default image loader and creator.
    ///
    public override convenience init() {
        self.init(imageLoader: DefaultImageLoader())
    }

    /// Create a new `DefaultImageRequestHandler` with a specified image loader.
    ///
    /// - Parameters:
    ///   - imageLoader: The `ImageLoader` to use for this request handler.
    ///
    public convenience init(imageLoader: ImageLoader) {
        self.init(
            imageLoader: imageLoader,
            imageCreator: DefaultImageCreator(),
            workerQueue: dispatch_queue_create("ch.konoma.matisse/creatorQueue", DISPATCH_QUEUE_CONCURRENT)
        )
    }

    /// Testing initializer.
    ///
    /// - Parameters:
    ///   - imageLoader:  The `ImageLoader` to use for this request handler.
    ///   - imageCreator: The image creator to use for this request handler.
    ///   - workerQueue:  The dispatch queue to execute requests on.
    ///
    internal init(imageLoader: ImageLoader, imageCreator: DefaultImageCreator, workerQueue: dispatch_queue_t) {
        self.imageLoader = imageLoader
        self.imageCreator = imageCreator
        self.workerQueue = DispatchQueue(dispatchQueue: workerQueue)
    }


    // MARK: - Retrieving Images

    /// Retrieve and prepare the image for the given `ImageRequest`
    ///
    /// Uses the `ImageLoader` passed to this request handler to download images.
    /// Then applies the transformations from the request to the downloaded image.
    ///
    /// - Parameters:
    ///   - request:    The `ImageRequest` to resolve.
    ///   - completion: The completion block that is called when the request finished.
    ///
    public func retrieveImageForRequest(request: ImageRequest, completion: (UIImage?, NSError?) -> Void) {
        imageLoader.loadImageForRequest(request) { url, error in
            guard let url = url else {
                completion(nil, error)
                return
            }

            self.createImageFromURL(url, request: request, completion: completion)
        }
    }

    private func createImageFromURL(url: NSURL, request: ImageRequest, completion: (UIImage?, NSError?) -> Void) {
        workerQueue.async {
            do {
                let image = try self.imageCreator.createImageFromURL(url, request: request)
                completion(image, nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }
}
