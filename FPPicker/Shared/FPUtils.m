//
//  FPUtils.m
//  FPPicker
//
//  Created by Ruben Nine on 10/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPUtils.h"
#import "FPPrivateConfig.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSData+FPHexString.h"

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#endif

@implementation FPUtils

+ (NSBundle *)frameworkBundle
{
    static NSBundle *frameworkBundle = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        NSString *mainBundlePath = [[NSBundle bundleForClass:self.class] resourcePath];
        NSString *frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"FPPicker.bundle"];

        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });

    return frameworkBundle;
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
    int hours = timeInSeconds / 3600.0;
    int minutes = (timeInSeconds % 3600) / 60;
    int seconds = timeInSeconds % 60;

    if (hours == 0)
    {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    else
    {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
}

+ (NSString *)genRandStringLength:(int)len
{
    const NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];

    for (int i = 0; i < len; i++)
    {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % letters.length]];
    }

    return [randomString copy];
}

+ (NSURL *)genRandTemporaryURLWithFileLength:(int)length
{
    NSString *rndString = [self genRandStringLength:length];
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:rndString];

    return [NSURL fileURLWithPath:tempPath
                      isDirectory:NO];
}

+ (NSString *)JSONEncodeObject:(id)object
                         error:(NSError **)error
{
    if ([NSJSONSerialization isValidJSONObject:object])
    {
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:object
                                                           options:0
                                                             error:error];

        NSString *JSONString = [[NSString alloc] initWithData:JSONData
                                                     encoding:NSUTF8StringEncoding];

        return JSONString;
    }

    return nil;
}

+ (size_t)fileSizeForLocalURL:(NSURL *)url
{
    NSNumber *fileSizeValue;
    NSError *fileSizeError;

    [url getResourceValue:&fileSizeValue
                   forKey:NSURLFileSizeKey
                    error:&fileSizeError];

    if (fileSizeError)
    {
        NSLog(@"Error when getting filesize of %@: %@",
              url,
              fileSizeError);
    }

    return fileSizeValue.unsignedLongValue;
}

+ (NSString *)policyForHandle:(NSString *)handle
               expiryInterval:(NSTimeInterval)expiryInterval
               andCallOptions:(NSArray *)callOptions
{
    NSAssert(expiryInterval, @"expiryInterval is a required argument");

    NSMutableDictionary *policyDictionary = [NSMutableDictionary dictionary];
    NSDate *expiryDate = [NSDate dateWithTimeIntervalSinceNow:expiryInterval];

    policyDictionary[@"expiry"] = @((time_t)[expiryDate timeIntervalSince1970]);

    if (callOptions)
    {
        policyDictionary[@"call"] = callOptions;
    }

    if (handle)
    {
        policyDictionary[@"handle"] = handle;
    }

    NSError *error;
    NSString *JSONString = [self JSONEncodeObject:policyDictionary
                                            error:&error];

    if (error)
    {
        NSLog(@"Error JSON encoding object (%@): %@",
              policyDictionary,
              error);

        return nil;
    }

    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedPolicy = [JSONData base64EncodedStringWithOptions:0];

    return base64EncodedPolicy;
}

+ (NSString *)signPolicy:(NSString *)policy
                usingKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [policy cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256,
           cKey,
           strlen(cKey),
           cData,
           strlen(cData),
           cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];

    return [HMAC FPHexString];
}

+ (NSString *)filePickerLocationWithOptionalSecurityFor:(NSString *)filePickerLocation
{
    if (fpAPPSECRETKEY)
    {
        NSString *handle = [[NSURL URLWithString:filePickerLocation] lastPathComponent];

        NSAssert(handle,
                 @"Failed to extract handle from %@",
                 filePickerLocation);

        NSString *policy = [self policyForHandle:handle
                                  expiryInterval:3600.0
                                  andCallOptions:@[@"read"]];

        NSString *signature = [self signPolicy:policy
                                      usingKey:fpAPPSECRETKEY];

        NSString *queryString = [NSString stringWithFormat:@"?policy=%@&signature=%@",
                                 policy,
                                 signature];

        return [filePickerLocation stringByAppendingString:queryString];
    }
    else
    {
        return filePickerLocation;
    }
}

+ (BOOL)  validateURL:(NSString *)URL
    againstURLPattern:(NSString *)URLPattern
{
    NSString *regexpPattern = [URLPattern stringByStandardizingPath];

    regexpPattern = [NSRegularExpression escapedPatternForString:regexpPattern];

    regexpPattern = [regexpPattern stringByReplacingOccurrencesOfString:@"\\*"
                                                             withString:@"((\\w|\\-)+)"];

    regexpPattern = [@"^" stringByAppendingString:regexpPattern];

    NSRegularExpressionOptions matchOptions = NSRegularExpressionCaseInsensitive |
                                              NSRegularExpressionAnchorsMatchLines;

    NSError *error;

    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regexpPattern
                                                                            options:matchOptions
                                                                              error:&error];

    if (error)
    {
        DLog(@"Error: %@", error);

        return NO;
    }

    NSString *standardizedURLPath = [URL stringByStandardizingPath];

    NSUInteger numberOfMatches = [regexp numberOfMatchesInString:standardizedURLPath
                                                         options:NSMatchingReportCompletion
                                                           range:NSMakeRange(0, standardizedURLPath.length)];

    return numberOfMatches > 0;
}

+ (NSString *)UTIForMimetype:(NSString *)mimetype
{
    return (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
                                                                               (__bridge CFStringRef)mimetype,
                                                                               NULL);
}

+ (NSString *)mimetypeForUTI:(NSString *)UTI
{
    return (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
}

+ (BOOL)      UTI:(NSString *)UTI
    conformsToUTI:(NSString *)conformsToUTI
{
    Boolean result = UTTypeConformsTo((__bridge CFStringRef)UTI,
                                      (__bridge CFStringRef)conformsToUTI);

    return (BOOL)result;
}

+ (NSError *) errorWithCode:(NSInteger)code
    andLocalizedDescription:(NSString *)localizedDescription
{
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey:localizedDescription
    };

    NSError *error = [NSError errorWithDomain:@"io.filepicker"
                                         code:code
                                     userInfo:userInfo];

    return error;
}

+ (NSString *)uuidString
{
    // Returns a UUID
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);

    CFRelease(uuid);

    return uuidStr;
}

@end
