//
//  ImageRequest.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


@objc(MTSImageRequest)
public class ImageRequest : NSObject {
    
    public let identifier: NSUUID
    public let URL: NSURL
    public let transformations: [ImageTransformation]
    
    public init(URL: NSURL, transformations: [ImageTransformation]) {
        self.identifier = NSUUID()
        self.URL = URL
        self.transformations = transformations
    }
    
    public var descriptor: String {
        return URL.absoluteString + ";" + (transformations.map { $0.descriptor }).joinWithSeparator(";")
    }
}
