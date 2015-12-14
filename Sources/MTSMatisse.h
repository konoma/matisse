//
//  MTSMatisse.h
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MTSMatisseContext;
@class MTSObjcImageRequestCreator;
@protocol MTSImageRequestHandler;
@protocol MTSImageCache;


/// The Objective-C Matisse DSL class
///
/// You use this class to create Matisse image requests with a fluid interface. For normal usage you can
/// simply use the class methods.
///
/// Example:
///
///     [MTSMatisse load:imageURL].showIn(myImageView);
///
///
/// If you need more than one Matisse DSL object you can create them by passing a context in by hand.
///
/// Example:
///
///     MTSMatisse *customMatisse = [[MTSMatisse alloc] initWithContext:preconfiguredContext];
///
///     customMatisse.load(imageURL).showIn(myImageView)
///
@interface MTSMatisse : NSObject

#pragma mark - Initialization

/// Create a custom instance of the Matisse DSL class.
///
/// If for some reason you need to have multiple different Matisse DSL objects you can create
/// new ones by passing a configured `MTSMatisseContext` to this initializer.
///
/// - Parameters:
///   - context: The `MTSMatisseContext` to use for this DSL instance.
///
- (instancetype)initWithContext:(MTSMatisseContext *)context;

@property (nonatomic, readonly) MTSMatisseContext *context;


#pragma mark - Creating Requests

/// Start a new image request for the given URL.
///
/// - Parameters:
///   - url: The URL to load the image from.
///
/// - Returns:
///   An image request creator configured for the given URL.
///
- (MTSObjcImageRequestCreator *)load:(NSURL *)url;


#pragma mark - Shared Matisse Instance - Configuration

/// Use a different fast cache for the shared Matisse instance.
///
/// - Note:
///   This method must only be called before using the shared Matisse instance
///   for the first time.
///
/// - Parameters:
///   - cache: The cache to use, or `nil` to disable the fast cache
///
+ (void)useFastCache:(id<MTSImageCache>)cache;

/// Use a different slow cache for the shared Matisse instance.
///
/// - Note:
///   This method must only be called before using the shared Matisse instance
///   for the first time.
///
/// - Parameters:
///   - cache: The cache to use, or `nil` to disable the slow cache
///
+ (void)useSlowCache:(id<MTSImageCache>)cache;

/// Use a different request handler for the shared Matisse instance.
///
/// - Note:
///   This method must only be called before using the shared Matisse instance
///   for the first time.
///
/// - Parameters:
///   - requestHandler: The request handler to use
///
+ (void)useRequestHandler:(id<MTSImageRequestHandler>)requestHandler;

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
+ (instancetype)shared;


#pragma mark - Shared Matisse Instance - Creating Requests

/// Start a new image request for the given URL using the shared Matisse instance.
///
/// - Parameters:
///   - url: The URL to load the image from.
///
/// - Returns: An image request creator configured for the given URL.
///
+ (MTSObjcImageRequestCreator *)load:(NSURL *)url;

@end
