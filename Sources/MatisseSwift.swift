//
//  Matisse.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public final class Matisse {
    
    private init() {} // prevent initialization
    
    private static let context = MatisseContext()
    
    public class func load(url: NSURL) -> ImageRequestBuilder {
        return context.load(url)
    }
}


public extension ImageRequestBuilder {
    
    public func into(imageView: UIImageView) {
        assert(NSThread.isMainThread())
        
        let identifier = build().identifier
        
        imageView.matisseRequestIdentifier = identifier
        
        execute { result in
            if imageView.matisseRequestIdentifier == identifier {
                imageView.image = result.value
                imageView.matisseRequestIdentifier = nil
            }
        }
    }
}


private var requestIdentifierKey: Int = 0

public extension UIImageView {
    
    public var matisseRequestIdentifier: NSUUID? {
        get { return objc_getAssociatedObject(self, &requestIdentifierKey) as? NSUUID }
        set { objc_setAssociatedObject(self, &requestIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}