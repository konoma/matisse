//
//  ImageCache.swift
//  Matisse
//
//  Created by Markus Gasser on 28.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// An `ImageCache` is an object capable of storing and maybe later returning images for an `ImageRequest`.
///
/// There are two kinds of caches in use in a `MatisseContext`: the fast cache and the slow cache.
///
/// The fast cache is called synchronously when the context tries to resolve an `ImageRequest`. This
/// operation is therefore blocking the main thread and should be as fast as possible. Disk access and
/// other expensive operations should be avoided in the fast cache.
///
/// The slow cache is called in an asynchronous fashion from a background thread. Since the main thread
/// is not blocked this way, the cache is free to use more expensive operations (like disk IO).
///
/// Both caches implement this protocol though and are called the same (only in different environments).
///
/// The fast cache is always accessed from the main thread. The slow cache may be accessed from a
/// background thread, but not concurrently. This means the caches themselves are not required to be
/// thread safe.
///
public protocol ImageCache: class {

    /// Stores an image referenced by the given `ImageRequest` in this cache.
    ///
    /// The cache is free how and if the image is stored. The cost parameter gives the cache a hint
    /// how expensive it is to recreate this image. This information may be used by the cache to
    /// decide what objects to evict when space gets tight. It's not guaranteed that this value
    /// is set. If no hint is given then `0` will be passed.
    ///
    /// - Note:
    ///   May be called from a background thread, but never concurrently.
    ///
    /// - Parameters:
    ///   - image:   The image to store.
    ///   - request: The `ImageRequest` to store this image for.
    ///   - cost:    Optional hint on how expensive it is to recreate the image if evicted.
    ///              Pass `0` if no useful data is available.
    ///
    func store(image: UIImage, forRequest request: ImageRequest, withCost cost: Int)

    /// Returns the image for this request if it's still in the chache.
    ///
    /// - Note:
    ///   May be called from a background thread, but never concurrently.
    ///
    /// - Parameters:
    ///   - request: The `ImageRequest` to return the image for.
    ///
    /// - Returns:
    ///   The image associated with this request if it's still in the cache. Otherwise `nil`.
    ///
    func retrieveImage(forRequest request: ImageRequest) -> UIImage?
}
