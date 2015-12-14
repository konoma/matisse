//
//  MemoryImageCache.swift
//  Matisse
//
//  Created by Markus Gasser on 28.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// A `ImageCache` implementation that uses `NSCache`.
///
@objc(MTSMemoryImageCache)
public class MemoryImageCache: NSObject, ImageCache {

    private let cache: NSCache

    // MARK: - Initialization

    /// Create a new instance with a private `NSCache` instance.
    ///
    public override convenience init() {
        self.init(cache: NSCache())
    }

    /// Create a new instance with a custom `NSCache` instance.
    ///
    /// - Parameters:
    ///   - cache: The `NSCache` instance used to cache images.
    ///
    public init(cache: NSCache) {
        self.cache = cache
    }


    // MARK: - Accessing the Cache

    /// Stores an image referenced by the given `ImageRequest` in this cache.
    ///
    /// - Parameters:
    ///   - image:   The image to store.
    ///   - request: The `ImageRequest` to store this image for.
    ///   - cost:    Optional hint on how expensive it is to recreate the image if evicted.
    ///              Pass `0` if no useful data is available.
    ///
    public func storeImage(image: UIImage, forRequest request: ImageRequest, withCost cost: Int) {
        cache.setObject(image, forKey: request.descriptor, cost: cost)
    }

    /// Returns the image for this request if it's still in the chache.
    ///
    /// - Parameters:
    ///   - request: The `ImageRequest` to return the image for.
    ///
    /// - Returns:
    ///   The image associated with this request if it's still in the cache. Otherwise `nil`.
    ///
    public func retrieveImageForRequest(request: ImageRequest) -> UIImage? {
        return cache.objectForKey(request.descriptor) as? UIImage
    }
}
