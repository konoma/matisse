//
//  MTSObjcImageRequestCreator.h
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MTSImageRequest;
@protocol MTSImageTransformation;
@protocol MTSImageRequestTarget;


// Helper macros to delcare a creator method.
//
// Defines a property with the given name that returns a block which returns the MTSObjcImageRequestCreator instance.
//
// Use like this:
//
//     MTS_DECLARE_CREATOR_METHOD(circleCrop, CGFloat radius);
//     MTS_DECLARE_CREATOR_METHOD(somethingElse, void);
//     MTS_DECLARE_CREATOR_METHOD(multiParam, NSUInteger foo, CGFloat bar);
//
// And to implement it:
//
//     MTS_IMPLEMENT_CREATOR_METHOD(circleCrop, ^(CGFloat radius) {
//         return self.transform([[CircleCropTransform alloc] init]);
//     })
//
#define MTS_DECLARE_CREATOR_METHOD(NAME, ...) MTS_DECLARE_CREATOR_METHOD_TYPED(MTSObjcImageRequestCreator*, NAME, ##__VA_ARGS__)
#define MTS_DECLARE_CREATOR_METHOD_TYPED(RETURN_TYPE, NAME, ...) @property (nonatomic, readonly) RETURN_TYPE(^NAME)(__VA_ARGS__)
#define MTS_IMPLEMENT_CREATOR_METHOD(NAME, BLOCK_IMPL) - (typeof(((MTSObjcImageRequestCreator*)nil).NAME))NAME { return BLOCK_IMPL; }


/// This class provides a fluid interface to configure an image request.
///
/// You cannot create instances of this class yourself. Instead use the `-[MTSMatisse load:]`
/// or `+[MTSMatisse load:]` method to retrieve one.
///
/// Then configure the request using the methods on the creator.
///
///     [MTSMatisse load:url].resizeTo(width: 100.0, height: 100.0)
///
/// Finally execute the request with `fetch(completion:)` or another execution method.
///
///     [MTSMatisse load:url].resizeTo(width: 100.0, height: 100.0).showIn(imageView)
///
/// If you create custom image transformations, you should add an extension to this
/// creator. Make sure you return the creator instance so that a fluid call chain can
/// be maintained. You can use the provided helper macros to support you.
///
///     // in your .h file:
///
///     @interface MTSObjcImageRequestCreator (CircleCrop)
///
///     MTS_DECLARE_CREATOR_METHOD(circleCrop, void);
///
///     @end
///
///     // in your .m file:
///
///     @implementation MTSObjcImageRequestCreator (CircleCrop)
///
///     MTS_IMPLEMENT_CREATOR_METHOD(circleCrop, ^(void) {
///         return self.transform([[CircleCropTransformation alloc] init]);
///     })
///
///     @end
///
@interface MTSObjcImageRequestCreator : NSObject

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
MTS_DECLARE_CREATOR_METHOD(transform, id<MTSImageTransformation> transformation);

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
MTS_DECLARE_CREATOR_METHOD_TYPED(UIImage*, fetch, void(^completion)(MTSImageRequest*, UIImage*, NSError*));

/// Fetches the image and passes it to the given `MTSImageRequestTarget`.
///
/// This method checks wether the target is still valid after the request resolves,
/// and discards updates if the target was associated with another request in the mean
/// time.
///
/// - Parameters:
///   - target: The `MTSImageRequestTarget` to show the image in.
///
MTS_DECLARE_CREATOR_METHOD_TYPED(void, showInTarget, id<MTSImageRequestTarget> target);

/// Same as `showInTarget(id<MTSImageRequestTarget>)` but repeated here because of swift limitations.
///
MTS_DECLARE_CREATOR_METHOD_TYPED(void, showIn, UIImageView *imageView);

@end
