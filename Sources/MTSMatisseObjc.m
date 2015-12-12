//
//  MTSMatisseObjc.m
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import "MTSMatisseObjc.h"

#import <Matisse/Matisse-Swift.h>


@interface MTSObjcImageRequestCreator ()

- (instancetype)initWithRequestBuilder:(MTSImageRequestBuilder *)builder;

@property (nonatomic, readonly) MTSImageRequestBuilder *requestBuilder;

@end


@implementation MTSMatisse

#pragma mark - Initialization

- (instancetype)initWithContext:(MTSMatisseContext *)context {
    NSParameterAssert(context != nil);
    
    if ((self = [super init])) {
        _context = context;
    }
    return self;
}


#pragma mark - Creating Requests

- (MTSObjcImageRequestCreator *)load:(NSURL *)url {
    MTSImageRequestBuilder *builder = [[MTSImageRequestBuilder alloc] initWithContext:self.context URL:url];
    return [[MTSObjcImageRequestCreator alloc] initWithRequestBuilder:builder];
}


#pragma mark - Shared Matisse Instance - Configuration

static MTSMatisse *_sharedInstance;
static id<MTSImageCache> _fastCache;
static id<MTSImageCache> _slowCache;
static id<MTSImageRequestHandler> _requestHandler;

+ (void)initialize {
    if (self != [MTSMatisse class]) {
        return;
    }
    
    _fastCache = [[MTSMemoryImageCache alloc] init];
    _slowCache = [[MTSDiskImageCache alloc] init];
    _requestHandler = [[MTSDefaultImageRequestHandler alloc] initWithImageLoader:[[MTSDefaultImageLoader alloc] init]];
}

+ (void)useFastCache:(id<MTSImageCache>)cache {
    [self checkMainThread];
    [self checkUnused];
    
    _fastCache = cache;
}

+ (void)useSlowCache:(id<MTSImageCache>)cache {
    [self checkMainThread];
    [self checkUnused];
    
    _slowCache = cache;
}

+ (void)useRequestHandler:(id<MTSImageRequestHandler>)requestHandler {
    NSParameterAssert(requestHandler != nil);
    
    [self checkMainThread];
    [self checkUnused];
    
    _requestHandler = requestHandler;
}

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MTSMatisseContext *context = [[MTSMatisseContext alloc] initWithFastCache:_fastCache slowCache:_slowCache requestHandler:_requestHandler];
        _sharedInstance = [[MTSMatisse alloc] initWithContext:context];
    });
    
    return _sharedInstance;
}

+ (MTSObjcImageRequestCreator *)load:(NSURL *)url {
    return [[self shared] load:url];
}


#pragma mark - Helpers

+ (void)checkUnused {
    NSAssert(_sharedInstance == nil, @"You cannot modify the shared Matisse instance after it was first used");
}


+ (void)checkMainThread {
    NSAssert([NSThread isMainThread], @"You must access Matisse from the main thread");
}

@end


@implementation MTSObjcImageRequestCreator

#pragma mark - Initialization

- (instancetype)initWithRequestBuilder:(MTSImageRequestBuilder *)builder {
    NSParameterAssert(builder != nil);
    
    if ((self = [super init])) {
        _requestBuilder = builder;
    }
    return self;
}


#pragma mark - Modifying the Request

MTS_IMPLEMENT_CREATOR_METHOD(transform, ^(id<MTSImageTransformation> transformation) {
    [self.requestBuilder addTransformation:transformation];
    return self;
})


#pragma mark - Executing the Request

MTS_IMPLEMENT_CREATOR_METHOD(fetch, ^(void(^completion)(MTSImageRequest*, UIImage*, NSError*)) {
    return [self.requestBuilder fetch:completion];
});

MTS_IMPLEMENT_CREATOR_METHOD(showInTarget, ^(id<MTSImageRequestTarget> target) {
    return [self.requestBuilder showInTarget:target];
});

MTS_IMPLEMENT_CREATOR_METHOD(showIn, ^(UIImageView *imageView) {
    return [self.requestBuilder showInTarget:(id)imageView];
});

@end
