//
//  Matisse+UIImageView.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public extension ImageRequest {
    
    public func into(imageView: UIImageView) {
        
        imageView.matisseRequestIdentifier = identifier
        
        execute { result in
            if imageView.matisseRequestIdentifier == self.identifier {
                imageView.image = result.value
                imageView.matisseRequestIdentifier = nil
            }
        }
    }
}


private var requestIdentifierKey: Void


public extension UIImageView {
    
    public var matisseRequestIdentifier: NSUUID? {
        get { return objc_getAssociatedObject(self, &requestIdentifierKey) as? NSUUID }
        set { objc_setAssociatedObject(self, &requestIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
