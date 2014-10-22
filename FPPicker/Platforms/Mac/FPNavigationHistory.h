//
//  FPNavigationHistory.h
//  FPPicker
//
//  Created by Ruben Nine on 22/10/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPNavigationHistory : NSObject

- (void)addItem:(id)item;
- (void)clear;
- (id)currentItem;
- (BOOL)canNavigateBack;
- (BOOL)canNavigateForward;
- (BOOL)navigateBack;
- (BOOL)navigateForward;

@end
