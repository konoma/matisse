//
//  ImageTransformation.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// The `ImageTransformation` protocol describes objects that are capable of applying
/// a transformation to a `CGImage`.
///
public protocol ImageTransformation: class {

    /// Apply the transformation to the given `CGImage` and return the transformed image.
    ///
    /// - Parameters:
    ///   - image: The image to transform
    ///
    /// - Throws:
    ///   If the passed image cannot be transformed using this `ImageTransformation`.
    ///
    /// - Returns:
    ///   The transformed image.
    ///
    func transform(image: CGImage) throws -> CGImage

    /// A string describing this transformation.
    ///
    /// The descriptor must describe this transformation such that equal transformations
    /// _should_ have equal descriptions and different transformations _must_ have
    /// different descriptors. The reason for this is that requests are considered equal
    /// based in part on wether their transformations are equal. This is checked using
    /// the descriptor.
    ///
    var descriptor: String { get }
}
