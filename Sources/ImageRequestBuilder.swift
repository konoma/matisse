//
//  ImageRequestBuilder.swift
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


@objc(MTSImageRequestBuilder)
public class ImageRequestBuilder : NSObject {
    
    private let context: Matisse
    private let URL: NSURL
    private var transformations: [ImageTransformation] = []
    private var builtRequest: ImageRequest?
    
    public init(context: Matisse, URL: NSURL) {
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
        context.executeRequest(build(), completion: completion)
    }
    
    
    // MARK: - Helper
    
    private func checkNotYetBuilt() {
        assert(builtRequest == nil, "Cannot modify the request because it was already built")
    }
}


// MARK: - Convenience Initialization

public extension Matisse {
    
    public class func load(url: NSURL) -> ImageRequestBuilder {
        return sharedContext().load(url)
    }
    
    public func load(url: NSURL) -> ImageRequestBuilder {
        return ImageRequestBuilder(context: self, URL: url)
    }
}


// MARK: - Support for UIImageView

public extension ImageRequestBuilder {
    
    public func into(imageView: UIImageView) {
        let identifier = build().identifier
        
        imageView.matisseRequestIdentifier = identifier
        
        execute { result, error in
            if imageView.matisseRequestIdentifier == identifier {
                imageView.image = result
                imageView.matisseRequestIdentifier = nil
            }
        }
    }
}

public extension UIImageView {
    
    private static var requestIdentifierKey: Int = 0
    
    public var matisseRequestIdentifier: NSUUID? {
        get { return objc_getAssociatedObject(self, &UIImageView.requestIdentifierKey) as? NSUUID }
        set { objc_setAssociatedObject(self, &UIImageView.requestIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
