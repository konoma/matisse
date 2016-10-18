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
public class MemoryImageCache: ImageCache {

    private let cache: NSCache<AnyObject, AnyObject>

    // MARK: - Initialization

    /// Create a new instance with a private `NSCache` instance.
    ///
    public convenience init() {
        self.init(cache: NSCache())
    }

    /// Create a new instance with a custom `NSCache` instance.
    ///
    /// - Parameters:
    ///   - cache: The `NSCache` instance used to cache images.
    ///
    public init(cache: NSCache<AnyObject, AnyObject>) {
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
    public func store(image: UIImage, forRequest request: ImageRequest, withCost cost: Int) {
        self.cache.setObject(image, forKey: request.descriptor as AnyObject, cost: cost)
    }

    /// Returns the image for this request if it's still in the chache.
    ///
    /// - Parameters:
    ///   - request: The `ImageRequest` to return the image for.
    ///
    /// - Returns:
    ///   The image associated with this request if it's still in the cache. Otherwise `nil`.
    ///
    public func retrieveImage(forRequest request: ImageRequest) -> UIImage? {
        return self.cache.object(forKey: request.descriptor as AnyObject) as? UIImage
    }
}
