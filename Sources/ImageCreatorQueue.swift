//
//  ImageCreatorQueue.swift
//  Matisse
//
//  Created by Markus Gasser on 23.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation
import ImageIO


internal class ImageCreatorQueue {
    
    typealias CreateResultHandler = (UIImage?, NSError?) -> Void
    
    private let dispatchQueue = DispatchQueue(label: "ch.konoma.matisse/imageCreatorQueue", type: .Concurrent)
    
    
    // MARK: - Submitting Requests
    
    func createImageFromURL(url: NSURL, request: ImageRequest, completion: CreateResultHandler) {
        dispatchQueue.async {
            let result: UIImage?
            let err: NSError?
            
            do {
                let image = try self.createAndTransformImageAtURL(url, transformations: request.transformations)
                result = UIImage(CGImage: image, scale: UIScreen.mainScreen().scale, orientation: .Up)
                err = nil
            } catch {
                result = nil
                err = error as NSError
            }
            
            DispatchQueue.main.async {
                completion(result, err)
            }
        }
    }
    
    private func createAndTransformImageAtURL(url: NSURL, transformations: [ImageTransformation]) throws -> CGImage {
        let options = [ (kCGImageSourceShouldCache as NSString): false ] as NSDictionary
        
        guard let source = CGImageSourceCreateWithURL(url, options) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        guard let image = CGImageSourceCreateImageAtIndex(source, 0, options) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        return try transformations.reduce(image) { image, transformation in
            try transformation.transformImage(image)
        }
    }
}