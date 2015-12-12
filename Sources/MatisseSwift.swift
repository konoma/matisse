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


// MARK: - Request Creator


/// This class provides a fluid interface to configure an image request.
///
/// You cannot create instances of this class yourself. Instead use the `load(_:)` method on
/// a `Matisse` instance or on the class to retrieve one.
///
/// Then configure the request using the methods on the creator.
///
///     Matisse.load(exampleURL).resizeTo(width: 100.0, height: 100.0)
///
/// Finally execute the request with `fetch(completion:)` or another execution method.
///
///     Matisse.load(exampleURL).resizeTo(width: 100.0, height: 100.0).showIn(imageView)
///
/// - Note:
///   If you create custom image transformations, you should add an extension to this
///   creator. Make sure you return the creator instance so that a fluid call chain can
///   be maintained.
///
///       extension MatisseImageRequestCreator {
///
///           func circleCrop() -> ImageRequestBuilder {
///               return transform(CircleCropTransformation())
///           }
///       }
///
public class SwiftImageRequestCreator {

    private let requestBuilder: ImageRequestBuilder

    /// Create a new request creator with the given builder.
    internal init(requestBuilder: ImageRequestBuilder) {
        self.requestBuilder = requestBuilder
    }

    /// Append a transformation to this image request.
    ///
    /// This will apply the passed transformation to the image when the requested
    /// image was loaded.
    ///
    /// This method returns the receiver so you can chain calls.
    ///
    /// - Parameters:
    ///   - transformation: The `ImageTransformation` to apply to the loaded image.
    ///
    /// - Returns: The receiver
    ///
    public func transform(transformation: ImageTransformation) -> Self {
        requestBuilder.addTransformation(transformation)
        return self
    }

    /// Creates the image request and fetches it using the configured Matisse context.
    ///
    /// Downloading and preparing the image are performed in the background. After it
    /// completes, the completion handler is called.
    ///
    /// After calling this method it's not possible to modify the request further.
    ///
    /// - Parameter completion: The block to call when the image is either downloaded or
    ///                         if an error happened.
    ///
    public func fetch(completion: (ImageRequest, UIImage?, NSError?) -> Void) -> UIImage? {
        return requestBuilder.fetch(completion)
    }

    /// Fetches the image and passes it to the given `ImageRequestTarget`.
    ///
    /// This method checks wether the target is still valid after the request resolves,
    /// and discards updates if the target was associated with another request in the mean
    /// time.
    ///
    /// - Parameters:
    ///   - target: The `ImageRequestTarget` to show the image in.
    ///
    public func showIn(target: ImageRequestTarget) {
        requestBuilder.showInTarget(target)
    }

    /// Same as `showInTarget(_: ImageRequestTarget)` but repeated here because of swift limitations.
    ///
    public func showIn(imageView: UIImageView) {
        requestBuilder.showInTarget(imageView)
    }
}
