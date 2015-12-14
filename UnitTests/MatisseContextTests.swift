//
//  MatisseContextTests.swift
//  MatisseTests
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import XCTest
import Nimble

@testable import Matisse


class MatisseContextTests: XCTestCase {
    
    let fastCache = InspectableImageCache()
    let slowCache = InspectableImageCache()
    let requestHandler = InspectableImageRequestHandler()
    var matisse: MatisseContext!
    
    let sampleImage = UIImage()
    let sampleRequest = ImageRequest(url: NSURL(string: "test://request")!, transformations: [])
    
    
    override func setUp() {
        super.setUp()
        
        matisse = MatisseContext(fastCache: fastCache, slowCache: slowCache, requestHandler: requestHandler, syncQueue: dispatch_get_main_queue())
    }
    
    func test_executing_request_returns_from_fastCache() {
        // fast cache will return an image for the sample request
        fastCache.cached[sampleRequest.identifier] = sampleImage
        
        var asyncImage: UIImage?
        let syncImage = matisse.executeRequest(sampleRequest) { image, error in
            asyncImage = image
        }
        
        expect(syncImage).to(equal(sampleImage))
        expect(asyncImage).toEventually(equal(sampleImage))
    }
    
    func test_executing_request_returns_from_slowCache() {
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
    
    func test_executing_request_returns_from_handler() {
        // fast cache does not return an image for the request
        // slow cache does not return an image for the request
        // handler will return an image
        requestHandler.responses[sampleRequest.identifier] = sampleImage
        
        var asyncImage: UIImage?
        let syncImage = matisse.executeRequest(sampleRequest) { image, error in
            asyncImage = image
        }
        
        expect(syncImage).to(beNil())
        expect(asyncImage).toEventually(equal(sampleImage))
    }
    
    func test_executing_request_reports_error_from_handler() {
        // fast cache does not return an image for the request
        // slow cache does not return an image for the request
        // handler will return an error
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        requestHandler.responses[sampleRequest.identifier] = error
        
        var asyncImage: UIImage? = UIImage() // to make sure the later check to `nil` is not fooled by a default value
        var asyncError: NSError?
        let syncImage = matisse.executeRequest(sampleRequest) { image, error in
            asyncImage = image
            asyncError = error
        }
        
        expect(syncImage).to(beNil())
        expect(asyncImage).toEventually(beNil())
        expect(asyncError).toEventually(equal(error))
    }
    
    func test_executing_request_with_handler_will_cache_result() {
        // fast cache does not return an image for the request
        // slow cache does not return an image for the request
        // handler will return an image
        requestHandler.responses[sampleRequest.identifier] = sampleImage
        
        // should give both caches a chance to store the result
        matisse.executeRequest(sampleRequest) { image, error in }
        
        expect(self.fastCache.cached[self.sampleRequest.identifier]).toEventually(equal(sampleImage))
        expect(self.slowCache.cached[self.sampleRequest.identifier]).toEventually(equal(sampleImage))
    }
    
    func test_executing_request_with_slow_cache_will_cache_result_in_fast_cache() {
        // fast cache does not return an image for the request
        // slow cache will return an image for the sample request
        slowCache.cached[sampleRequest.identifier] = sampleImage
        
        // should give both caches a chance to store the result
        matisse.executeRequest(sampleRequest) { image, error in }
        
        expect(self.fastCache.cached[self.sampleRequest.identifier]).toEventually(equal(sampleImage))
    }
    
    func test_executing_multiple_requests_coalesces_when_using_handler() {
        // fast cache does not return an image for the request
        // slow cache does not return an image for the request
        // handler will return an image
        requestHandler.responses[sampleRequest.identifier] = sampleImage
        let secondRequest = ImageRequest(url: sampleRequest.url, transformations: sampleRequest.transformations)
        
        var asyncImage1: UIImage?
        var asyncImage2: UIImage?
        matisse.executeRequest(sampleRequest) { image, error in asyncImage1 = image }
        matisse.executeRequest(secondRequest) { image, error in asyncImage2 = image }
        
        expect(asyncImage1).toEventually(equal(sampleImage))
        expect(asyncImage2).toEventually(equal(sampleImage))
    }
    
    func test_executing_multiple_requests_only_caches_a_single_result() {
        // fast cache does not return an image for the request
        // slow cache does not return an image for the request
        // handler will return an image
        requestHandler.responses[sampleRequest.identifier] = sampleImage
        let secondRequest = ImageRequest(url: sampleRequest.url, transformations: sampleRequest.transformations)
        
        var done = false
        matisse.executeRequest(sampleRequest) { image, error in }
        matisse.executeRequest(secondRequest) { image, error in
            // we must check this in here because there is no way (I know of)
            // to make sure the value will _never_ be nil with expect(...)
            // when we get here, the value will already be cached
            expect(self.fastCache.cached[secondRequest.identifier]).to(beNil())
            expect(self.slowCache.cached[secondRequest.identifier]).to(beNil())
            done = true
        }
        
        expect(done).toEventually(beTrue())
    }
}


class InspectableImageCache: NSObject, ImageCache {
    
    var cached: [NSUUID: UIImage] = [:]
    
    func storeImage(image: UIImage, forRequest request: ImageRequest, withCost cost: Int) {
        cached[request.identifier] = image
    }
    
    func retrieveImageForRequest(request: ImageRequest) -> UIImage? {
        return cached[request.identifier]
    }
}


class InspectableImageRequestHandler: NSObject, ImageRequestHandler {
    
    var responses: [NSUUID: AnyObject] = [:]
    
    func retrieveImageForRequest(request: ImageRequest, completion: (UIImage?, NSError?) -> Void) {
        DispatchQueue.main.async {
            let response: AnyObject? = self.responses[request.identifier]
            completion(response as? UIImage, response as? NSError)
        }
    }
}
