//
//  DefaultImageLoader.swift
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


@objc(MTSDefaultImageLoader)
public class DefaultImageLoader : ImageLoaderBase {
    
    private let urlSession: NSURLSession
    
    public init(urlSession: NSURLSession, fileManager: NSFileManager) {
        self.urlSession = urlSession
        
        super.init(fileManager: fileManager)
    }
    
    public convenience init() {
        self.init(urlSession: NSURLSession.sharedSession(), fileManager: NSFileManager())
    }
    
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
