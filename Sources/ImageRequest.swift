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
}


@objc(MTSImageRequestBuilder)
public class ImageRequestBuilder : NSObject {
    
    private let context: Matisse
    private let URL: NSURL
    private var transformations: [ImageTransformation] = []
    private var builtRequest: ImageRequest?
    
    internal init(context: Matisse, URL: NSURL) {
        self.context = context
        self.URL = URL
    }
    
    
    // MARK: - Configuration
    
    public func addTransformation(transformation: ImageTransformation) -> ImageRequestBuilder {
        checkNotYetBuilt()
        
        transformations.append(transformation)
        return self
    }
    
    
    // MARK: - Building and Executing the Request
    
    public func build() -> ImageRequest {
        if let request = builtRequest {
            return request
        }
        
        let request = ImageRequest(URL: URL, transformations: transformations)
        builtRequest = request
        return request
    }
    
    public func execute(completion: (UIImage?, NSError?) -> Void) {
        context.submitRequest(build(), completion: completion)
    }
    
    
    // MARK: - Helper
    
    private func checkNotYetBuilt() {
        assert(builtRequest == nil, "Cannot modify the request because it was already built")
    }
}
