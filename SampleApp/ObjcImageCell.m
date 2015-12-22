//
//  ImageCell.m
//  Matisse
//
//  Created by Markus Gasser on 26.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import "ObjcImageCell.h"


@implementation ObjcImageCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

@end
