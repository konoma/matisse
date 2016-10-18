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
    let sampleRequest = ImageRequest(url: URL(string: "test://request")!, transformations: [])
    
    
    override func setUp() {
        super.setUp()
        
        matisse = MatisseContext(fastCache: fastCache, slowCache: slowCache, requestHandler: requestHandler, syncQueue: DispatchQueue.main)
    }
    
    func test_executing_request_returns_from_fastCache() {
        // fast cache will return an image for the sample request
        fastCache.cached[sampleRequest.identifier] = sampleImage
        
        var asyncImage: UIImage?
        let syncImage = matisse.execute(request: sampleRequest) { image, error in
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
        let syncImage = matisse.execute(request: sampleRequest) { image, error in
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
        let syncImage = matisse.execute(request: sampleRequest) { image, error in
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
        let syncImage = matisse.execute(request: sampleRequest) { image, error in
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
        matisse.execute(request: sampleRequest) { image, error in }
        
        expect(self.fastCache.cached[self.sampleRequest.identifier]).toEventually(equal(sampleImage))
        expect(self.slowCache.cached[self.sampleRequest.identifier]).toEventually(equal(sampleImage))
    }
    
    func test_executing_request_with_slow_cache_will_cache_result_in_fast_cache() {
        // fast cache does not return an image for the request
        // slow cache will return an image for the sample request
        slowCache.cached[sampleRequest.identifier] = sampleImage
        
        // should give both caches a chance to store the result
        matisse.execute(request: sampleRequest) { image, error in }
        
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
        matisse.execute(request: sampleRequest) { image, error in asyncImage1 = image }
        matisse.execute(request: secondRequest) { image, error in asyncImage2 = image }
        
        expect(asyncImage1).toEventually(equal(sampleImage))
        expect(asyncImage2).toEventually(equal(sampleImage))
    }
    
    func test_executing_multiple_requests_only_caches_a_single_result() {
        // fast cache does not return an image for the request
        // slow cache does not return an image for the request
        // handler will return an image
        requestHandler.responses[self.sampleRequest.identifier] = self.sampleImage
        let secondRequest = ImageRequest(url: self.sampleRequest.url, transformations: self.sampleRequest.transformations)
        
        var done = false
        matisse.execute(request: sampleRequest) { image, error in }
        matisse.execute(request: secondRequest) { image, error in
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


class InspectableImageCache: ImageCache {
    
    var cached: [UUID: UIImage] = [:]
    
    func store(image: UIImage, forRequest request: ImageRequest, withCost cost: Int) {
        self.cached[request.identifier] = image
    }
    
    func retrieveImage(forRequest request: ImageRequest) -> UIImage? {
        return self.cached[request.identifier]
    }
}


class InspectableImageRequestHandler: ImageRequestHandler {
    
    var responses: [UUID: AnyObject] = [:]
    
    func retrieveImage(forRequest request: ImageRequest, completion: @escaping (UIImage?, NSError?) -> Void) {
        DispatchQueue.main.async {
            let response: AnyObject? = self.responses[request.identifier]
            completion(response as? UIImage, response as? NSError)
        }
    }
}
