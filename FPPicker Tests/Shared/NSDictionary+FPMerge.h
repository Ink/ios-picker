//
//  NSDictionary+FPMerge.h
//  FPPicker
//
//  Created by Ruben Nine on 16/06/14.
//  Copyright (c) 2014 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FPMerge)

+ (NSDictionary *)mergeDictionary:(NSDictionary *)dictionary
                             into:(NSDictionary *)anotherDictionary;

@end
