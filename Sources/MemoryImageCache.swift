//
//  MemoryImageCache.swift
//  Matisse
//
//  Created by Markus Gasser on 28.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


@objc(MTSMemoryImageCache)
public class MemoryImageCache: NSObject, ImageCache {
    
    private let cache: NSCache
    
    public init(cache: NSCache = NSCache()) {
        self.cache = cache
    }
    
    public func storeImage(image: UIImage, forRequest request: ImageRequest, withCost cost: Int) {
        cache.setObject(image, forKey: request.descriptor, cost: cost)
    }
    
    public func retrieveImageForRequest(request: ImageRequest) -> UIImage? {
        return cache.objectForKey(request.descriptor) as? UIImage
    }
}
