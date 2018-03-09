//
//  ImageRequestBuilder.swift
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// ImageRequestBuilder provides a common interface for creating an ImageRequest.
///
/// The Swift DSL classes wrap this builder to provide its interface to API clients.
/// This class encapsulates common logic, such as protecting against modifications
/// after the request was built.
///
public class ImageRequestBuilder {

    private let context: MatisseContext
    private let url: URL
    private var transformations: [ImageTransformation] = []
    private var builtRequest: ImageRequest?


    // MARK: - Initialization

    /// Create a new image request builder.
    ///
    /// - Parameters:
    ///   - context: The Matisse instance to execute the built request in.
    ///   - url:     The source URL of the image to fetch.
    ///
    internal init(context: MatisseContext, url: URL) {
        self.context = context
        self.url = url
    }


    // MARK: - Configuring and Building the Request

    /// Add a new image transformation to the request.
    ///
    /// Transformations will be applied in the order they are added to the request.
    ///
    /// - Note:
    ///   You cannot modify the request after it was fetched.
    ///
    /// - Parameters:
    ///   - transformation: The transformation to apply to the downloaded image.
    ///
    /// - Returns:
    ///   The receiver.
    ///
    public func transform(_ transformation: ImageTransformation) -> Self {
        self.checkNotYetBuilt()

        self.transformations.append(transformation)
        return self
    }

    /// The image request created by this builder.
    ///
    /// If accessed for the first time it creates the image request using the current
    /// configuration options. After calling this method it's not possible to modify
    /// the request further.
    ///
    public var imageRequest: ImageRequest {
        if let request = self.builtRequest {
            return request
        }

        let request = ImageRequest(url: self.url, transformations: self.transformations)
        self.builtRequest = request
        return request
    }


    // MARK: - Executing the Request

    /// Creates the image request and fetches it using the configured Matisse context.
    ///
    /// Downloading and preparing the image are performed in the background. After it
    /// completes, the completion handler is called.
    ///
    /// After calling this method it's not possible to modify the request further.
    ///
    /// - Parameters:
    ///   - completion: The block to call when the image is either downloaded or
    ///                 if an error happens.
    ///
    /// - Returns:
    ///   The cached image if the request was fulfilled from the fast cache, otherwise `nil`.
    ///
    @discardableResult public func fetch(_ completion: @escaping (ImageRequest, UIImage?, NSError?) -> Void) -> UIImage? {
        let request = self.imageRequest

        return self.context.execute(request: request) { image, error in
            completion(request, image, error)
        }
    }

    /// Fetches the image and passes it to the given `ImageRequestTarget`.
    ///
    /// This method checks wether the target is still valid after the request resolves,
    /// and discards updates if the target was associated with another request in the mean
    /// time.
    ///
    /// If the image can be retrieved from the fast cache, the target is updated immediately.
    /// Otherwise it's updated asynchronously on the main thread.
    ///
    /// - Parameters:
    ///   - target: The `ImageRequestTarget` to show the image in.
    ///
    public func showIn(_ target: ImageRequestTarget) {
        target.matisseRequestIdentifier = self.imageRequest.identifier

        var alreadySet = false

        // fetch the image then show it in the target
        let fetchedImage = self.fetch { request, image, error in
            if !alreadySet && target.matisseRequestIdentifier == request.identifier {
                target.update(forImageRequest: request, image: image, error: error)
                target.matisseRequestIdentifier = nil
            }
        }

        // show the image in the target directly, if it was retrieved from the fast cache
        // note: this will be executed before the completion block above
        if let image = fetchedImage {
            target.update(forImageRequest: self.imageRequest, image: image, error: nil)
            alreadySet = true
        }
    }


    // MARK: - Helper

    /// Makes sure the request was not built before. Should be checked when trying to modify the request.
    private func checkNotYetBuilt() {
        assert(self.builtRequest == nil, "Cannot modify the request because it was already built")
    }
}
