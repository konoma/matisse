//
//  DefaultImageRequestHandler.swift
//  Matisse
//
//  Created by Markus Gasser on 28.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// The request handler that is used by the shared `Matisse` DSL instance if not specified differently.
///
/// To use a `DefaultImageRequestHandler` with a different `ImageLoader` on the shared DSL instance you
/// don't need to create a new object yourself. Instead you can use `useImageLoader(_:)` on the shared
/// DSL class to set the `ImageLoader` directly.
///
public class DefaultImageRequestHandler: ImageRequestHandler {

    private let imageLoader: ImageLoader
    private let imageCreator: DefaultImageCreator
    private let workerQueue: DispatchQueue


    // MARK: - Initialization

    /// Create a new `DefaultImageRequestHandler` with a default image loader and creator.
    ///
    public convenience init() {
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
            workerQueue: DispatchQueue(label: "ch.konoma.matisse/creatorQueue", attributes: .concurrent)
        )
    }

    /// Testing initializer.
    ///
    /// - Parameters:
    ///   - imageLoader:  The `ImageLoader` to use for this request handler.
    ///   - imageCreator: The image creator to use for this request handler.
    ///   - workerQueue:  The dispatch queue to execute requests on.
    ///
    internal init(imageLoader: ImageLoader, imageCreator: DefaultImageCreator, workerQueue: DispatchQueue) {
        self.imageLoader = imageLoader
        self.imageCreator = imageCreator
        self.workerQueue = workerQueue
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
    public func retrieveImage(forRequest request: ImageRequest, completion: @escaping (UIImage?, NSError?) -> Void) {
        self.imageLoader.loadImage(forRequest: request) { url, error in
            guard let url = url else {
                completion(nil, error)
                return
            }

            self.createImage(fromUrl: url, request: request, completion: completion)
        }
    }

    private func createImage(fromUrl url: URL, request: ImageRequest, completion: @escaping (UIImage?, NSError?) -> Void) {
        self.workerQueue.async {
            do {
                let image = try self.imageCreator.createImage(fromUrl: url, request: request)
                completion(image, nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }
}
