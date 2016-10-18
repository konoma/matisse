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
public protocol ImageLoader: class {

    /// Load the image for the given request.
    ///
    /// When the image was loaded, pass an URL of a temporary file
    /// that holds the downloaded image to the completion block. The
    /// caller takes ownership of this file and is responsible for
    /// deleting it when no longer in use.
    ///
    /// - Note:
    ///   This method may be called from a background thread, but not concurrently.
    ///
    /// - Parameters:
    ///   - request:    The image request for which the image should be loaded.
    ///   - completion: The completion block to call when the request has finished.
    ///
    func loadImage(forRequest request: ImageRequest, completion: @escaping (URL?, NSError?) -> Void)
}


/// Abstract base class for `ImageLoader` implementors.
///
/// Implements common logic such as generating temporary URLs
/// and checking response status codes.
///
open class ImageLoaderBase: ImageLoader {

    /// The file manager used to create the temporary directory if necessary
    public let fileManager: FileManager

    /// Create a new instance of this class.
    ///
    /// - Parameters:
    ///   - fileManager: Allows providing a custom file manager. Used for testing purposes, you should not need this.
    ///
    public init(fileManager: FileManager = FileManager()) {
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
    /// In your subclass you only need to override `loadImage(atUrl:, toUrl:)` to provide the actual download.
    ///
    /// - Parameters:
    ///   - request:    The image request for which the image should be loaded.
    ///   - completion: The completion block to call when the request has finished.
    ///
    open func loadImage(forRequest request: ImageRequest, completion: @escaping (URL?, NSError?) -> Void) {
        // create a destination URL and make sure the containing directory exists
        let destinationUrl = createDestinationURL()

        do {
            let directory = destinationUrl.deletingLastPathComponent()
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            // We can safely ignore this error. If it's something serious it will be caught later.
            // A likely error is that this directory already exists
        }

        // call the actual implementation to really download the image
        loadImage(atUrl: request.url, toUrl: destinationUrl) { response, error in
            // handle any response error
            guard let response = response else {
                completion(nil, error ?? NSError.matisseUnknownError())
                return
            }

            // check for a 200 OK status code from the server
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion(nil, NSError.matisseDownloadError("Unexpected status code \(httpResponse.statusCode) (expected 200)"))
                return
            }

            // all good!
            completion(destinationUrl, nil)
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
    ///   - sourceUrl:      The URL where to download the image from.
    ///   - destinationUrl: The local URL to save the downloaded image to.
    ///   - completion:     The completion block to call after the download finishes (either successfully or not).
    ///
    open func loadImage(atUrl sourceUrl: URL, toUrl destinationUrl: URL, completion: @escaping (URLResponse?, NSError?) -> Void) {
        fatalError("You must override this method in a subclass")
    }

    /// Create a unique temporary file URL.
    ///
    /// - Returns:
    ///   A path to a unique temporary file.
    ///
    private func createDestinationURL() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("MatisseImageLoader")
            .appendingPathComponent(UUID().uuidString)
    }
}
