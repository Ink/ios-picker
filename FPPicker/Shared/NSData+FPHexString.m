//
//  NSData+FPHexString.m
//  FPPicker
//
//  Created by Ruben Nine on 14/07/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "NSData+FPHexString.h"

@implementation NSData (FPHexString)

- (NSString *)FPHexString
{
    NSMutableString *string = [NSMutableString stringWithCapacity:self.length * 2];
    const unsigned char *dataBytes = self.bytes;

    for (size_t idx = 0; idx < self.length; ++idx)
    {
        [string appendFormat:@"%02x", dataBytes[idx]];
    }

    return [string copy];
}

@end
