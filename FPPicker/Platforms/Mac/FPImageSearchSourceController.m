//
//  FPImageSearchSourceController.m
//  FPPicker
//
//  Created by Ruben on 9/25/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPImageSearchSourceController.h"
#import "FPInternalHeaders.h"

@interface FPImageSearchSourceController ()

@property (nonatomic, strong) FPRepresentedSource *representedSource;

@end

@implementation FPImageSearchSourceController

#pragma mark - Accessors

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;

    self.representedSource.currentPath = [NSString stringWithFormat:@"%@/%@",
                                          self.representedSource.source.rootPath,
                                          [FPUtils urlEncodeString:searchString]];
}

@end
