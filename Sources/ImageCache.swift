//
//  ImageCache.swift
//  Matisse
//
//  Created by Markus Gasser on 28.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


@objc(MTSCache)
public protocol ImageCache: NSObjectProtocol {
    
    func storeImage(image: UIImage, forRequest request: ImageRequest, withCost cost: Int)
    
    func retrieveImageForRequest(request: ImageRequest) -> UIImage?
}
