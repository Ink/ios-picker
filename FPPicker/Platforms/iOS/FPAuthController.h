//
//  TestViewController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FPSource;

@interface FPAuthController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *service;
@property (nonatomic) BOOL alreadyReload;

- (instancetype)initWithSource:(FPSource *)source NS_DESIGNATED_INITIALIZER;

@end
