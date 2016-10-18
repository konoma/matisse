//
//  ImageRequestHandler.swift
//  Matisse
//
//  Created by Markus Gasser on 28.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// An `ImageRequestHandler` is responsible for resolving an `ImageRequest`.
///
/// The request handler is called by the `MatisseContext` if a request cannot
/// be fulfilled from the caches. The handler is likely to be called from a
/// background thread, but is never called concurrently on multiple threads.
///
/// Resolving the request includes downloading the image, creating the image
/// and applying any transformations on it, if specified by the request.
///
public protocol ImageRequestHandler: class {

    /// Retrieve and prepare the image for the given `ImageRequest`
    ///
    /// This includes downloading the image, creating it and applying any
    /// transformations specified in the passed image request.
    ///
    /// - Note:
    ///   This method will be called from a background thread, but not concurrently.
    ///   The completion handler may be executed on any thread.
    ///
    /// - Parameters:
    ///   - request:    The `ImageRequest` to resolve.
    ///   - completion: The completion block that must be called when the request
    ///                 succeeded or failed. Pass `nil` for the image to mark the
    ///                 request as failed.
    ///
    func retrieveImage(forRequest request: ImageRequest, completion: @escaping (UIImage?, NSError?) -> Void)
}
