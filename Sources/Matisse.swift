//
//  MatisseContext.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


@objc(MTSMatisse)
public class Matisse : NSObject {
    
    // MARK: - Shared Context
    
    private static var _sharedContext: Matisse?
    private static var _fastCache: ImageCache? = MemoryImageCache()
    private static var _slowCache: ImageCache? = MemoryImageCache()
    private static var _imageLoader: ImageLoader = DefaultImageLoader()
    
    public class func useImageLoader(imageLoader: ImageLoader) {
        assert(_sharedContext == nil, "Can't configure the shared Matisse context after first usage")
        
        _imageLoader = imageLoader
    }
    
    public class func sharedContext() -> Matisse {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: Matisse? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = Matisse(fastCache: _fastCache, slowCache: _slowCache, imageLoader: _imageLoader)
        }
        
        return Static.instance!
    }
    
    public class func load(url: NSURL) -> ImageRequestBuilder {
        return sharedContext().load(url)
    }
    

    // MARK: - Initialization
    
    private let fastCache: ImageCache?
    private let slowCache: ImageCache?
    private let syncQueue: DispatchQueue
    
    private let imageLoaderQueue: ImageLoaderQueue
    private let imageCreatorQueue = ImageCreatorQueue()
    
    private let memoryCache = NSCache()
    
    public init(fastCache: ImageCache?, slowCache: ImageCache?, imageLoader: ImageLoader) {
        self.fastCache = fastCache
        self.slowCache = slowCache
        self.imageLoaderQueue = ImageLoaderQueue(imageLoader: imageLoader)
        
        self.syncQueue = DispatchQueue(label: "ch.konoma.matisse.syncQueue", type: .Serial)
    }
    
    
    // MARK: - Loading Images
    
    public func executeRequest(request: ImageRequest, completion: (UIImage?, NSError?) -> Void) -> UIImage? {
        // first try to get an image from the fastCache, without going to a background queue
        if let image = fastCache?.retrieveImageForRequest(request) {
            DispatchQueue.main.async { completion(image, nil) }
            return image
        }
        
        // if we can't get an image out of the fast cache, go to background
        syncQueue.async {
            
            // secondly try to get an image from the slow cache
            if let image = self.slowCache?.retrieveImageForRequest(request) {
                DispatchQueue.main.async { completion(image, nil) }
                return
            }
        }
        
        // for all async request executing, return nil
        return nil
    }
    
    
    // MARK: - Internals
    
    internal func submitRequest(request: ImageRequest, completion: (UIImage?, NSError?) -> Void) {
        if let image = self.memoryCache.objectForKey(request.URL.absoluteString) as? UIImage {
            DispatchQueue.main.async {
                completion(image, nil)
            }
            return
        }
        
        imageLoaderQueue.submitFetchRequestForURL(request.URL) { result, error in
            guard let url = result else {
                completion(nil, error)
                return
            }
            
            self.imageCreatorQueue.createImageFromURL(url, request: request) { result, error in
                DispatchQueue.main.async {
                    if let image = result {
                        self.memoryCache.setObject(image, forKey: request.URL.absoluteString)
                    }
                    completion(result, error)
                }
            }
        }
    }
}


public extension Matisse {
    
    public func load(url: NSURL) -> ImageRequestBuilder {
        return ImageRequestBuilder(context: self, URL: url)
    }
}


public extension ImageRequestBuilder {
    
    public func into(imageView: UIImageView) {
        assert(NSThread.isMainThread())
        
        let identifier = build().identifier
        
        imageView.matisseRequestIdentifier = identifier
        
        execute { result, error in
            if imageView.matisseRequestIdentifier == identifier {
                imageView.image = result
                imageView.matisseRequestIdentifier = nil
            }
        }
    }
}


private var requestIdentifierKey: Int = 0

public extension UIImageView {
    
    public var matisseRequestIdentifier: NSUUID? {
        get { return objc_getAssociatedObject(self, &requestIdentifierKey) as? NSUUID }
        set { objc_setAssociatedObject(self, &requestIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
