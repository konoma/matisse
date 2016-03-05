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
    private let url: NSURL
    private var transformations: [ImageTransformation] = []
    private var builtRequest: ImageRequest?


    // MARK: - Initialization

    /// Create a new image request builder.
    ///
    /// - Parameters:
    ///   - context: The Matisse instance to execute the built request in.
    ///   - url:     The source URL of the image to fetch.
    ///
    internal init(context: MatisseContext, url: NSURL) {
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
    public func transform(transformation: ImageTransformation) -> Self {
        checkNotYetBuilt()

        transformations.append(transformation)
        return self
    }

    /// The image request created by this builder.
    ///
    /// If accessed for the first time it creates the image request using the current
    /// configuration options. After calling this method it's not possible to modify
    /// the request further.
    ///
    public var imageRequest: ImageRequest {
        if let request = builtRequest {
            return request
        }

        let request = ImageRequest(url: url, transformations: transformations)
        builtRequest = request
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
    public func fetch(completion: (ImageRequest, UIImage?, NSError?) -> Void) -> UIImage? {
        let request = imageRequest

        return context.executeRequest(request) { image, error in
            completion(request, image, error)
        }
    }

    /// Fetches the image and passes it to the given `ImageRequestTarget`.
    ///
    /// This method checks wether the target is still valid after the request resolves,
    /// and discards updates if the target was associated with another request in the mean
    /// time.
    ///
    /// - Parameters:
    ///   - target: The `ImageRequestTarget` to show the image in.
    ///
    public func showIn(target: ImageRequestTarget) {
        target.matisseRequestIdentifier = imageRequest.identifier

        fetch { request, image, error in
            if target.matisseRequestIdentifier == request.identifier {
                target.updateForImageRequest(request, image: image, error: error)
                target.matisseRequestIdentifier = nil
            }
        }
    }

    /// Same as `showInTarget(_: ImageRequestTarget)` but repeated here because of swift limitations.
    ///
    /// - Parameters:
    ///   - imageView: The target image view to show the fetched image in.
    ///
    public func showIn(imageView: UIImageView) {
        showIn(imageView as ImageRequestTarget)
    }


    // MARK: - Helper

    /// Makes sure the request was not built before. Should be checked when trying to modify the request.
    private func checkNotYetBuilt() {
        assert(builtRequest == nil, "Cannot modify the request because it was already built")
    }
}
