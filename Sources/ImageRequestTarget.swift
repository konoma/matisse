//
//  ImageRequestTarget.swift
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// An `ImageRequestTarget` specifies an object that can display the result of an `ImageRequest`
///
/// When a request is loaded into a target (using the `showInTarget(_:)` method on `ImageRequestBuilder`)
/// the handler calls `updateForImageRequest(_:, image:, error:)` on the target with the results
/// from the completion block. The target may then decide what it does with this information.
///
/// Additionally the handler associates the target with a request to make sure that multiple
/// request don't overwrite now invalid targets. For this the request identifier is stored on
/// the target.
///
public protocol ImageRequestTarget: class {

    /// The identifier of the `ImageRequest` currently owning this target.
    ///
    /// When a request finishes it checks to see wether the request is still
    /// the owner of this target, and if not discards the results.
    ///
    var matisseRequestIdentifier: UUID? { get set }

    /// Update the target with the results of the given `ImageRequest`.
    ///
    /// - Parameters:
    ///   - imageRequest: The `ImageRequest` whose results should be displayed.
    ///   - image:        The resolved image if the request was successful, or `nil`.
    ///   - error:        The error if the request failed, or `nil`.
    ///
    func update(forImageRequest imageRequest: ImageRequest, image: UIImage?, error: NSError?)
}
