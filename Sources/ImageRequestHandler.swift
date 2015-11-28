//
//  ImageRequestHandler.swift
//  Matisse
//
//  Created by Markus Gasser on 28.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


@objc(MTSImageRequestHandler)
public protocol ImageRequestHandler: NSObjectProtocol {
    
    func retrieveImageForRequest(request: ImageRequest, completion: (UIImage?, NSError?) -> Void)
}
