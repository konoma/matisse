//
//  MatisseImageLoader.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//


import Foundation


/// An `ImageLoader` is responsible for downloading images.
///
/// For support in implementing an `ImageLoader` you can use
/// the `ImageLoaderBase` as a parent class for your image loader.
///
@objc(MTSImageLoader)
public protocol ImageLoader : NSObjectProtocol {
    
    /// Load the image for the given request.
    ///
    /// When the image was loaded, pass an NSURL of a temporary file
    /// that holds the downloaded image to the completion block. The
    /// caller takes ownership of this file and is responsible for
    /// deleting it when no longer in use.
    ///
    /// - Parameters:
    ///   - request:    The image request for which the image should be loaded.
    ///   - completion: The completion block to call when the request has finished.
    ///
    func loadImageForRequest(request: ImageRequest, completion: (NSURL?, NSError?) -> Void)
}


/// Abstract base class for `ImageLoader` implementors.
///
/// Implements common logic such as generating temporary URLs
/// and checking response status codes.
///
@objc(MTSImageLoaderBase)
public class ImageLoaderBase: NSObject, ImageLoader {
    
    /// The file manager used to create the temporary directory if necessary
    public let fileManager: NSFileManager
    
    /// Create a new instance of this class.
    ///
    /// - Parameters:
    ///   - fileManager: Allows providing a custom file manager. Used for testing purposes, you should not need this.
    ///
    public init(fileManager: NSFileManager = NSFileManager()) {
        self.fileManager = fileManager
    }
    
    /// Load the image for the given request.
    ///
    /// Implements the `ImageLoader` protocol requirement. This method first creates a temporary file path
    /// and prepares it for the actual request. Then this calls `loadImageAtURL(_:, toURL:)` with the request
    /// URL and the destination URL respective, passing a completion block. The completion block then handles
    /// the response by checking the status code and potential errors. Afterwards the completion block of this
    /// method is called with appropriate values.
    ///
    /// In your subclass you only need to override `loadImageAtURL(_:, toURL:)` to provide the actual download.
    ///
    /// - Parameters:
    ///   - request:    The image request for which the image should be loaded.
    ///   - completion: The completion block to call when the request has finished.
    ///
    public func loadImageForRequest(request: ImageRequest, completion: (NSURL?, NSError?) -> Void) {
        // create a destination URL and make sure the containing directory exists
        let destinationURL = createDestinationURL()
        if let directoryURL = destinationURL.URLByDeletingLastPathComponent {
            do {
                try fileManager.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                // We can safely ignore this error. If it's something serious it will be caught later.
                // A likely error is that this directory already exists
            }
        }
        
        // call the actual implementation to really download the image
        loadImageAtURL(request.URL, toURL: destinationURL) { response, error in
            // handle any response error
            guard let response = response else {
                completion(nil, error ?? NSError.matisseUnknownError())
                return
            }
            
            // check for a 200 OK status code from the server
            if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode != 200 {
                completion(nil, NSError.matisseDownloadError("Unexpected status code \(httpResponse.statusCode) (expected 200)"))
                return
            }
            
            // all good!
            completion(destinationURL, nil)
        }
    }
    
    /// Donwload the image at the given source URL to a destination URL.
    ///
    /// This method is called by the default implementation of `loadImageForRequest(_:, completion:)` to actually
    /// download the image. When the download finishes call the completion block with the url response and error.
    ///
    /// - Note: You must override this method.
    ///
    /// - Parameters:
    ///   - sourceURL:      The URL where to download the image from
    ///   - destinationURL: The local URL to save the downloaded image to
    ///   - completion:     The completion block to call after the download finishes (either successfully or not)
    ///
    public func loadImageAtURL(sourceURL: NSURL, toURL destinationURL: NSURL, completion: (NSURLResponse?, NSError?) -> Void) {
        fatalError("You must override this method in a subclass")
    }
    
    /// Create a unique temporary file URL.
    ///
    /// - Returns: A path to a unique temporary file.
    ///
    private func createDestinationURL() -> NSURL {
        return NSURL(fileURLWithPath: NSTemporaryDirectory())
            .URLByAppendingPathComponent("MatisseImageLoader")
            .URLByAppendingPathComponent(NSUUID().UUIDString)
    }
}
