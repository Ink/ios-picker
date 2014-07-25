//
//  FPPicker.m
//  FPPicker
//
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import "FPPicker.h"
#import "FPConfig.h"

@implementation FPPicker

+ (void)configureWithAPIKey:(NSString *)apiKey
{
    FPConfig *config = [FPConfig sharedInstance];
    config.APIKey = apiKey;
}

@end
