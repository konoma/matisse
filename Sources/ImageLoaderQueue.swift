//
//  ImageLoaderQueue.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


internal class ImageLoaderQueue {
    
    typealias FetchResultHandler = (Result<NSURL>) -> Void
    
    private let imageLoader: MatisseImageLoader
    private let dispatchQueue: DispatchQueue
    private var queuedFetchRequests: [NSURL: ImageFetchRequest] = [:]
    
    
    // MARK: - Initialization
    
    init(imageLoader: MatisseImageLoader) {
        self.imageLoader = imageLoader
        self.dispatchQueue = DispatchQueue(label: "ch.konoma.matisse/imageLoaderQueue", type: .Serial)
    }
    
    
    // MARK: - Submitting Requests
    
    func submitFetchRequestForURL(url: NSURL, completion: FetchResultHandler) {
        dispatchQueue.async {
            if let existingRequest = self.queuedFetchRequests[url] {
                existingRequest.completionHandlers.append(completion)
            } else {
                let fetchRequest = ImageFetchRequest(URL: url, completion: completion)
                self.queuedFetchRequests[url] = fetchRequest
                self.startFetchRequest(fetchRequest)
            }
        }
    }
    
    private func startFetchRequest(fetchRequest: ImageFetchRequest) {
        let destinationURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(NSUUID().UUIDString)
        
        imageLoader.loadImageForURL(fetchRequest.URL, toURL: destinationURL) { result in
            self.dispatchQueue.async {
                self.queuedFetchRequests[fetchRequest.URL] = nil
                
                DispatchQueue.main.async {
                    fetchRequest.notifyResult(result)
                }
            }
        }
    }
}
