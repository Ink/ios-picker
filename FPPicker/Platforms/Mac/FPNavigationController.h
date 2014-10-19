//
//  FPNavigationController.h
//  FPPicker
//
//  Created by Ruben Nine on 22/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPRepresentedSource;

@protocol FPNavigationControllerDelegate <NSObject>

@optional

- (void)currentDirectoryPopupButtonSelectionChanged:(NSString *)newPath;

@end

@interface FPNavigationController : NSViewController

@property (nonatomic, weak) IBOutlet id <FPNavigationControllerDelegate> delegate;

@property (nonatomic, assign) BOOL shouldEnableControls;
@property (nonatomic, strong) FPRepresentedSource *representedSource;

-(void)refreshDirectoriesPopup;

@end
