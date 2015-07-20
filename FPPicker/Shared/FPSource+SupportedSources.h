//
//  FPSource+SupportedSources.h
//  FPPicker
//
//  Created by Ruben Nine on 20/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSource.h"

@interface FPSource (SupportedSources)

+ (NSArray *)allSources;
+ (NSArray *)allMobileSources;
+ (NSArray *)allDesktopSources;

+ (NSArray *)localMobileSources;
+ (NSArray *)localDesktopSources;
+ (NSArray *)remoteSources;

- (instancetype)initWithSourceIdentifier:(NSString *)identifier;
+ (FPSource *)sourceWithIdentifier:(NSString *)identifier;

@end
