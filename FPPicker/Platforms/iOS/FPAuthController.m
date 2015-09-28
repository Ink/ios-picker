//
//  FPAuthController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPAuthController.h"
#import "FPInternalHeaders.h"
#import "FPUtils+ResourceHelpers.h"

// WebKit error constants are not exposed in iOS (they are in WebKit for Mac)
// So we define them here (conditionally) for documentation purposes.
// https://developer.apple.com/library/prerelease/mac/documentation/Cocoa/Reference/WebKit/Miscellaneous/WebKit_Constants/#//apple_ref/doc/constant_group/WebKit_Policy_Errors

#ifndef WebKitErrorFrameLoadInterruptedByPolicyChange
#define WebKitErrorFrameLoadInterruptedByPolicyChange 102
#endif

@interface FPAuthController ()

@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, strong) FPSource *source;

@end


@implementation FPAuthController

- (instancetype)initWithSource:(FPSource *)source
{
    if (!source)
    {
        return nil;
    }

    self = [super initWithNibName:nil
                           bundle:nil];

    if (self)
    {
        self.source = source;
        self.service = source.identifier;
        self.title = source.name;
    }

    return self;
}

#pragma mark - Accessors

- (NSDictionary *)settings
{
    if (!_settings)
    {
        _settings = [FPUtils settings];
    }

    return _settings;
}

#pragma mark - Other Methods

- (void)backToSourceList
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Override it with our specialty jump back to list.

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backToSourceList)];

    self.webView = [UIWebView new];

    [self.view addSubview:self.webView];

    self.webView.delegate = self;

    NSString *serviceID = [self.service lowercaseString];

    NSString *urlString = [NSString stringWithFormat:@"%@/api/client/%@/auth/open?m=*/*&key=%@&id=0&modal=false",
                           fpBASE_URL,
                           serviceID,
                           fpAPIKEY];

    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    self.webView.scalesPageToFit = YES;

    [self.webView loadRequest:requestObj];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.webView = nil;
    self.service = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    self.webView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.webView.frame = self.view.bounds;

    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:NO];
    [self.webView stopLoading];

    self.webView.delegate = nil;
    self.webView = nil;
}

- (void)loadRequest:(NSURLRequest *)request
{
    if ([self.webView isLoading])
    {
        [self.webView stopLoading];
    }

    [self.webView loadRequest:request];
}

#pragma mark WebView Delegate Methods

- (BOOL)               webView:(UIWebView *)localWebView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navigationType
{
    DLog(@"Loading Path: %@ (relpath: %@)",
         request.URL.absoluteString,
         request.URL.path);

    if ([request.URL.path isEqualToString:@"/dialog/open"])
    {
        //NSLog(@"HIT");
        //NSLog(@"Coookies: %@", fpCOOKIES);

        [[NSNotificationCenter defaultCenter] postNotificationName:FPPickerDidAuthenticateAgainstSourceNotification
                                                            object:self.source];

        [self.navigationController popViewControllerAnimated:NO];

        return NO;
    }

    if ([self.settings[@"OnlyResolveAllowedLinks"] boolValue])
    {
        NSString *normalizedString = [request.URL.absoluteString stringByStandardizingPath];

        for (id object in [FPUtils disallowedURLPrefixList])
        {
            if ([object isEqualToString:@""])
            {
                // Ignore empty strings

                continue;
            }

            if ([FPUtils validateURL:normalizedString
                   againstURLPattern     :object])
            {
                NSForceLog(@"REJECTING URL FOR WEBVIEW: %@", request.URL.absoluteString);

                return NO;
            }
        }

        for (id object in [FPUtils allowedURLPrefixList])
        {
            if ([object isEqualToString:@""])
            {
                // Ignore empty strings

                continue;
            }

            if ([FPUtils validateURL:normalizedString
                   againstURLPattern     :object])
            {
                return YES;
            }
        }

        #ifdef DEBUG

        if ([request.URL.absoluteString hasPrefix:fpBASE_URL])
        {
            [MBProgressHUD showHUDAddedTo:localWebView
                                 animated:YES];

            return YES;
        }

        #endif

        NSForceLog(@"REJECTING URL FOR WEBVIEW: %@", request.URL.absoluteString);

        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:webView
                         animated:YES];
}

- (void)         webView:(UIWebView *)webView
    didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:webView
                             animated:YES];

    if ([error.domain isEqualToString:@"WebKitErrorDomain"] &&
        error.code != WebKitErrorFrameLoadInterruptedByPolicyChange)
    {
        NSForceLog(@"Web view load error: %@", error);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:webView
                             animated:YES];

    int width = CGRectGetWidth(CGRectApplyAffineTransform(self.view.bounds,
                                                          self.view.transform));

    NSString *js = [NSString stringWithFormat:
                    @"var meta = document.createElement('meta'); " \
                    "meta.setAttribute( 'name', 'viewport' ); " \
                    "meta.setAttribute( 'content', 'width = %d, initial-scale = 1.0, user-scalable = yes' ); " \
                    "document.getElementsByTagName('head')[0].appendChild(meta)", width
                   ];

    [webView stringByEvaluatingJavaScriptFromString:js];

    if ([self.settings[@"HideAllLinks"] boolValue])
    {
        NSString *xui = [FPUtils xuiJSString];
        NSString *linkRemoval = @"x$('a').setStyle('display', 'none')";

        [webView stringByEvaluatingJavaScriptFromString:xui];
        [webView stringByEvaluatingJavaScriptFromString:linkRemoval];
    }
}

@end
