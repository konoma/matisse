//
//  ResizeTransformation+DSL.h
//  Matisse
//
//  Created by Markus Gasser on 12.12.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import <Matisse/MTSMatisseObjc.h>


@interface MTSObjcImageRequestCreator (ResizeTransformation)

MTS_DECLARE_CREATOR_METHOD(resizeTo, CGSize size, UIViewContentMode contentMode);

@end
