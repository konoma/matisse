//
//  MatisseContext.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public class MatisseContext : NSObject {
    
    private let imageLoaderQueue = ImageLoaderQueue(imageLoader: DefaultImageLoader())
    private let imageCreatorQueue = ImageCreatorQueue()
    
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
            
            self.imageCreatorQueue.createImageFromURL(url, request: request) { result in
                DispatchQueue.main.async {
                    if let image = result.value {
                        self.memoryCache.setObject(image, forKey: request.URL.absoluteString)
                    }
                    request.notifyResult(result)
                }
            }
        }
    }
}