//
//  NSDictionary+FPMerge.m
//  FPPicker
//
//  Created by Ruben Nine on 16/06/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "NSDictionary+FPMerge.h"

@implementation NSDictionary (FPMerge)

+ (NSDictionary *)mergeDictionary:(NSDictionary *)dictionary
                             into:(NSDictionary *)anotherDictionary
{
    NSMutableDictionary *tmpMutableDictionary = [dictionary mutableCopy];

    [tmpMutableDictionary addEntriesFromDictionary:anotherDictionary];

    return [tmpMutableDictionary copy];
}

@end
