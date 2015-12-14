//
//  ResizeTransformation+DSL.h
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import <Matisse/MTSObjcImageRequestCreator.h>


@interface MTSObjcImageRequestCreator (ResizeTransformation)

/// Apply a transformation to resize the image to the given target size with the specified content mode.
///
/// Use like this: `<creator>.resizeTo(CGSizeMake(100.0f, 100.0f), UIViewContentModeScaleAspectFit)`
///
/// - Parameters:
///   - targetSize:  The target size to resize the image to.
///   - contentMode: The content mode describing how the image should fit into the target size.
///
/// - Returns:
///   The receiver.
///
MTS_DECLARE_CREATOR_METHOD(resizeTo, CGSize size, UIViewContentMode contentMode);

@end
