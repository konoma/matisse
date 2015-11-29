//
//  MatisseImageLoader.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//


import Foundation


/**
 * An `ImageLoader` is responsible for downloading images.
 *
 * For support in implementing an `ImageLoader` you can use
 * the `ImageLoaderBase` as a parent class for your image loader.
 */
@objc(MTSImageLoader)
public protocol ImageLoader : NSObjectProtocol {
    
    /**
     * Load the image for the given request.
     *
     * When the image was loaded, pass an NSURL of a temporary file
     * that holds the downloaded image to the completion block. The
     * caller takes ownership of this file and is responsible for
     * deleting it when no longer in use.
     *
     * - Parameters:
     *   - request:    The image request for which the image should be loaded.
     *   - completion: The completion block to call when the request has finished.
     */
    func loadImageForRequest(request: ImageRequest, completion: (NSURL?, NSError?) -> Void)
}


/**
 * Abstract base class for `ImageLoader` implementors.
 *
 * Implements common logic such as generating temporary URLs
 * and checking response status codes.
 */
@objc(MTSImageLoaderBase)
public class ImageLoaderBase: NSObject, ImageLoader {
    
    public let fileManager: NSFileManager
    
    public init(fileManager: NSFileManager = NSFileManager()) {
        self.fileManager = fileManager
    }
    
    public func loadImageForRequest(request: ImageRequest, completion: (NSURL?, NSError?) -> Void) {
        let destinationURL = createDestinationURL()
        
        // make sure the destination directory exists
        if let directoryURL = destinationURL.URLByDeletingLastPathComponent {
            do {
                try fileManager.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                // We can safely ignore this error. If it's something serious it will be caught later.
            }
        }
        
        loadImageAtURL(request.URL, toURL: destinationURL) { response, error in
            guard let response = response else {
                completion(nil, error ?? NSError.matisseUnknownError())
                return
            }
            
            if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode != 200 {
                completion(nil, NSError.matisseDownloadError("Unexpected status code \(httpResponse.statusCode) (expected 200)"))
                return
            }
            
            completion(destinationURL, nil)
        }
    }
    
    public func loadImageAtURL(sourceURL: NSURL, toURL destinationURL: NSURL, completion: (NSURLResponse?, NSError?) -> Void) {
        fatalError("You must override this method in a subclass")
    }
    
    /// create a unique temporary file URL
    private func createDestinationURL() -> NSURL {
        return NSURL(fileURLWithPath: NSTemporaryDirectory())
            .URLByAppendingPathComponent("MatisseImageLoader")
            .URLByAppendingPathComponent(NSUUID().UUIDString)
    }
}
