//
//  DiskImageCache.swift
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


@objc(MTSDiskImageCache)
public class DiskImageCache: NSObject, ImageCache {

    private static var _defaultCacheDirectory = NSFileManager
        .defaultManager()
        .URLsForDirectory(.CachesDirectory, inDomains: .AllDomainsMask)
        .first!

    public class func defaultCacheDirectory() -> NSURL {
        return _defaultCacheDirectory
    }

    private let cacheDirectoryURL: NSURL
    private let fileManager: NSFileManager

    public override convenience init() {
        self.init(cacheDirectoryURL: DiskImageCache.defaultCacheDirectory(), fileManager: NSFileManager())
    }

    public init(cacheDirectoryURL: NSURL, fileManager: NSFileManager) {
        self.cacheDirectoryURL = cacheDirectoryURL
        self.fileManager = fileManager
    }

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
            print("Storing image to file at path \(path)")
            NSKeyedArchiver.archiveRootObject(image, toFile: path)
        }
    }

    public func retrieveImageForRequest(request: ImageRequest) -> UIImage? {
        let fileURL = fileURLFromRequest(request)

        guard let path = fileURL.absoluteURL.path else {
            return nil
        }

        print("Retrieving image from file at path \(path)")
        return NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? UIImage
    }

    private func fileURLFromRequest(request: ImageRequest) -> NSURL {
        return cacheDirectoryURL.URLByAppendingPathComponent(request.descriptor.matisseMD5String)
    }
}
