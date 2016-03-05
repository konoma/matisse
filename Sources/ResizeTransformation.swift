//
//  ResizeTransformation.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import UIKit


/// An `ImageTransformation` to resize an image.
///
public class ResizeTransformation: ImageTransformation {

    private enum AxisPosition {

        case Start
        case Center
        case End
    }

    private let targetSize: CGSize
    private let contentMode: UIViewContentMode
    private let deviceScale: CGFloat
    private let scaledTargetSize: CGSize


    // MARK: - Initialization

    /// Create a new `ResizeTransformation` with the given target size and content mode.
    ///
    /// - Parameters:
    ///   - targetSize:  The target image size.
    ///   - contentMode: The content mode describing how the image should fit into the target size.
    ///
    public convenience init(targetSize: CGSize, contentMode: UIViewContentMode) {
        self.init(targetSize: targetSize, contentMode: contentMode, deviceScale: UIScreen.mainScreen().scale)
    }

    /// Create a new `ResizeTransformation` with the given target size and content mode.
    ///
    /// - Parameters:
    ///   - targetSize:  The target image size.
    ///   - contentMode: The content mode describing how the image should fit into the target size.
    ///   - deviceScale: The device scale which is applied to the target size.
    ///
    public init(targetSize: CGSize, contentMode: UIViewContentMode, deviceScale: CGFloat) {
        self.targetSize = targetSize
        self.contentMode = contentMode
        self.deviceScale = deviceScale

        self.scaledTargetSize = CGSize(width: (targetSize.width * deviceScale), height: (targetSize.height * deviceScale))
    }


    // MARK: - Transforming the Image

    /// Resizes the image with the configured parameters.
    ///
    /// - Parameters:
    ///   - image: The image to transform
    ///
    /// - Throws:
    ///   If the image cannot be resized.
    ///
    /// - Returns:
    ///   The transformed image.
    ///
    public func transformImage(image: CGImage) throws -> CGImage {
        let bitsPerComponent = CGImageGetBitsPerComponent(image)
        let colorSpace = CGImageGetColorSpace(image)
        let bitmapInfo = CGImageGetBitmapInfo(image)

        let originalSize = CGSize(width: CGImageGetWidth(image), height: CGImageGetHeight(image))

        let context = CGBitmapContextCreate(nil,
            Int(scaledTargetSize.width),
            Int(scaledTargetSize.height),
            bitsPerComponent,
            0,
            colorSpace,
            bitmapInfo.rawValue
        )

        if context == nil {
            throw NSError.matisseCreationError("Could not resize image")
        }

        CGContextSetInterpolationQuality(context, .High)
        CGContextDrawImage(context, calculateImageRectWithOriginalSize(originalSize), image)

        if let scaled = CGBitmapContextCreateImage(context) {
            return scaled
        } else {
            throw NSError.matisseCreationError("Could not resize image")
        }
    }

    private func calculateImageRectWithOriginalSize(originalSize: CGSize) -> CGRect {
        // swiftlint:disable:previous cyclomatic_complexity

        switch contentMode {

        case .ScaleToFill:
            return CGRect(origin: .zero, size: scaledTargetSize)

        case .ScaleAspectFill:
            let scaledSize = self.scaledSizeForSize(originalSize, targetSize: scaledTargetSize, fitting: false)
            return rectWithSize(scaledSize, inSize: scaledTargetSize, xPosition: .Center, yPosition: .Center)

        case .ScaleAspectFit:
            let scaledSize = self.scaledSizeForSize(originalSize, targetSize: scaledTargetSize, fitting: true)
            return rectWithSize(scaledSize, inSize: scaledTargetSize, xPosition: .Center, yPosition: .Center)

        case .Center, .Redraw:
            return rectWithSize(originalSize, inSize: scaledTargetSize, xPosition: .Center, yPosition: .Center)

        case .Top:
            return rectWithSize(originalSize, inSize: scaledTargetSize, xPosition: .Center, yPosition: .End)

        case .Bottom:
            return rectWithSize(originalSize, inSize: scaledTargetSize, xPosition: .Center, yPosition: .Start)

        case .Left:
            return rectWithSize(originalSize, inSize: scaledTargetSize, xPosition: .Start, yPosition: .Center)

        case .Right:
            return rectWithSize(originalSize, inSize: scaledTargetSize, xPosition: .End, yPosition: .Center)

        case .TopLeft:
            return rectWithSize(originalSize, inSize: scaledTargetSize, xPosition: .Start, yPosition: .End)

        case .TopRight:
            return rectWithSize(originalSize, inSize: scaledTargetSize, xPosition: .End, yPosition: .End)

        case .BottomLeft:
            return rectWithSize(originalSize, inSize: scaledTargetSize, xPosition: .Start, yPosition: .Start)

        case .BottomRight:
            return rectWithSize(originalSize, inSize: scaledTargetSize, xPosition: .End, yPosition: .Start)
        }
    }

    private func scaledSizeForSize(size: CGSize, targetSize: CGSize, fitting: Bool) -> CGSize {
        let widthScale = size.width / targetSize.width
        let heightScale = size.height / targetSize.height
        let scale = fitting ? max(widthScale, heightScale) : min(widthScale, heightScale)

        return CGSize(width: round(size.width / scale), height: round(size.height / scale))
    }

    private func rectWithSize(size: CGSize, inSize targetSize: CGSize, xPosition: AxisPosition, yPosition: AxisPosition) -> CGRect {
        let xOffset = axisValueForTargetValue(targetSize.width, originalValue: size.width, position: xPosition)
        let yOffset = axisValueForTargetValue(targetSize.height, originalValue: size.height, position: yPosition)

        return CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: size)
    }

    private func axisValueForTargetValue(targetValue: CGFloat, originalValue: CGFloat, position: AxisPosition) -> CGFloat {
        switch position {
        case .Start:  return 0.0
        case .Center: return round((targetValue - originalValue) / 2.0)
        case .End:    return targetValue - originalValue
        }
    }


    // MARK: - Describing the Transformation

    /// A string describing this transformation.
    ///
    public var descriptor: String {
        return "resize(\(targetSize.width),\(targetSize.height),\(deviceScale),\(contentMode.rawValue))"
    }
}


public extension ImageRequestBuilder {

    /// Apply a transformation to resize the image to the given target size with the specified content mode.
    ///
    /// - Parameters:
    ///   - targetSize:  The target size to resize the image to.
    ///   - contentMode: The content mode describing how the image should fit into the target size.
    ///                  Default is `UIViewContentMode.ScaleToFill`.
    ///
    /// - Returns:
    ///   The receiver.
    ///
    public func resizeTo(targetSize: CGSize, contentMode: UIViewContentMode = .ScaleToFill) -> Self {
        return transform(ResizeTransformation(targetSize: targetSize, contentMode: contentMode))
    }

    /// Apply a transformation to resize the image to the given target size with the specified content mode.
    ///
    /// - Parameters:
    ///   - width:       The target width to resize the image to.
    ///   - height:      The target height to resize the image to.
    ///   - contentMode: The content mode describing how the image should fit into the target size.
    ///                  Default is `UIViewContentMode.ScaleToFill`.
    ///
    /// - Returns:
    ///   The receiver.
    ///
    public func resizeTo(width width: CGFloat, height: CGFloat, contentMode: UIViewContentMode = .ScaleToFill) -> Self {
        return resizeTo(CGSize(width: width, height: height), contentMode: contentMode)
    }
}
