//
//  NSData+Extention.m
//  WildFireChat
//
//  Created by Ada on 6/4/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "NSData+Extention.h"

@implementation NSData (Extention)

- (NSString *)toHex {
    const unsigned *tokenBytes = [self bytes];
    NSString *hex = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    return hex;
}

@end
