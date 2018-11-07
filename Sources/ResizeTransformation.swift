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

        case start
        case center
        case end
    }

    private let targetSize: CGSize
    private let contentMode: UIView.ContentMode
    private let deviceScale: CGFloat
    private let scaledTargetSize: CGSize


    // MARK: - Initialization

    /// Create a new `ResizeTransformation` with the given target size and content mode.
    ///
    /// - Parameters:
    ///   - targetSize:  The target image size.
    ///   - contentMode: The content mode describing how the image should fit into the target size.
    ///
    public convenience init(targetSize: CGSize, contentMode: UIView.ContentMode) {
        self.init(targetSize: targetSize, contentMode: contentMode, deviceScale: UIScreen.main.scale)
    }

    /// Create a new `ResizeTransformation` with the given target size and content mode.
    ///
    /// - Parameters:
    ///   - targetSize:  The target image size.
    ///   - contentMode: The content mode describing how the image should fit into the target size.
    ///   - deviceScale: The device scale which is applied to the target size.
    ///
    public init(targetSize: CGSize, contentMode: UIView.ContentMode, deviceScale: CGFloat) {
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
    public func transform(image: CGImage) throws -> CGImage {
        let bitsPerComponent = image.bitsPerComponent
        let colorSpace = image.colorSpace
        let bitmapInfo = image.bitmapInfo

        let originalSize = CGSize(width: image.width, height: image.height)

        let context = CGContext(data: nil,
            width: Int(self.scaledTargetSize.width),
            height: Int(self.scaledTargetSize.height),
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace!,
            bitmapInfo: bitmapInfo.rawValue
        )

        if context == nil {
            throw NSError.matisseCreationError("Could not resize image")
        }

        context!.interpolationQuality = .high
        context?.draw(image, in: self.calculateImageRect(withOriginalSize: originalSize))

        if let scaled = context?.makeImage() {
            return scaled
        } else {
            throw NSError.matisseCreationError("Could not resize image")
        }
    }

    private func calculateImageRect(withOriginalSize originalSize: CGSize) -> CGRect {
        // swiftlint:disable:previous cyclomatic_complexity

        switch contentMode {

        case .scaleToFill:
            return CGRect(origin: .zero, size: self.scaledTargetSize)

        case .scaleAspectFill:
            let scaledSize = self.scaledSize(forSize: originalSize, targetSize: self.scaledTargetSize, fitting: false)
            return self.rect(withSize: scaledSize, inSize: self.scaledTargetSize, xPosition: .center, yPosition: .center)

        case .scaleAspectFit:
            let scaledSize = self.scaledSize(forSize: originalSize, targetSize: self.scaledTargetSize, fitting: true)
            return self.rect(withSize: scaledSize, inSize: self.scaledTargetSize, xPosition: .center, yPosition: .center)

        case .center, .redraw:
            return self.rect(withSize: originalSize, inSize: self.scaledTargetSize, xPosition: .center, yPosition: .center)

        case .top:
            return self.rect(withSize: originalSize, inSize: self.scaledTargetSize, xPosition: .center, yPosition: .end)

        case .bottom:
            return self.rect(withSize: originalSize, inSize: self.scaledTargetSize, xPosition: .center, yPosition: .start)

        case .left:
            return self.rect(withSize: originalSize, inSize: self.scaledTargetSize, xPosition: .start, yPosition: .center)

        case .right:
            return self.rect(withSize: originalSize, inSize: self.scaledTargetSize, xPosition: .end, yPosition: .center)

        case .topLeft:
            return self.rect(withSize: originalSize, inSize: self.scaledTargetSize, xPosition: .start, yPosition: .end)

        case .topRight:
            return self.rect(withSize: originalSize, inSize: self.scaledTargetSize, xPosition: .end, yPosition: .end)

        case .bottomLeft:
            return self.rect(withSize: originalSize, inSize: self.scaledTargetSize, xPosition: .start, yPosition: .start)

        case .bottomRight:
            return self.rect(withSize: originalSize, inSize: self.scaledTargetSize, xPosition: .end, yPosition: .start)
        }
    }

    private func scaledSize(forSize size: CGSize, targetSize: CGSize, fitting: Bool) -> CGSize {
        let widthScale = size.width / targetSize.width
        let heightScale = size.height / targetSize.height
        let scale = fitting ? max(widthScale, heightScale) : min(widthScale, heightScale)

        return CGSize(width: round(size.width / scale), height: round(size.height / scale))
    }

    private func rect(withSize size: CGSize, inSize targetSize: CGSize, xPosition: AxisPosition, yPosition: AxisPosition) -> CGRect {
        let xOffset = self.axisValue(forTargetValue: targetSize.width, originalValue: size.width, position: xPosition)
        let yOffset = self.axisValue(forTargetValue: targetSize.height, originalValue: size.height, position: yPosition)

        return CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: size)
    }

    private func axisValue(forTargetValue targetValue: CGFloat, originalValue: CGFloat, position: AxisPosition) -> CGFloat {
        switch position {
        case .start:  return 0.0
        case .center: return round((targetValue - originalValue) / 2.0)
        case .end:    return targetValue - originalValue
        }
    }


    // MARK: - Describing the Transformation

    /// A string describing this transformation.
    ///
    public var descriptor: String {
        return "resize(\(self.targetSize.width),\(self.targetSize.height),\(self.deviceScale),\(self.contentMode.rawValue))"
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
    public func resizeTo(size: CGSize, contentMode: UIView.ContentMode = .scaleToFill) -> Self {
        return transform(ResizeTransformation(targetSize: size, contentMode: contentMode))
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
    public func resizeTo(width: CGFloat, height: CGFloat, contentMode: UIView.ContentMode = .scaleToFill) -> Self {
        return resizeTo(size: CGSize(width: width, height: height), contentMode: contentMode)
    }
}
