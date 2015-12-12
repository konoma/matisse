//
//  ImageRequestTarget.swift
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation



@objc(MTSImageRequestTarget)
public protocol ImageRequestTarget: NSObjectProtocol {

    var matisseRequestIdentifier: NSUUID? { get set }

    func updateForImageRequest(imageRequest: ImageRequest, image: UIImage?, error: NSError?)
}
