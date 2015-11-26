//
//  MatisseContext.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


@objc(MTSMatisseContext)
public class MatisseContext : NSObject {
    
    // MARK: - Shared Context
    
    private static var _sharedContext: MatisseContext?
    private static var _imageLoader: ImageLoader = DefaultImageLoader()
    
    @objc
    public class func sharedContext() -> MatisseContext {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: MatisseContext? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = MatisseContext(imageLoader: _imageLoader)
        }
        
        return Static.instance!
    }
    
    
    // MARK: - Initialization
    
    private let imageLoaderQueue: ImageLoaderQueue
    private let imageCreatorQueue = ImageCreatorQueue()
    
    private let memoryCache = NSCache()
    
    public init(imageLoader: ImageLoader = DefaultImageLoader()) {
        self.imageLoaderQueue = ImageLoaderQueue(imageLoader: imageLoader)
    }
    
    
    // MARK: - Loading Images
    
    public func load(url: NSURL) -> ImageRequestBuilder {
        return ImageRequestBuilder(context: self, URL: url)
    }
    
    public func executeRequest(request: ImageRequest, completion: (Result<UIImage>) -> Void) -> UIImage? {
        return nil
    }
    
    
    // MARK: - Internals
    
    
    
    internal func submitRequest(request: ImageRequest, completion: (Result<UIImage>) -> Void) {
        if let image = self.memoryCache.objectForKey(request.URL.absoluteString) as? UIImage {
            DispatchQueue.main.async {
                completion(Result.success(image))
            }
            return
        }
        
        imageLoaderQueue.submitFetchRequestForURL(request.URL) { result in
            guard let url = result.value else {
                completion(Result.error(result.error ?? NSError(domain: "", code: 0, userInfo: nil)))
                return
            }
            
            self.imageCreatorQueue.createImageFromURL(url, request: request) { result in
                DispatchQueue.main.async {
                    if let image = result.value {
                        self.memoryCache.setObject(image, forKey: request.URL.absoluteString)
                    }
                    completion(result)
                }
            }
        }
    }
}