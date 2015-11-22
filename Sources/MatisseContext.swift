//
//  MatisseContext.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public class MatisseContext : NSObject {
    
    private let imageLoaderQueue = ImageLoaderQueue(imageLoader: DefaultImageLoader())
    
    
    // MARK: - Loading Images
    
    public func load(url: NSURL) -> MatisseRequest {
        return MatisseRequest(context: self, URL: url)
    }
    
    
    // MARK: - Internals
    
    internal func submitRequest(request: MatisseRequest) {
        imageLoaderQueue.submitFetchRequestForURL(request.URL) { result in
            if let url = result.value, path = url.path, image = UIImage(contentsOfFile: path) {
                request.notifyResult(Result.success(image))
            } else {
                request.notifyResult(Result.error(result.error ?? NSError(domain: "", code: 0, userInfo: nil)))
            }
        }
    }
}