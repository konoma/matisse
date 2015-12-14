//
//  ResizeTransformation+DSL.swift
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import UIKit


public extension SwiftImageRequestCreator {

    /// Apply a transformation to resize the image to the given target size with the specified content mode.
    ///
    /// - Parameters:
    ///   - targetSize:  The target size to resize the image to.
    ///   - contentMode: The content mode describing how the image should fit into the target size.
    ///                  Default is `UIViewContentMode.ScaleToFill`.
    ///
    /// - Returns:
    ///   The receiver.
    ///
    public func resizeTo(targetSize: CGSize, contentMode: UIViewContentMode = .ScaleToFill) -> Self {
        return transform(ResizeTransformation(targetSize: targetSize, contentMode: contentMode))
    }

    /// Apply a transformation to resize the image to the given target size with the specified content mode.
    ///
    /// - Parameters:
    ///   - width:       The target width to resize the image to.
    ///   - height:      The target height to resize the image to.
    ///   - contentMode: The content mode describing how the image should fit into the target size.
    ///                  Default is `UIViewContentMode.ScaleToFill`.
    ///
    /// - Returns:
    ///   The receiver.
    ///
    public func resizeTo(width width: CGFloat, height: CGFloat, contentMode: UIViewContentMode = .ScaleToFill) -> Self {
        return resizeTo(CGSize(width: width, height: height), contentMode: contentMode)
    }
}
