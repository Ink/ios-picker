//
//  FPBarButtonItem.h
//  FPPicker
//
//  Created by Ruben Nine on 10/08/15.
//  Copyright (c) 2015 Filepicker.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FPBarButtonItem : UIView

@property (nonatomic, copy) UIColor *happyTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *angryTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

@end
