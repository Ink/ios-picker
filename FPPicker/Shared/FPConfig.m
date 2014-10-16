//
//  FPConfig.m
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPConfig.h"
#import "FPPrivateConfig.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@interface FPConfig ()

@property (nonatomic, readwrite, strong) NSURL *baseURL;

@end

@implementation FPConfig

static FPConfig *FPSharedInstance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        FPSharedInstance = [[super allocWithZone:NULL] init];
    });

    return FPSharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

#pragma mark - Accessors

- (NSURL *)baseURL
{
    if (!_baseURL)
    {
        _baseURL = [NSURL URLWithString:fpBASE_URL];
    }

    return _baseURL;
}

#if TARGET_OS_IPHONE

// In iOS, if no image preprocessing block is given,
// we will use a default implementation that compresses JPEG images at 0.6 quality.

- (FPImageUploadPreprocessorBlock)imageUploadPreprocessorBlock
{
    if (!_imageUploadPreprocessorBlock)
    {
        _imageUploadPreprocessorBlock = ^(NSURL *localURL,
                                          NSString *mimetype) {
            if ([mimetype isEqualToString:@"image/jpeg"])
            {
                CGFloat compresionQuality = 0.6;

                DLog(@"Compressing JPEG with %f compression quality.", compresionQuality);

                UIImage *image = [UIImage imageWithContentsOfFile:localURL.path];
                NSData *filedata = UIImageJPEGRepresentation(image, compresionQuality);

                [filedata writeToURL:localURL
                          atomically:YES];
            }
        };
    }

    return _imageUploadPreprocessorBlock;
}

#endif

#pragma mark - Private

- (NSArray *)cookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    return [cookieStorage cookiesForURL:self.baseURL];
}

- (NSDictionary *)infoDict
{
    return [NSBundle mainBundle].infoDictionary;
}

#pragma mark - Only to be used in tests

+ (void)destroyAndRecreateSingleton
{
    FPSharedInstance = [[super allocWithZone:NULL] init];
}

@end
