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

- (instancetype)initWithSource:(FPSource *)source
                       andPath:(NSString *)path;

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) FPSource *source;

- (NSString *)rootPath;
- (NSString *)parentPath;

@end
