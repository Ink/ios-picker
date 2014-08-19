//
//  FPAuthController.h
//  FPPicker Mac
//
//  Created by Ruben Nine on 06/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "FPSource.h"

typedef void (^FPAuthSuccessBlock)(void);
typedef void (^FPAuthFailureBlock)(NSError *error);


@interface FPAuthController : NSViewController

@property (nonatomic, strong) NSString *service;
@property (nonatomic, strong) NSString *path;

@property (nonatomic, weak) IBOutlet WebView *webView;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;

- (void)displayAuthSheetWithSource:(FPSource *)source
                     inModalWindow:(NSWindow *)modalWindow
                     modalDelegate:(id)modalDelegate
                    didEndSelector:(SEL)didEndSelector
                           success:(FPAuthSuccessBlock)success
                           failure:(FPAuthFailureBlock)failure;

@end
