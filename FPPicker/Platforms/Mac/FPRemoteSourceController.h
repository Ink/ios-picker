//
//  FPRemoteSourceController.h
//  FPPicker Mac
//
//  Created by Ruben Nine on 07/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FPSource;
@class FPAuthController;

@interface FPRemoteSourceController : NSViewController

@property (nonatomic, weak) IBOutlet FPAuthController *authController;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, strong) IBOutlet NSTextView *textView;
@property (nonatomic, strong) IBOutlet NSButton *loginButton;
@property (nonatomic, strong) IBOutlet NSButton *logoutButton;
@property (nonatomic, strong) IBOutlet NSTabView *tabView;

@property (nonatomic, strong) FPSource *source;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *viewType;
@property (nonatomic, strong) NSString *nextPage;

- (void)fpLoadContentAtPath;

@end
