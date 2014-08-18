//
//  FPUtils+ResourceHelpers.h
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPUtils.h"

@interface FPUtils (ResourceHelpers)

+ (NSArray *)allowedURLPrefixList;
+ (NSArray *)disallowedURLPrefixList;
+ (NSDictionary *)settings;
+ (NSString *)xuiJSString;

@end
