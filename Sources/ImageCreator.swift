//
//  ImageCreator.swift
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation
import ImageIO


@objc(MTSImageCreator)
public class ImageCreator: NSObject {
    
    public func createImageFromURL(url: NSURL, request: ImageRequest) throws -> UIImage {
        let rawImage = try createCGImageFromURL(url)
        let transformedImage = try transformImage(rawImage, withTransformations: request.transformations)
        
        return UIImage(CGImage: transformedImage, scale: UIScreen.mainScreen().scale, orientation: .Up)
    }
    
    private func createCGImageFromURL(url: NSURL) throws -> CGImage {
        let options = [ (kCGImageSourceShouldCache as NSString): false ] as NSDictionary
        
        guard let source = CGImageSourceCreateWithURL(url, options) else {
            throw NSError.matisseCreationError("Could not create CGImageSource from URL \(url)")
        }
        
        guard let image = CGImageSourceCreateImageAtIndex(source, 0, options) else {
            throw NSError.matisseCreationError("Could not get CGImage from image source")
        }
        
        return image
    }
    
    private func transformImage(rawImage: CGImage, withTransformations transformations: [ImageTransformation]) throws -> CGImage {
        return try transformations.reduce(rawImage) { image, transformation in
            try transformation.transformImage(image)
        }
    }
}