//
//  MatisseContext.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public class MatisseContext : NSObject {
    
    // MARK: - Public API
    
    public func load(url: NSURL) -> ImageRequest {
        return ImageRequest(context: self, url: url)
    }
    
    
    // MARK: - Internals
    
    internal func submitRequest(request: ImageRequest) {
        let urlRequest = NSURLRequest(URL: request.url)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { response, data, error in
            if let imageData = data, image = UIImage(data: imageData) {
                request.notifyResult(Result.success(image))
            } else {
                request.notifyResult(Result.error(error ?? NSError(domain: "", code: 0, userInfo: nil)))
            }
        }
    }
}