//
//  DefaultImageRequestHandler.swift
//  Matisse
//
//  Created by Markus Gasser on 28.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public class DefaultImageRequestHandler: NSObject, ImageRequestHandler {
    
    private let imageLoader: ImageLoader
    private let imageCreator: ImageCreator
    private let workerQueue: DispatchQueue
    
    public init(
        imageLoader: ImageLoader,
        imageCreator: ImageCreator = ImageCreator(),
        workerQueue: dispatch_queue_t = dispatch_queue_create("ch.konoma.matisse/creatorQueue", DISPATCH_QUEUE_CONCURRENT))
    {
        self.imageLoader = imageLoader
        self.imageCreator = imageCreator
        self.workerQueue = DispatchQueue(dispatchQueue: workerQueue)
    }
    
    public func retrieveImageForRequest(request: ImageRequest, completion: (UIImage?, NSError?) -> Void) {
        imageLoader.loadImageForRequest(request) { url, error in
            guard let url = url else {
                completion(nil, error)
                return
            }
            
            self.createImageFromURL(url, request: request, completion: completion)
        }
    }
    
    private func createImageFromURL(url: NSURL, request: ImageRequest, completion: (UIImage?, NSError?) -> Void) {
        workerQueue.async {
            do {
                let image = try self.imageCreator.createImageFromURL(url, request: request)
                completion(image, nil)
            } catch {
                completion(nil, error as NSError)
            }
        }
    }
}
