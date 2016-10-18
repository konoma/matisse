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
/// Downloads the images using `URLSession` download tasks.
///
public class DefaultImageLoader: ImageLoaderBase {

    private let urlSession: URLSession


    // MARK: - Initialization

    /// Create a new `DefaultImageLoader` using the shared `URLSession` and a private `NSFileManager`.
    ///
    public convenience init() {
        self.init(urlSession: URLSession.shared)
    }

    /// Create a new `DefaultImageLoader` using a custom `URLSession`.
    ///
    /// - Parameters:
    ///   - urlSession: The `URLSession` to use to create download tasks.
    ///
    public convenience init(urlSession: URLSession) {
        self.init(urlSession: urlSession, fileManager: FileManager())
    }

    /// Create a new `DefaultImageLoader` using a custom `URLSession` and `NSFileManager`.
    ///
    /// - Parameters:
    ///   - urlSession:  The `URLSession` to use to create download tasks.
    ///   - fileManager: The file manager used for file operations.
    ///
    public init(urlSession: URLSession, fileManager: FileManager) {
        self.urlSession = urlSession

        super.init(fileManager: fileManager)
    }


    // MARK: - Downloading Images

    /// Donwload the image at the given source URL to a destination URL.
    ///
    /// Uses `URLSession` download tasks to download the image and copies them to the requested URL.
    ///
    /// - Parameters:
    ///   - sourceURL:      The URL where to download the image from.
    ///   - destinationURL: The local URL to save the downloaded image to.
    ///   - completion:     The completion block called after the download finishes.
    ///
    public override func loadImage(atUrl source: URL, toUrl destination: URL, completion: @escaping (URLResponse?, NSError?) -> Void) {
        let task = self.urlSession.downloadTask(with: URLRequest(url: source), completionHandler: { temporaryLocation, response, error in
            guard let temporaryLocation = temporaryLocation else {
                completion(response, error as NSError?)
                return
            }

            do {
                try self.fileManager.moveItem(at: temporaryLocation, to: destination)
                completion(response, nil)
            } catch {
                completion(nil, error as NSError)
            }
        })
        task.resume()
    }
}
