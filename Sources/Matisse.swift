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
    private static var _requestHandler: ImageRequestHandler = DefaultImageRequestHandler(imageLoader: DefaultImageLoader())
    
    public class func sharedContext() -> Matisse {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: Matisse? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = Matisse(fastCache: _fastCache, slowCache: _slowCache, requestHandler: _requestHandler)
        }
        
        return Static.instance!
    }
    
    public class func load(url: NSURL) -> ImageRequestBuilder {
        return sharedContext().load(url)
    }
    

    // MARK: - Initialization
    
    private let fastCache: ImageCache?
    private let slowCache: ImageCache?
    private let requestHandler: ImageRequestHandler
    private let syncQueue: DispatchQueue
    
    public init(fastCache: ImageCache?, slowCache: ImageCache?, requestHandler: ImageRequestHandler) {
        self.fastCache = fastCache
        self.slowCache = slowCache
        self.requestHandler = requestHandler
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
                DispatchQueue.main.async {
                    completion(image, nil)
                }
                return
            }
            
            // if we can't get a cached image, try to retrieve it from the handler
            self.requestHandler.retrieveImageForRequest(request) { image, error in
                // cache a retrieved image before notifying
                if let image = image {
                    self.cacheImage(image, forRequest: request)
                }
                
                // report the result on the main queue
                DispatchQueue.main.async {
                    completion(image, error)
                }
            }
        }
        
        // return nil for all requests resolved in background
        return nil
    }
    
    private func cacheImage(image: UIImage, forRequest request: ImageRequest) {
        let cost = 0 // to be calculated, e.g. using the time it took to create the image
        
        // cache the result in the slow cache on the background sync queue
        self.syncQueue.async {
            self.slowCache?.storeImage(image, forRequest: request, withCost: cost)
        }
        
        // cache the result in the fast cache on the main queue
        DispatchQueue.main.async {
            self.fastCache?.storeImage(image, forRequest: request, withCost: cost)
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
