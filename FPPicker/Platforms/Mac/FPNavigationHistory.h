//
//  FPNavigationHistory.h
//  FPPicker
//
//  Created by Ruben Nine on 22/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPNavigationHistory : NSObject

- (void)addNavigationItem:(id)item;
- (void)clearNavigation;
- (id)currentNavigationItem;
- (BOOL)canNavigateBack;
- (BOOL)canNavigateForward;
- (BOOL)navigateBack;
- (BOOL)navigateForward;

@end
