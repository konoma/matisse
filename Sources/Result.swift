//
//  Result.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public class Result<T> {
    
    public let value: T?
    public let error: ErrorType?
    
    
    // MARK: - Initialization
    
    public class func success(value: T) -> Result {
        return Result(value: value, error: nil)
    }
    
    public class func error(error: ErrorType) -> Result {
        return Result(value: nil, error: error)
    }
    
    private init(value: T?, error: ErrorType?) {
        self.value = value
        self.error = error
    }
    
    
    // MARK: - Helpers
    
    public var success: Bool {
        return (value != nil)
    }
}
