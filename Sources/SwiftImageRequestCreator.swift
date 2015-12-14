//
//  SwiftImageRequestCreator.swift
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// This class provides a fluid interface to configure an image request.
///
/// You cannot create instances of this class yourself. Instead use the `Matisse.load(_:)`
/// method on to retrieve a `SwiftImageRequestCreator`.
///
/// Then configure the request using the methods on the creator.
///
///     Matisse.load(exampleURL).resizeTo(width: 100.0, height: 100.0)
///
/// Finally execute the request with `fetch(_:)` or another execution method.
///
///     Matisse.load(exampleURL).resizeTo(width: 100.0, height: 100.0).showIn(imageView)
///
/// If you create custom image transformations, you should add an extension to this
/// creator. Make sure you return the creator instance so that a fluid call chain can
/// be maintained.
///
///     extension SwiftImageRequestCreator {
///
///         func circleCrop() -> Self {
///             return transform(CircleCropTransformation())
///         }
///     }
///
public class SwiftImageRequestCreator {

    private let requestBuilder: ImageRequestBuilder

    /// Create a new request creator with the given builder.
    ///
    /// - Parameters:
    ///   - requestBuilder: The `ImageRequestBuilder` to create the image request.
    ///
    internal init(requestBuilder: ImageRequestBuilder) {
        self.requestBuilder = requestBuilder
    }

    /// Append a transformation to this image request.
    ///
    /// This will apply the passed transformation to the image when the requested
    /// image was loaded.
    ///
    /// This method returns the receiver so you can chain calls.
    ///
    /// - Parameters - transformation: The `ImageTransformation` to apply to the loaded image.
    ///
    /// - Returns:
    ///   The receiver
    ///
    public func transform(transformation: ImageTransformation) -> Self {
        requestBuilder.addTransformation(transformation)
        return self
    }

    /// Creates the image request and fetches it using the configured Matisse context.
    ///
    /// Downloading and preparing the image are performed in the background. After it
    /// completes, the completion handler is called.
    ///
    /// After calling this method it's not possible to modify the request further.
    ///
    /// - Parameter completion: The block to call when the image is either downloaded or
    ///                         if an error happened.
    ///
    public func fetch(completion: (ImageRequest, UIImage?, NSError?) -> Void) -> UIImage? {
        return requestBuilder.fetch(completion)
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
        requestBuilder.showInTarget(target)
    }

    /// Same as `showInTarget(_: ImageRequestTarget)` but repeated here because of swift limitations.
    ///
    public func showIn(imageView: UIImageView) {
        requestBuilder.showInTarget(imageView)
    }
}
