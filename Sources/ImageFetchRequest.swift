//
//  ImageFetchRequest.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


internal class ImageFetchRequest {
    
    let URL: NSURL
    var completionHandlers: [ImageLoaderQueue.FetchResultHandler]
    
    
    // MARK: - Initialization
    
    init(URL: NSURL, completion: ImageLoaderQueue.FetchResultHandler) {
        self.URL = URL
        self.completionHandlers = [ completion ]
    }
    
    
    // MARK: - Notification
    
    func notifyResult(result: NSURL?, error: NSError?) {
        for handler in completionHandlers {
            handler(result, error)
        }
    }
}
