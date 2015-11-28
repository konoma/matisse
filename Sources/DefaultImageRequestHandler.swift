//
//  DefaultImageRequestHandler.swift
//  Matisse
//
//  Created by Markus Gasser on 28.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public class DefaultImageRequestHandler: NSObject, ImageRequestHandler {
    
    private let imageLoaderQueue: ImageLoaderQueue
    private let imageCreatorQueue = ImageCreatorQueue()
    
    public init(imageLoader: ImageLoader) {
        self.imageLoaderQueue = ImageLoaderQueue(imageLoader: imageLoader)
    }
    
    public func retrieveImageForRequest(request: ImageRequest, completion: (UIImage?, NSError?) -> Void) {
        imageLoaderQueue.submitFetchRequestForURL(request.URL) { result, error in
            guard let url = result else {
                completion(nil, error)
                return
            }
            
            self.imageCreatorQueue.createImageFromURL(url, request: request) { result, error in
                DispatchQueue.main.async {
                    completion(result, error)
                }
            }
        }
    }
}
