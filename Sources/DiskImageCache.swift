//
//  DiskImageCache.swift
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// A naive implementation of `ImageCache` that stores files on disk.
///
/// This class stores files in the caches directory of the application.
/// It relies on the operating system to cleanup images. Suitable for
/// a reasonable amount of images. If you download large numbers of images,
/// you should probably look to implement this differently, or find a way
/// to manage the directory size.
///
/// Images are serialized using `NSKeyedArchiver` to preserve file type and metadata.
///
@objc(MTSDiskImageCache)
public class DiskImageCache: NSObject, ImageCache {

    private let cacheDirectoryURL: NSURL
    private let fileManager: NSFileManager

    private static var _defaultCacheDirectory = NSFileManager
        .defaultManager()
        .URLsForDirectory(.CachesDirectory, inDomains: .AllDomainsMask)
        .first!


    // MARK: - Global Configuration

    /// Get the default cache directory for this application.
    ///
    /// - Returns:
    ///   The default cache directory for this application.
    ///
    public class func defaultCacheDirectory() -> NSURL {
        return _defaultCacheDirectory
    }


    // MARK: - Initialization

    /// Create a new `DiskImageCache` with the default cache directory and a private file manager.
    ///
    public override convenience init() {
        self.init(cacheDirectoryURL: DiskImageCache.defaultCacheDirectory())
    }

    /// Create a new `DiskImageCache` with a custom cache directory and a private file manager.
    ///
    /// - Parameters:
    ///   - cacheDirectoryURL: The URL of the directory to use as the cache.
    ///
    public convenience init(cacheDirectoryURL: NSURL) {
        self.init(cacheDirectoryURL: cacheDirectoryURL, fileManager: NSFileManager())
    }

    /// Create a new `DiskImageCache` with a custom cache directory and file manager.
    ///
    /// - Parameters:
    ///   - cacheDirectoryURL: The URL of the directory to use as the cache.
    ///   - fileManager:       The file manager used to access files.
    ///
    public init(cacheDirectoryURL: NSURL, fileManager: NSFileManager) {
        self.cacheDirectoryURL = cacheDirectoryURL
        self.fileManager = fileManager
    }


    // MARK: - Accessing the Cache

    /// Stores an image referenced by the given `ImageRequest` in this cache.
    ///
    /// - Parameters:
    ///   - image:   The image to store.
    ///   - request: The `ImageRequest` to store this image for.
    ///   - cost:    Ignored.
    ///
    public func storeImage(image: UIImage, forRequest request: ImageRequest, withCost cost: Int) {
        let fileURL = fileURLFromRequest(request)

        // make sure the destination directory exists
        if let directoryURL = fileURL.URLByDeletingLastPathComponent {
            do {
                try fileManager.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                // We can safely ignore this error. If it's something serious it will be caught later.
            }
        }

        if let path = fileURL.absoluteURL.path {
            NSKeyedArchiver.archiveRootObject(image, toFile: path)
        }
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
        let fileURL = fileURLFromRequest(request)

        guard let path = fileURL.absoluteURL.path else {
            return nil
        }

        return NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? UIImage
    }


    // MARK: - Helpers

    private func fileURLFromRequest(request: ImageRequest) -> NSURL {
        return cacheDirectoryURL.URLByAppendingPathComponent(request.descriptor.matisseMD5String)
    }
}
