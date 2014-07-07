//
//  FPUtils.m
//  FPPicker
//
//  Created by Ruben Nine on 10/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPUtils.h"
#import "FPConfig.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

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
    NSString *rndString = [FPUtils genRandStringLength:length];
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

+ (NSString *)JSONSessionStringForAPIKey:(NSString *)APIKey andMimetypes:(id)mimetypes
{
    NSError *error;

    NSMutableDictionary *sessionObject = [@{@"app":[@{} mutableCopy]} mutableCopy];

    if (APIKey)
    {
        sessionObject[@"app"][@"apikey"] = APIKey;
    }

    if (mimetypes)
    {
        sessionObject[@"mimetypes"] = mimetypes;
    }

    return [FPUtils JSONEncodeObject:sessionObject
                               error:&error];
}

+ (BOOL)copyAssetRepresentation:(ALAssetRepresentation *)representation
                   intoLocalURL:(NSURL *)localURL
{
    NSError *error;
    const char *path;
    FILE *fd;

    path = localURL.path.UTF8String;
    fd = fopen(path, "w");

    if (!fd)
    {
        NSLog(@"Asset copy failed: Could not open file at path %s for writing.", path);

        return NO;
    }


    uint8_t *bufferChunk = malloc(sizeof(uint8_t) * fpMaxLocalChunkCopySize);

    if (!bufferChunk)
    {
        NSLog(@"Asset copy failed: Buffer could not be allocated");

        fclose(fd);

        return NO;
    }

    int chunksNeeded = (int)ceilf(1.0f * representation.size / fpMaxLocalChunkCopySize);

    size_t actualBytesRead;
    size_t actualBytesWritten;
    size_t totalBytesWritten = 0;
    size_t offset = 0;

    for (int c = 0; c < chunksNeeded; c++)
    {
        actualBytesRead = [representation getBytes:bufferChunk
                                        fromOffset:offset
                                            length:fpMaxLocalChunkCopySize
                                             error:&error];

        if (error)
        {
            NSLog(@"Asset copy failed: An error ocurred when reading bytes at offset %lu from %@: %@",
                  offset,
                  representation,
                  error);

            fclose(fd);

            return NO;
        }

        offset += actualBytesRead;

        actualBytesWritten = fwrite(bufferChunk, 1, actualBytesRead, fd);
        totalBytesWritten += actualBytesWritten;
    }

    free(bufferChunk);
    fclose(fd);

    if (totalBytesWritten < representation.size)
    {
        NSLog(@"Asset copy failed: Incomplete copy. Only %lu out of %lld bytes were copied",
              totalBytesWritten,
              representation.size);

        return NO;
    }

    return YES;
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

+ (UIImage *)fixImageRotationIfNecessary:(UIImage *)image
{
    /*
     * http://stackoverflow.com/questions/10170009/image-became-horizontal-after-successfully-uploaded-on-server-using-http-post
     */

    CGImageRef imgRef = image.CGImage;

    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);


    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);

    /*
       int kMaxResolution = 640; // Or whatever

       if (width > kMaxResolution || height > kMaxResolution) {
       CGFloat ratio = width/height;
       if (ratio > 1) {
       bounds.size.width = kMaxResolution;
       bounds.size.height = roundf(bounds.size.width / ratio);
       }
       else {
       bounds.size.height = kMaxResolution;
       bounds.size.width = roundf(bounds.size.height * ratio);
       }
       }
     */

    CGFloat scaleRatio = CGRectGetWidth(bounds) / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;

    switch (orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;

        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;

        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;

        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = CGRectGetHeight(bounds);
            bounds.size.height = CGRectGetWidth(bounds);
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;

        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = CGRectGetHeight(bounds);
            bounds.size.height = CGRectGetWidth(bounds);
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;

        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = CGRectGetHeight(bounds);
            bounds.size.height = CGRectGetWidth(bounds);
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;

        case UIImageOrientationRight: //EXIF = 8
            boundHeight = CGRectGetHeight(bounds);
            bounds.size.height = CGRectGetWidth(bounds);
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;

        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }

    UIGraphicsBeginImageContext(bounds.size);

    CGContextRef context = UIGraphicsGetCurrentContext();

    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }

    CGContextConcatCTM(context, transform);

    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return imageCopy;
}

@end
