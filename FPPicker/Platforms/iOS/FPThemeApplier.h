//
//  FPThemeApplier.h
//  FPPicker
//
//  Created by Ruben Nine on 07/08/15.
//  Copyright (c) 2015 Filepicker.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPTheme.h"

@interface FPThemeApplier : NSObject

@property (nonatomic, strong, readonly) FPTheme *theme;

- (instancetype)initWithTheme:(FPTheme *)theme NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)applyToController:(id)controller;

@end
