//
//  NSString+MD5.m
//  Matisse
//
//  Created by Markus Gasser on 29.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (MatisseMD5)

- (NSString *)matisseMD5String {
    const char *ptr = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:(CC_MD5_DIGEST_LENGTH * 2)];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    
    return output;
}

@end
