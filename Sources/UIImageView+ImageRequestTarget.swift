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

    /// The identifier of the `ImageRequest` currently owning this target.
    ///
    public var matisseRequestIdentifier: UUID? {
        get { return objc_getAssociatedObject(self, &UIImageView.requestIdentifierKey) as? UUID }
        set { objc_setAssociatedObject(self, &UIImageView.requestIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Update this image view with the results of the given `ImageRequest`.
    ///
    /// Sets the image to the given `image`.
    ///
    /// - Parameters:
    ///   - imageRequest: The `ImageRequest` whose results should be displayed. Ignored.
    ///   - image:        The resolved image if the request was successful, or `nil`.
    ///   - error:        The error if the request failed, or `nil`. Ignored.
    ///
    public func update(forImageRequest imageRequest: ImageRequest, image: UIImage?, error: NSError?) {
        self.image = image
    }
}

// Cannot publicly specify protocol compliance. The image view is
// still compliant, because the methods are implemented above.
extension UIImageView: ImageRequestTarget { }


public extension ImageRequestBuilder {

    /// Same as `showInTarget(_: ImageRequestTarget)` but repeated here because of swift limitations.
    ///
    /// - Parameters:
    ///   - imageView: The target image view to show the fetched image in.
    ///
    public func showIn(_ imageView: UIImageView) {
        self.showIn(imageView as ImageRequestTarget)
    }
}
