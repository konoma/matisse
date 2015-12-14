//
//  DefaultImageLoader.swift
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// The default image loader provided with Matisse.
///
/// Downloads the images using `NSURLSession` download tasks.
///
@objc(MTSDefaultImageLoader)
public class DefaultImageLoader: ImageLoaderBase {

    private let urlSession: NSURLSession


    // MARK: - Initialization

    /// Create a new `DefaultImageLoader` using the shared `NSURLSession` and a private `NSFileManager`.
    ///
    public convenience init() {
        self.init(urlSession: NSURLSession.sharedSession())
    }

    /// Create a new `DefaultImageLoader` using a custom `NSURLSession`.
    ///
    /// - Parameters:
    ///   - urlSession: The `NSURLSession` to use to create download tasks.
    ///
    public convenience init(urlSession: NSURLSession) {
        self.init(urlSession: urlSession, fileManager: NSFileManager())
    }

    /// Create a new `DefaultImageLoader` using a custom `NSURLSession` and `NSFileManager`.
    ///
    /// - Parameters:
    ///   - urlSession:  The `NSURLSession` to use to create download tasks.
    ///   - fileManager: The file manager used for file operations.
    ///
    public init(urlSession: NSURLSession, fileManager: NSFileManager) {
        self.urlSession = urlSession

        super.init(fileManager: fileManager)
    }


    // MARK: - Downloading Images

    /// Donwload the image at the given source URL to a destination URL.
    ///
    /// Uses `NSURLSession` download tasks to download the image and copies them to the requested URL.
    ///
    /// - Parameters:
    ///   - sourceURL:      The URL where to download the image from.
    ///   - destinationURL: The local URL to save the downloaded image to.
    ///   - completion:     The completion block called after the download finishes.
    ///
    public override func loadImageAtURL(sourceURL: NSURL, toURL destinationURL: NSURL, completion: (NSURLResponse?, NSError?) -> Void) {
        let task = urlSession.downloadTaskWithRequest(NSURLRequest(URL: sourceURL)) { temporaryURL, response, error in
            guard let temporaryURL = temporaryURL else {
                completion(response, error)
                return
            }

            do {
                try self.fileManager.moveItemAtURL(temporaryURL, toURL: destinationURL)
                completion(response, nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
        task.resume()
    }
}
