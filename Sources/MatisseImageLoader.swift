//
//  MatisseImageLoader.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//


import Foundation


public protocol MatisseImageLoader : NSObjectProtocol {
    
    func loadImageForURL(url: NSURL, toURL destinationURL: NSURL, completion: Result<NSURL> -> Void)
}


public class DefaultImageLoader : NSObject, MatisseImageLoader {
    
    private let urlSession: NSURLSession
    private let fileManager: NSFileManager
    
    public init(urlSession: NSURLSession = NSURLSession.sharedSession(), fileManager: NSFileManager = NSFileManager()) {
        self.urlSession = urlSession
        self.fileManager = fileManager
    }
    
    public func loadImageForURL(url: NSURL, toURL destinationURL: NSURL, completion: Result<NSURL> -> Void) {
        let task = urlSession.downloadTaskWithRequest(NSURLRequest(URL: url)) { temporaryURL, response, error in
            guard let temporaryURL = temporaryURL else {
                completion(Result.error(error ?? NSError(domain: "", code: 0, userInfo: nil)))
                return
            }
            
            do {
                try self.fileManager.moveItemAtURL(temporaryURL, toURL: destinationURL)
                completion(Result.success(destinationURL))
            } catch {
                completion(Result.error(error))
            }
        }
        task.resume()
    }
}
