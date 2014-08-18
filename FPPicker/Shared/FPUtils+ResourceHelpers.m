//
//  FPUtils+ResourceHelpers.m
//  FPPicker
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPUtils+ResourceHelpers.h"

@implementation FPUtils (ResourceHelpers)

+ (NSArray *)allowedURLPrefixList
{
    NSURL *path = [[FPUtils frameworkBundle] URLForResource:@"allowedUrlPrefix"
                                              withExtension:@"plist"];

    return [NSArray arrayWithContentsOfURL:path];
}

+ (NSArray *)disallowedURLPrefixList
{
    NSURL *path = [[FPUtils frameworkBundle] URLForResource:@"disallowedUrlPrefix"
                                              withExtension:@"plist"];

    return [NSArray arrayWithContentsOfURL:path];
}

+ (NSDictionary *)settings
{
    NSURL *FPSettingsFilePath = [[FPUtils frameworkBundle] URLForResource:@"FilepickerSettings"
                                                            withExtension:@"plist"];

    return [NSDictionary dictionaryWithContentsOfURL:FPSettingsFilePath];
}

+ (NSString *)xuiJSString
{
    NSURL *xuiURL = [[FPUtils frameworkBundle] URLForResource:@"xui-2.3.2.min"
                                                withExtension:@"js"];

    NSError *error;

    NSString *xui = [NSString stringWithContentsOfURL:xuiURL
                                             encoding:NSUTF8StringEncoding
                                                error:&error];

    if (error)
    {
        NSForceLog(@"Error loading XUI javascript contents: %@", error);

        return nil;
    }

    return xui;
}

@end
