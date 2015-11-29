//
//  ResizeTransformation.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public class ResizeTransformation : NSObject, ImageTransformation {
    
    public let targetSize: CGSize
    public let contentMode: UIViewContentMode
    public let deviceScale: CGFloat
    private let scaledTargeSize: CGSize
    
    public init(targetSize: CGSize, contentMode: UIViewContentMode, deviceScale: CGFloat = UIScreen.mainScreen().scale) {
        self.targetSize = targetSize
        self.contentMode = contentMode
        self.deviceScale = deviceScale
        
        self.scaledTargeSize = CGSize(width: (targetSize.width * deviceScale), height: (targetSize.height * deviceScale))
    }
    
    public var descriptor: String {
        return "resize(\(targetSize.width),\(targetSize.height),\(deviceScale),\(contentMode.rawValue))"
    }
    
    public func transformImage(image: CGImage) throws -> CGImage {
        let bitsPerComponent = CGImageGetBitsPerComponent(image)
        let bytesPerRow = CGImageGetBytesPerRow(image)
        let colorSpace = CGImageGetColorSpace(image)
        let bitmapInfo = CGImageGetBitmapInfo(image)
        
        let originalSize = CGSize(width: CGImageGetWidth(image), height: CGImageGetHeight(image))
        
        let context = CGBitmapContextCreate(nil, Int(scaledTargeSize.width), Int(scaledTargeSize.height), bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        CGContextSetInterpolationQuality(context, .High)
        CGContextDrawImage(context, calculateImageRectWithOriginalSize(originalSize), image)
        
        if let scaled = CGBitmapContextCreateImage(context) {
            return scaled
        } else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
    }
    
    private func calculateImageRectWithOriginalSize(originalSize: CGSize) -> CGRect {
        switch contentMode {
        case .ScaleToFill:
            return CGRect(origin: CGPointZero, size: scaledTargeSize)
            
        case .ScaleAspectFill:
            let widthScale = originalSize.width / scaledTargeSize.width
            let heightScale = originalSize.height / scaledTargeSize.height
            let scale = min(widthScale, heightScale)
            let scaledSize = CGSize(width: round(originalSize.width / scale), height: round(originalSize.height / scale))
            return centerRectWithSize(scaledSize, inSize: scaledTargeSize)
            
        default:
            return CGRect(origin: CGPointZero, size: targetSize)
        }
    }
    
    private func centerRectWithSize(size: CGSize, inSize targetSize: CGSize) -> CGRect {
        let xOffset = round(targetSize.width - size.width) / 2.0
        let yOffset = round(targetSize.height - size.height) / 2.0
        return CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: size)
    }
}


public extension ImageRequestBuilder {
    
    public func resizeTo(targetSize: CGSize, contentMode: UIViewContentMode = .ScaleToFill) -> ImageRequestBuilder {
        return addTransformation(ResizeTransformation(targetSize: targetSize, contentMode: contentMode))
    }
    
    public func resizeTo(width width: CGFloat, height: CGFloat, contentMode: UIViewContentMode = .ScaleToFill) -> ImageRequestBuilder {
        return resizeTo(CGSize(width: width, height: height), contentMode: contentMode)
    }
}
