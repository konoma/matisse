//
//  ResizeTransformation+DSL.swift
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import UIKit


public extension SwiftImageRequestCreator {
    
    public func resizeTo(targetSize: CGSize, contentMode: UIViewContentMode = .ScaleToFill) -> Self {
        return transform(ResizeTransformation(targetSize: targetSize, contentMode: contentMode))
    }
    
    public func resizeTo(width width: CGFloat, height: CGFloat, contentMode: UIViewContentMode = .ScaleToFill) -> Self {
        return resizeTo(CGSize(width: width, height: height), contentMode: contentMode)
    }
}
