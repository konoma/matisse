//
//  MatisseErrors.swift
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// Matisse error codes
///
public enum MatisseErrorCode: Int {

    /// An unknown error happened.
    case unknown = 0

    /// An error downloading the image happened.
    case downloadError = 1

    /// An error creating or resizing the image happened.
    case creationError = 2
}


public extension NSError {

    // MARK: - Constants

    /// The `NSError` error domain for Matisse errors.
    ///
    public static var MatisseErrorDomain: String { return "MatisseErrorDomain" }


    // MARK: - Error Information

    /// Tests wether this error is a Matisse error or not.
    ///
    /// Determined by checking the domain for `MatisseErrorDomain`.
    ///
    public var isMatisseError: Bool {
        return domain == NSError.MatisseErrorDomain
    }

    /// The matisse error code for this error.
    ///
    /// If the receiver is not a matisse error, returns `MatisseErrorCode.Unknown`.
    ///
    public var matisseErrorCode: MatisseErrorCode {
        return isMatisseError ? (MatisseErrorCode(rawValue: code) ?? .unknown) : .unknown
    }


    // MARK: - Creating Matisse Errors

    /// Create a new matisse error with code `MatisseErrorCode.Unknown`.
    ///
    /// - Parameters:
    ///   - message: The message for this error. Optional.
    ///
    /// - Returns:
    ///   A new `NSError` instance with the Matisse error domain and the unknown error code.
    ///
    public class func matisseUnknownError(_ message: String? = nil) -> NSError {
        return matisseErrorWithCode(.unknown, message: message)
    }

    /// Create a new matisse error with code `MatisseErrorCode.DownloadError`.
    ///
    /// - Parameters:
    ///   - message: The message for this error. Optional.
    ///
    /// - Returns:
    ///   A new `NSError` instance with the Matisse error domain and the download error code.
    ///
    public class func matisseDownloadError(_ message: String? = nil) -> NSError {
        return matisseErrorWithCode(.downloadError, message: message)
    }

    /// Create a new matisse error with code `MatisseErrorCode.CreationError`.
    ///
    /// - Parameters:
    ///   - message: The message for this error. Optional.
    ///
    /// - Returns:
    ///   A new `NSError` instance with the Matisse error domain and the creation error code.
    ///
    public class func matisseCreationError(_ message: String? = nil) -> NSError {
        return matisseErrorWithCode(.creationError, message: message)
    }

    /// Create a new matisse error with the given code.
    ///
    /// - Parameters:
    ///   - code:    The matisse error code.
    ///   - message: The message for this error. Optional.
    ///
    /// - Returns:
    ///   A new `NSError` instance with the Matisse error domain and the specified error code.
    ///
    public class func matisseErrorWithCode(_ code: MatisseErrorCode, message: String? = nil) -> NSError {
        let userInfo: [String: AnyObject]

        if let message = message {
            userInfo = [ NSLocalizedDescriptionKey: message as AnyObject ]
        } else {
            userInfo = [:]
        }

        return NSError(domain: MatisseErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}
