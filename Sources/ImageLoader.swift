//
//  MatisseImageLoader.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//


import Foundation


@objc(MTSImageLoader)
public protocol ImageLoader : NSObjectProtocol {
    
    func loadImageForURL(url: NSURL, toURL destinationURL: NSURL, completion: (NSURL?, NSError?) -> Void)
}


@objc(MTSDefaultImageLoader)
public class DefaultImageLoader : NSObject, ImageLoader {
    
    private let urlSession: NSURLSession
    private let fileManager: NSFileManager
    
    public init(urlSession: NSURLSession, fileManager: NSFileManager) {
        self.urlSession = urlSession
        self.fileManager = fileManager
    }
    
    override public convenience init() {
        self.init(urlSession: NSURLSession.sharedSession(), fileManager: NSFileManager())
    }
    
    public func loadImageForURL(url: NSURL, toURL destinationURL: NSURL, completion: (NSURL?, NSError?) -> Void) {
        let task = urlSession.downloadTaskWithRequest(NSURLRequest(URL: url)) { temporaryURL, response, error in
            guard let temporaryURL = temporaryURL else {
                completion(nil, error)
                return
            }
            
            do {
                try self.fileManager.moveItemAtURL(temporaryURL, toURL: destinationURL)
                completion(destinationURL, nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
        task.resume()
    }
}
