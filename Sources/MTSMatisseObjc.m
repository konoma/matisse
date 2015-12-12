//
//  MTSMatisseObjc.m
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import "MTSMatisseObjc.h"
#import "MTSMatisseObjc+Internal.h"

#import <Matisse/Matisse-Swift.h>


@implementation MTSMatisse

- (MTSObjcImageRequestCreator *)load:(NSURL *)url {
    return nil;
}

+ (MTSObjcImageRequestCreator *)load:(NSURL *)url {
    return nil;
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
