//
//  ImageRequestBuilder.swift
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/**
 * ImageRequestBuilder provides a fluid interface for creating an ImageRequest.
 *
 * You create a request builder using the `load(url:)` method on a Matisse instance.
 *
 *     Matisse.load(exampleURL)
 *
 * Then configure the request using the methods on the builder.
 *
 *     Matisse.load(exampleURL).resizeTo(width: 100.0, height: 100.0)
 *
 * Finally execute the request with `fetch(completion:)` or another execution method.
 *
 *     Matisse.load(exampleURL).resizeTo(width: 100.0, height: 100.0).showIn(imageView)
 *
 * - Note:
 *   If you create custom image transformations, you should add an extension to the
 *   builder. Make sure you return the builder instance so that a fluid call chain can
 *   be maintained.
 *
 *       extension ImageRequestBuilder {
 *    
 *           func circleCrop() -> ImageRequestBuilder {
 *               return transform(CircleCropTransformation())
 *           }
 *       }
 *
 */
@objc(MTSImageRequestBuilder)
public class ImageRequestBuilder : NSObject {
    
    private let context: Matisse
    private let URL: NSURL
    private var transformations: [ImageTransformation] = []
    private var builtRequest: ImageRequest?
    
    /**
     * Create a new image request builder.
     *
     * You don't need to create a builder yourself usually. Instead use the `load(url:)`
     * method on a `Matisse` instance.
     *
     * - Parameter context: The Matisse instance to execute the built request in.
     * - Paramter URL: The source URL of the image to fetch.
     */
    public init(context: Matisse, URL: NSURL) {
        self.context = context
        self.URL = URL
    }
    
    
    // MARK: - Configuring and Building the Request
    
    /**
     * Add a new image transformation to the request.
     * 
     * Transformations will be applied in the order they are added to the request.
     *
     * - Note: You cannot modify the request after it was first accessed.
     *
     * - Parameter transformation: The transformation to apply to the downloaded image.
     * - Returns: The receiver
     */
    public func transform(transformation: ImageTransformation) -> ImageRequestBuilder {
        checkNotYetBuilt()
        
        transformations.append(transformation)
        return self
    }
    
    /**
     * The image request created by this builder.
     *
     * If accessed for the first time it creates the image request using the current
     * configuration options. After calling this method it's not possible to modify
     * the request further.
     */
    public var imageRequest: ImageRequest {
        if let request = builtRequest {
            return request
        }
        
        let request = ImageRequest(URL: URL, transformations: transformations)
        builtRequest = request
        return request
    }
    
    
    // MARK: - Executing the Request
    
    /**
     * Creates the image request and fetches it using the configured Matisse context.
     *
     * Downloading and preparing the image are performed in the background. After it
     * completes, the completion handler is called.
     *
     * After calling this method it's not possible to modify the request further.
     *
     * - Parameter completion: The block to call when the image is either downloaded or
     *                         if an error happened.
     */
    public func fetch(completion: (ImageRequest, UIImage?, NSError?) -> Void) {
        let request = imageRequest
        context.executeRequest(request) { image, error in
            completion(request, image, error)
        }
    }
    
    
    // MARK: - Helper
    
    private func checkNotYetBuilt() {
        assert(builtRequest == nil, "Cannot modify the request because it was already built")
    }
}


// MARK: - Convenience Initialization

public extension Matisse {
    
    /**
     * Create a new ImageRequest for the given URL on the shared Matisse instance.
     *
     * - Parameter url: The URL to load the image from.
     *
     * - Returns: an ImageRequestBuilder conifgured for the given URL.
     */
    public class func load(url: NSURL) -> ImageRequestBuilder {
        return sharedInstance().load(url)
    }
    
    /**
     * Create a new ImageRequest for the given URL.
     *
     * - Parameter url: The URL to load the image from.
     *
     * - Returns: an ImageRequestBuilder conifgured for the given URL.
     */
    public func load(url: NSURL) -> ImageRequestBuilder {
        return ImageRequestBuilder(context: self, URL: url)
    }
}


// MARK: - Support for UIImageView

public extension ImageRequestBuilder {
    
    /**
     * Fetch the image for this request and show it in the given image view.
     *
     * This method associates the given image view with the request. If this
     * association is changed before the request completes, then the result
     * of the fetch is discarded. This way this method can be used i.e. in a
     * UITableViewDataSource implementation without additional checks.
     *
     * - Parameter imageView: The UIImageView to display the image in
     */
    public func showIn(imageView: UIImageView) {
        imageView.matisseRequestIdentifier = imageRequest.identifier
        
        fetch { request, image, error in
            if imageView.matisseRequestIdentifier == request.identifier {
                imageView.image = image
                imageView.matisseRequestIdentifier = nil
            }
        }
    }
}

public extension UIImageView {
    
    private static var requestIdentifierKey: Int = 0
    
    /// The identifier of an ImageRequest associated with this image view.
    public var matisseRequestIdentifier: NSUUID? {
        get { return objc_getAssociatedObject(self, &UIImageView.requestIdentifierKey) as? NSUUID }
        set { objc_setAssociatedObject(self, &UIImageView.requestIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
