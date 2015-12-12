//
//  ResizeTransformation+DSL.m
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import "ResizeTransformation+DSL.h"
#import <Matisse/Matisse-Swift.h>


@implementation MTSObjcImageRequestCreator (ResizeTransformation)

MTS_IMPLEMENT_CREATOR_METHOD(resizeTo, ^(CGSize size, UIViewContentMode contentMode) {
    return self.transform([[MTSResizeTransformation alloc] initWithTargetSize:size contentMode:contentMode]);
})

@end
