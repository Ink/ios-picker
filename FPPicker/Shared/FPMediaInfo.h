//
//  FPMediaInfo.h
//  FPPicker
//
//  Created by Ruben Nine on 14/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAsset;
@class FPSource;

@interface FPMediaInfo : NSObject

@property (nonatomic, strong) NSString *mediaType;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) NSURL *remoteURL;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSNumber *filesize;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) FPSource *source;
@property (nonatomic, strong) ALAsset *originalAsset;
@property (nonatomic, strong) id thumbnailImage;

- (BOOL)containsImageAtMediaURL;
- (BOOL)containsVideoAtMediaURL;

@end
