//
//  Matisse+UIImageView.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public extension ImageRequest {
    
    public func into(imageView: UIImageView) {
        execute { result in
            imageView.image = result.value
        }
    }
}
