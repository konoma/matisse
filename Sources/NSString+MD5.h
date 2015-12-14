//
//  NSString+MD5.h
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (MatisseMD5)

/// Create a MD5 hash from the receiver.
@property (nonatomic, readonly) NSString *matisseMD5String;

@end
