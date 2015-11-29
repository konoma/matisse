//
//  MatisseErrors.swift
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


public let MatisseErrorDomain: String = "MatisseErrorDomain"

public enum MatisseErrorCode: Int {
    
    case Unknown = 0
    case DownloadError = 1
    case CreationError = 2
}

public extension NSError {
    
    public var isMatisseError: Bool {
        return domain == MatisseErrorDomain
    }
    
    public var matisseErrorCode: MatisseErrorCode {
        return isMatisseError ? (MatisseErrorCode(rawValue: code) ?? .Unknown) : .Unknown
    }
    
    public class func matisseUnknownError(message: String? = nil) -> NSError {
        return matisseErrorWithCode(.Unknown, message: message)
    }
    
    public class func matisseDownloadError(message: String? = nil) -> NSError {
        return matisseErrorWithCode(.DownloadError, message: message)
    }
    
    public class func matisseCreationError(message: String? = nil) -> NSError {
        return matisseErrorWithCode(.CreationError, message: message)
    }
    
    public class func matisseErrorWithCode(code: MatisseErrorCode, message: String? = nil) -> NSError {
        let userInfo: [String: AnyObject]
        
        if let message = message {
            userInfo = [ NSLocalizedDescriptionKey: message ]
        } else {
            userInfo = [:]
        }
        
        return NSError(domain: MatisseErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}