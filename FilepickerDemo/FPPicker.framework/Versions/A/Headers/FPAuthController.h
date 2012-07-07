//
//  TestViewController.h
//  filepicker
//
//  Created by Liyan David Chang on 6/25/12.
//  Copyright (c) 2012 Filepicker.io, All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPConfig.h"
#import "FP_MBProgressHUD.h"

@interface FPAuthController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *service;

@property (nonatomic, assign) BOOL alreadyReload;
@end
