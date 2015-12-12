//
//  UIImageView+ImageRequestTarget.swift
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import UIKit


public extension UIImageView {

    private static var requestIdentifierKey: Int = 0

    public var matisseRequestIdentifier: NSUUID? {
        get { return objc_getAssociatedObject(self, &UIImageView.requestIdentifierKey) as? NSUUID }
        set { objc_setAssociatedObject(self, &UIImageView.requestIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    public func updateForImageRequest(imageRequest: ImageRequest, image: UIImage?, error: NSError?) {
        self.image = image
    }
}

// Cannot publicly specify protocol compliance. The image view is
// still compliant, because the methods are implemented above.
extension UIImageView : ImageRequestTarget {
}
