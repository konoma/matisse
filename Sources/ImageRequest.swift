//
//  ImageRequest.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/**
 * Encapsulates information about an image request.
 *
 * Image requests are uniquely identifiable by their identifier.
 * If necessary they can be checked for content equality by comparing
 * their descriptor. This is a string created by combining the URL
 * of the request with any transformations applied to the image.
 * This is then for example used to implement request coalescing.
 */
@objc(MTSImageRequest)
public class ImageRequest : NSObject {
    
    /// The unique identifier for this request
    public let identifier: NSUUID
    
    /// The source URL for this image
    public let URL: NSURL
    
    /// Any transformations to apply after downloading the image
    public let transformations: [ImageTransformation]
    
    /**
     * Create a new image request.
     */
    public init(URL: NSURL, transformations: [ImageTransformation]) {
        self.identifier = NSUUID()
        self.URL = URL
        self.transformations = transformations
    }
    
    /**
     * A description created by combining the URL and any transformations.
     *
     * Can be used to check if two image requests are semantically equal
     * (i.e. they have the same source URL and transformations in the same
     * order).
     */
    public var descriptor: String {
        return URL.absoluteString + ";" + (transformations.map { $0.descriptor }).joinWithSeparator(";")
    }
}
