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

- (instancetype)initWithTheme:(FPTheme *)theme NS_DESIGNATED_INITIALIZER;
- (void)applyToController:(id)controller;

@property (nonatomic, strong, readonly) FPTheme *theme;

@end
