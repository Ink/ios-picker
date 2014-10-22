//
//  FPSourcePath.h
//  FPPicker
//
//  Created by Ruben Nine on 20/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPSource;

@interface FPSourcePath : NSObject

/**
   Please use the designated initializer instead.
 */
- (id)init __unavailable;

- (instancetype)initWithSource:(FPSource *)source
                       andPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong) FPSource *source;
@property (nonatomic, strong) NSString *path;

- (NSString *)rootPath;
- (NSString *)parentPath;

@end
