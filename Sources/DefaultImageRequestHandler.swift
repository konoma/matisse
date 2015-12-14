//
//  DefaultImageRequestHandler.swift
//  Matisse
//
//  Created by Markus Gasser on 28.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// The request handler that is used by the shared `Matisse`/`MTSMatisse` instance if not specified differently.
///
@objc(MTSDefaultImageRequestHandler)
public class DefaultImageRequestHandler: NSObject, ImageRequestHandler {

    private let imageLoader: ImageLoader
    private let imageCreator: DefaultImageCreator
    private let workerQueue: DispatchQueue

    public convenience init(imageLoader: ImageLoader) {
        self.init(
            imageLoader: imageLoader,
            imageCreator: DefaultImageCreator()
        )
    }

    public convenience init(imageLoader: ImageLoader, imageCreator: DefaultImageCreator) {
        self.init(
            imageLoader: imageLoader,
            imageCreator: imageCreator,
            workerQueue: dispatch_queue_create("ch.konoma.matisse/creatorQueue", DISPATCH_QUEUE_CONCURRENT)
        )
    }

    internal init(imageLoader: ImageLoader, imageCreator: DefaultImageCreator, workerQueue: dispatch_queue_t) {
        self.imageLoader = imageLoader
        self.imageCreator = imageCreator
        self.workerQueue = DispatchQueue(dispatchQueue: workerQueue)
    }

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
