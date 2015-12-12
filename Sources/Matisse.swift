//
//  Matisse.swift
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


// MARK: - Matisse DSL

/// The Swift Matisse DSL class
///
/// You use this class to create Matisse image requests with a fluid interface. For normal usage you can
/// simply use the class methods.
///
/// Example:
///
///     Matisse.load(imageURL).showIn(myImageView)
///
///
/// If you need more than one Matisse DSL object you can create them by passing a context in by hand.
///
/// Example:
///
///     let customMatisse = Matisse(context: preconfiguredContext)
///
///     customMatisse.load(imageURL).showIn(myImageView)
///
public class Matisse {

    // MARK: - Initialization

    /// The internal MatisseContext that handles image requests
    private let context: MatisseContext

    /// Create a custom instance of the Matisse DSL class.
    ///
    /// If for some reason you need to have multiple different Matisse DSL objects you can create
    /// new ones by passing a configured `MatisseContext` to this initializer.
    ///
    /// - Parameters:
    ///   - context: The `MatisseContext` to use for this DSL instance.
    ///
    public init(context: MatisseContext) {
        self.context = context
    }


    // MARK: - Creating Requests

    /// Start a new image request for the given URL.
    ///
    /// - Parameters:
    ///   - url: The URL to load the image from.
    ///
    /// - Returns: An image request creator configured for the given URL.
    ///
    public func load(url: NSURL) -> SwiftImageRequestCreator {
        let requestBuilder = ImageRequestBuilder(context: self.context, url: url)
        return SwiftImageRequestCreator(requestBuilder: requestBuilder)
    }


    // MARK: - Shared Matisse Instance - Configuration

    private static var _sharedInstance: Matisse?
    private static var _fastCache: ImageCache? = MemoryImageCache()
    private static var _slowCache: ImageCache? = DiskImageCache()
    private static var _requestHandler: ImageRequestHandler = DefaultImageRequestHandler(imageLoader: DefaultImageLoader())


    /// Use a different fast cache for the shared Matisse instance.
    ///
    /// - Note:
    ///   This method must only be called before using the shared Matisse instance
    ///   for the first time.
    ///
    /// - Parameters:
    ///   - cache: The cache to use, or `nil` to disable the fast cache
    ///
    public class func useFastCache(cache: ImageCache?) {
        checkMainThread()
        checkUnused()

        _fastCache = cache
    }

    /// Use a different slow cache for the shared Matisse instance.
    ///
    /// - Note:
    ///   This method must only be called before using the shared Matisse instance
    ///   for the first time.
    ///
    /// - Parameters:
    ///   - cache: The cache to use, or `nil` to disable the slow cache
    ///
    public class func useSlowCache(cache: ImageCache?) {
        checkMainThread()
        checkUnused()

        _slowCache = cache
    }

    /// Use a different request handler for the shared Matisse instance.
    ///
    /// - Note:
    ///   This method must only be called before using the shared Matisse instance
    ///   for the first time.
    ///
    /// - Parameters:
    ///   - requestHandler: The request handler to use
    ///
    public class func useRequestHandler(requestHandler: ImageRequestHandler) {
        checkMainThread()
        checkUnused()

        _requestHandler = requestHandler
    }

    /// Access the shared Matisse instance.
    ///
    /// When first accessed the instance is built using the current configuration.
    /// Afterwards it's not possible to change this instance anymore.
    ///
    /// Usually you don't need to access the shared instance directly, instead
    /// you can use the `load()` class func which will in turn access this instance.
    ///
    /// - Returns: The shared Matisse instance
    ///
    public class func shared() -> Matisse {
        checkMainThread()

        if _sharedInstance == nil {
            let context = MatisseContext(fastCache: _fastCache, slowCache: _slowCache, requestHandler: _requestHandler)
            _sharedInstance = Matisse(context: context)
        }
        return _sharedInstance!
    }


    // MARK: - Shared Matisse Instance - Creating Requests

    /// Start a new image request for the given URL using the shared Matisse instance.
    ///
    /// - Parameters:
    ///   - url: The URL to load the image from.
    ///
    /// - Returns: An image request creator configured for the given URL.
    ///
    public class func load(url: NSURL) -> SwiftImageRequestCreator {
        return shared().load(url)
    }


    // MARK: - Helpers

    /// Checks wether the shared instance was already built
    private class func checkUnused() {
        assert(_sharedInstance == nil, "You cannot modify the shared Matisse instance after it was first used")
    }

    /// Checks that all access is done on the main thread
    private class func checkMainThread() {
        assert(NSThread.isMainThread(), "You must access Matisse from the main thread")
    }
}
