//
//  FPImageSearchSourceController.m
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPImageSearchSourceController.h"
#import "FPUtils.h"

@implementation FPImageSearchSourceController

#pragma mark - Public Methods

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.navigationSupported = NO;
        self.searchSupported = YES;
    }

    return self;
}

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;

    self.path = [NSString stringWithFormat:@"%@/%@",
                 self.source.rootUrl,
                 [FPUtils urlEncodeString:searchString]];

    DLog(@"setting path of %@ to %@", self, self.path);
}

@end
