//
//  MatisseContext.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation
import ImageIO


public class MatisseContext : NSObject {
    
    private let imageLoaderQueue = ImageLoaderQueue(imageLoader: DefaultImageLoader())
    private let transformationQueue = DispatchQueue(label: "ch.konoma.matisse/transformationQueue", type: .Concurrent)
    private let memoryCache = NSCache()
    
    
    // MARK: - Loading Images
    
    public func load(url: NSURL) -> MatisseRequest {
        return MatisseRequest(context: self, URL: url)
    }
    
    
    // MARK: - Internals
    
    internal func submitRequest(request: MatisseRequest) {
        if let image = self.memoryCache.objectForKey(request.URL.absoluteString) as? UIImage {
            DispatchQueue.main.async {
                request.notifyResult(Result.success(image))
            }
            return
        }
        
        imageLoaderQueue.submitFetchRequestForURL(request.URL) { result in
            guard let url = result.value else {
                request.notifyResult(Result.error(result.error ?? NSError(domain: "", code: 0, userInfo: nil)))
                return
            }
            
            self.transformationQueue.async {
                let result: Result<UIImage>
                
                do {
                    let image = try self.createAndTransformImageAtURL(url, transformations: request.transformations)
                    result = Result.success(UIImage(CGImage: image, scale: UIScreen.mainScreen().scale, orientation: .Up))
                } catch {
                    result = Result.error(error)
                }
                
                DispatchQueue.main.async {
                    self.memoryCache.setObject(result.value!, forKey: request.URL.absoluteString)
                    request.notifyResult(result)
                }
            }
        }
    }
    
    private func createAndTransformImageAtURL(url: NSURL, transformations: [MatisseTransformation]) throws -> CGImage {
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