//
//  ResizeTransformation.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public class ResizeTransformation : NSObject, MatisseTransformation {
    
    public let targetSize: CGSize
    
    public init(targetSize: CGSize) {
        self.targetSize = targetSize
    }
    
    public func transformImage(image: CGImage) throws -> CGImage {
        let bitsPerComponent = CGImageGetBitsPerComponent(image)
        let bytesPerRow = CGImageGetBytesPerRow(image)
        let colorSpace = CGImageGetColorSpace(image)
        let bitmapInfo = CGImageGetBitmapInfo(image)
        
        let context = CGBitmapContextCreate(nil, Int(targetSize.width), Int(targetSize.height), bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        CGContextSetInterpolationQuality(context, .High)
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: targetSize), image)
        
        if let scaled = CGBitmapContextCreateImage(context) {
            return scaled
        } else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
    }
}


public extension MatisseRequest {
    
    public func resize(targetSize: CGSize) -> MatisseRequest {
        return addTransformation(ResizeTransformation(targetSize: targetSize))
    }
}
