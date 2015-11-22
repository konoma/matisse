//
//  MatisseTransformation.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public protocol MatisseTransformation : NSObjectProtocol {
    
    func transformImage(image: CGImage) throws -> CGImage
}
