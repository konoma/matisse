//
//  Matisse.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public final class Matisse : NSObject {
    
    private override init() {} // prevent initialization
    
    private static let context = MatisseContext()
    
    public class func load(url: NSURL) -> ImageRequest {
        return context.load(url)
    }
}
