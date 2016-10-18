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
public class DiskImageCache: ImageCache {

    private let cacheDirectoryURL: URL
    private let fileManager: FileManager


    // MARK: - Global Configuration

    /// The default cache directory for this application.
    ///
    public static var defaultCacheDirectory: URL = {
        return FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask)[0]
    }()


    // MARK: - Initialization

    /// Create a new `DiskImageCache` with the default cache directory and a private file manager.
    ///
    public convenience init() {
        self.init(cacheDirectoryURL: DiskImageCache.defaultCacheDirectory)
    }

    /// Create a new `DiskImageCache` with a custom cache directory and a private file manager.
    ///
    /// - Parameters:
    ///   - cacheDirectoryURL: The URL of the directory to use as the cache.
    ///
    public convenience init(cacheDirectoryURL: URL) {
        self.init(cacheDirectoryURL: cacheDirectoryURL, fileManager: FileManager())
    }

    /// Create a new `DiskImageCache` with a custom cache directory and file manager.
    ///
    /// - Parameters:
    ///   - cacheDirectoryURL: The URL of the directory to use as the cache.
    ///   - fileManager:       The file manager used to access files.
    ///
    public init(cacheDirectoryURL: URL, fileManager: FileManager) {
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
    public func store(image: UIImage, forRequest request: ImageRequest, withCost cost: Int) {
        let fileUrl = self.fileUrl(fromRequest: request)

        // make sure the destination directory exists
        do {
            let directoryURL = fileUrl.deletingLastPathComponent()
            try self.fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            // We can safely ignore this error. If it's something serious it will be caught later.
        }

        NSKeyedArchiver.archiveRootObject(image, toFile: fileUrl.absoluteURL.path)
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
        let fileUrl = self.fileUrl(fromRequest: request)

        return NSKeyedUnarchiver.unarchiveObject(withFile: fileUrl.absoluteURL.path) as? UIImage
    }


    // MARK: - Helpers

    private func fileUrl(fromRequest request: ImageRequest) -> URL {
        return self.cacheDirectoryURL.appendingPathComponent(request.descriptor.matisseMD5)
    }
}
