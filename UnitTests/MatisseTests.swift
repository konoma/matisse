//
//  MatisseTests.swift
//  MatisseTests
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import XCTest
import Nimble

@testable import Matisse


class MatisseTests: XCTestCase {
    
    let fastCache = InspectableImageCache()
    let slowCache = InspectableImageCache()
    var matisse: Matisse!
    
    let sampleImage = UIImage()
    let sampleRequest = ImageRequest(URL: NSURL(string: "test://request")!, transformations: [])
    
    
    override func setUp() {
        super.setUp()
        
        matisse = Matisse(fastCache: fastCache, slowCache: slowCache, imageLoader: DefaultImageLoader())
    }
    
    func test_executing_request_returns_from_fastCache_if_possible() {
        // fast cache will return an image for the sample request
        fastCache.cached[sampleRequest.identifier] = sampleImage
        
        var asyncImage: UIImage?
        let syncImage = matisse.executeRequest(sampleRequest) { image, error in
            asyncImage = image
        }
        
        expect(syncImage).to(equal(sampleImage))
        expect(asyncImage).toEventually(equal(sampleImage))
    }
    
    func test_executing_request_returns_from_slowCache_if_possible() {
        // fast cache does not return an image for the request
        // slow cache will return an image for the sample request
        slowCache.cached[sampleRequest.identifier] = sampleImage
        
        var asyncImage: UIImage?
        let syncImage = matisse.executeRequest(sampleRequest) { image, error in
            asyncImage = image
        }
        
        expect(syncImage).to(beNil())
        expect(asyncImage).toEventually(equal(sampleImage))
    }
}


@objc
class InspectableImageCache: NSObject, ImageCache {
    
    var cached: [NSUUID: UIImage] = [:]
    var stored: [(image: UIImage, request: ImageRequest, cost: Int)] = []
    var retrieved: [ImageRequest] = []
    
    func storeImage(image: UIImage, forRequest request: ImageRequest, withCost cost: Int) {
        stored.append((image, request, cost))
    }
    
    func retrieveImageForRequest(request: ImageRequest) -> UIImage? {
        retrieved.append(request)
        return cached[request.identifier]
    }
}
