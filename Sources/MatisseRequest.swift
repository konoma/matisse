//
//  MatisseRequest.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public class MatisseRequest : NSObject {
    
    private weak var context: MatisseContext?
    private var completion: (Result<UIImage> -> Void)?
    private var submitted: Bool = false
    
    public let identifier: NSUUID
    public let URL: NSURL
    internal var transformations: [MatisseTransformation] = []
    
    
    // MARK: - Initialization
    
    internal init(context: MatisseContext, URL: NSURL) {
        self.context = context
        self.identifier = NSUUID()
        self.URL = URL
    }
    
    
    // MARK: - Configuration
    
    public func addTransformation(transformation: MatisseTransformation) -> MatisseRequest {
        checkIsMainThread()
        checkNotYetSubmitted()
        
        transformations.append(transformation)
        return self
    }
    
    
    // MARK: - Executing the Request
    
    public func execute(completion compl: Result<UIImage> -> Void) {
        checkIsMainThread()
        checkNotYetSubmitted()
        
        completion = compl
        context?.submitRequest(self)
        
        submitted = true
        context = nil
    }
    
    internal func notifyResult(result: Result<UIImage>) {
        checkIsMainThread()
        
        assert(completion != nil, "Cannot notify a result twice or before ")
        
        completion?(result)
        completion = nil // make sure we're not holding a strong reference that may lead to a retain cycle
    }
    
    
    // MARK: - Helpers
    
    private func checkNotYetSubmitted() {
        assert(!submitted, "This ImageRequest was already submitted and cannot be modified or executed anymore")
    }
    
    private func checkIsMainThread() {
        assert(NSThread.isMainThread(), "Must be called on the main thread")
    }
}