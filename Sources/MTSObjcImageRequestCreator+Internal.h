//
//  MTSObjcImageRequestCreator+Internal.h
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import "MTSObjcImageRequestCreator.h"


@class MTSImageRequestBuilder;


@interface MTSObjcImageRequestCreator ()

- (instancetype)initWithRequestBuilder:(MTSImageRequestBuilder *)builder;

@property (nonatomic, readonly) MTSImageRequestBuilder *requestBuilder;

@end
