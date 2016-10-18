//
//  ImageRequest.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// Encapsulates information about an image request.
///
/// Image requests are uniquely identifiable by their identifier. If necessary
/// they can be checked for content equality by comparing their descriptor. This
/// is a string created by combining the URL of the request with any transformations
/// applied to the image. The descriptor is used for example to implement request
/// coalescing.
///
public class ImageRequest {

    // MARK: - Initialization

    /// Create a new image request for the given URL and transformations.
    ///
    /// - Parameters:
    ///   - url:             The URL where to retrieve the image from.
    ///   - transformations: The `ImageTransformation`s to apply to the downloaded image.
    ///
    public init(url: URL, transformations: [ImageTransformation]) {
        self.identifier = UUID()
        self.url = url
        self.transformations = transformations
    }


    // MARK: - Properties

    /// The unique identifier for this request
    public let identifier: UUID

    /// The source URL for this image
    public let url: URL

    /// Any transformations to apply after downloading the image
    public let transformations: [ImageTransformation]

    /// A description created by combining the URL and the descriptors of any transformations.
    ///
    /// The descriptor can be used to check if two image requests are semantically equal.
    /// If two requests use the same source URL and have the same transformations in the
    /// same order, then their result will be identical. If this case is detected, the
    /// `MatisseContext` can coalesce the requests and only execute one of them to receive
    /// the result for both requests.
    ///
    public var descriptor: String {
        return url.absoluteString + ";" + (transformations.map { $0.descriptor }).joined(separator: ";")
    }
}
