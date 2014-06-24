//
//  FPConfig.h
//  FPPicker
//
//  Created by Ruben Nine on 12/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#ifdef DEBUG
    #define fpBASE_URL                  @"https://dialog.filepicker.io"
#else
//Make sure release builds are always on prod.
    #define fpBASE_URL                  @"https://dialog.filepicker.io"
#endif

#define fpDEVICE_NAME               [[UIDevice currentDevice] name]
#define fpDEVICE_OS                 [[UIDevice currentDevice] systemName]
#define fpDEVICE_VERSION            [[UIDevice currentDevice] systemVersion]

#define fpDEVICE_TYPE               UI_USER_INTERFACE_IDIOM()
#define fpDEVICE_TYPE_IPAD          UIUserInterfaceIdiomPad
#define fpDEVICE_TYPE_IPHONE        UIUserInterfaceIdiomPhone

#define fpCOOKIES                   [[FPConfig sharedInstance] cookies]
#define fpAPIKEY                    [[FPConfig sharedInstance] APIKey]

#define fpWindowSize                CGSizeMake(320, 480)
#define fpCellIdentifier            @"Filepicker_Cell"

#define fpLocalThumbSize            75
#define fpRemoteThumbSize           100

#define fpMaxChunkSize              262144 //.25mb
#define fpNumRetries                10

#define fpMaxLocalChunkCopySize     2097152 //2.0mb

@interface FPConfig : NSObject

@property (nonatomic, strong) NSString *APIKey;
@property (nonatomic, strong) NSURL *baseURL;

+ (instancetype)sharedInstance;
- (NSArray *)cookies;

- (NSString *)APIKeyContentsFromFile;

@end
