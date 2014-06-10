//
//  FPUtils.m
//  FPPicker
//
//  Created by Ruben Nine on 10/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>

@implementation FPUtils

+ (NSBundle *)frameworkBundle
{
    static NSBundle *frameworkBundle = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        NSString *mainBundlePath = [NSBundle mainBundle].resourcePath;
        NSString *frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"FPPicker.bundle"];

        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });

    return frameworkBundle;
}

+ (NSString *)utiForMimetype:(NSString *)mimetype
{
    return (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
                                                                               (__bridge CFStringRef)mimetype,
                                                                               NULL);
}

+ (NSString *)urlEncodeString:(NSString *)inputString
{
    NSString *invalidCharactersString = @"!*'();:@&=+$,/?%#[]\" ";

    CFStringRef encoded = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                  (__bridge CFStringRef)inputString,
                                                                  NULL,
                                                                  (CFStringRef)invalidCharactersString,
                                                                  kCFStringEncodingUTF8);

    return CFBridgingRelease(encoded);
}

+ (BOOL)mimetype:(NSString *)mimetype instanceOfMimetype:(NSString *)supermimetype
{
    if ([supermimetype isEqualToString:@"*/*"])
    {
        return YES;
    }

    if (mimetype == supermimetype)
    {
        return YES;
    }

    NSArray *splitType1 = [mimetype componentsSeparatedByString:@"/"];
    NSArray *splitType2 = [supermimetype componentsSeparatedByString:@"/"];

    if ([splitType1[0] isEqualToString:splitType2[0]])
    {
        return YES;
    }

    return NO;
}

+ (NSString *)formatTimeInSeconds:(int)timeInSeconds
{
    int seconds = timeInSeconds % 60;
    int minutes = timeInSeconds / 60;

    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

+ (NSString *)genRandStringLength:(int)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];

    for (int i = 0; i < len; i++)
    {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % letters.length]];
    }

    return randomString;
}

@end
