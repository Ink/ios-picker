//
//  FPAuthController.m
//  FPPicker Mac
//
//  Created by Ruben Nine on 06/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPAuthController.h"
#import "FPPrivateConfig.h"
#import "FPUtils+ResourceHelpers.h"
#import "FPWindow.h"
#import "FPConstants.h"
#import <PureLayout/PureLayout.h>

@interface FPAuthController () <WebFrameLoadDelegate, WebResourceLoadDelegate>

@property (nonatomic, strong) FPSource *source;
@property (nonatomic, strong) NSString *service;
@property (nonatomic, strong) NSString *path;

@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, copy) FPAuthSuccessBlock successBlock;
@property (nonatomic, copy) FPAuthFailureBlock failureBlock;

@property (nonatomic, assign) BOOL didSetupViewConstraints;
@property (nonatomic, strong) WebView *webView;
@property (nonatomic, strong) NSProgressIndicator *progressIndicator;
@property (nonatomic, strong) NSButton *cancelButton;
@property (nonatomic, strong) FPWindow *window;

@end

@implementation FPAuthController

#pragma mark - Class Methods

+ (void)clearAuthCredentials
{
    // Since our cookies are stored system-wide (used by Safari and also our library) and
    // our user may have existing cookies from the web-based Filepicker library,
    // there could be an iframe value pair stored on the session cookie which will cause
    // our authentication process to fail in the last step.
    // A work-around for this is to simply remove the iframe value pair from the session cookie.

    for (NSHTTPCookie *cookie in fpCOOKIES)
    {
        if (![cookie.name isEqualToString:@"session"])
        {
            continue;
        }

        NSError *error;

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\&iframe\\=\\w+\\="
                                                                               options:0
                                                                                 error:&error];

        if (error)
        {
            DLog(@"Error: %@", error);

            continue;
        }

        NSString *newCookieValue = [regex stringByReplacingMatchesInString:cookie.value
                                                                   options:0
                                                                     range:NSMakeRange(0, cookie.value.length)
                                                              withTemplate:@""];

        if (![cookie.value isEqualToString:newCookieValue])
        {
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSMutableDictionary *cookieProperties = [cookie.properties mutableCopy];

            cookieProperties[NSHTTPCookieValue] = newCookieValue;

            NSHTTPCookie *newcookie = [NSHTTPCookie cookieWithProperties:cookieProperties];

            [cookieStorage deleteCookie:cookie];
            [cookieStorage setCookie:newcookie];

            NSForceLog(@"Removed iframe from session cookie.");
        }
    }
}

#pragma mark - Accessors

- (WebView *)webView
{
    if (!_webView)
    {
        _webView = [[WebView alloc] initForAutoLayout];
        _webView.frameLoadDelegate = self;
        _webView.resourceLoadDelegate = self;
    }

    return _webView;
}

- (NSProgressIndicator *)progressIndicator
{
    if (!_progressIndicator)
    {
        _progressIndicator = [[NSProgressIndicator alloc] initForAutoLayout];
        _progressIndicator.style = NSProgressIndicatorSpinningStyle;
        _progressIndicator.indeterminate = YES;
        _progressIndicator.displayedWhenStopped = NO;
    }

    return _progressIndicator;
}

- (NSButton *)cancelButton
{
    if (!_cancelButton)
    {
        _cancelButton = [[NSButton alloc] initForAutoLayout];
        [_cancelButton setButtonType:NSToggleButton];
        _cancelButton.bezelStyle = NSRoundedBezelStyle;
        _cancelButton.title = @"Cancel";
        _cancelButton.target = self;
        _cancelButton.action = @selector(closeSheet:);
    }

    return _cancelButton;
}

- (NSDictionary *)settings
{
    if (!_settings)
    {
        _settings = [FPUtils settings];
    }

    return _settings;
}

#pragma mark - Constructors/Destructors

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.didSetupViewConstraints = NO;
    }

    return self;
}

- (instancetype)initWithSource:(FPSource *)source
{
    self = [self init];

    if (self)
    {
        self.source = source;
        self.service = source.identifier;
        self.title = source.name;
    }

    return self;
}

#pragma mark - Public Methods

- (void)cancelOperation:(id)sender
{
    [self closeSheet:self];
}

- (void)loadView
{
    self.view = [[NSView alloc] initForAutoLayout];
}

- (void)displayAuthSheetInModalWindow:(NSWindow *)modalWindow
                              success:(FPAuthSuccessBlock)success
                              failure:(FPAuthFailureBlock)failure
{
    CGFloat desiredContentWidth = MIN(640, NSWidth(modalWindow.frame));
    NSRect initialContentRect = NSMakeRect(0, 0, desiredContentWidth, 540);

    self.window = [[FPWindow alloc] initWithContentRect:initialContentRect
                                              styleMask:0
                                                backing:NSBackingStoreBuffered
                                                  defer:YES];

    self.window.hasShadow = YES;
    self.window.contentView = self.view;

    [self updateViewConstraints];
    [self.class clearAuthCredentials];

    [self loadRequestWithSource:self.source
                        success:success
                        failure:failure];

    [modalWindow beginSheet:self.window
          completionHandler:nil];
}

- (void)updateViewConstraints
{
    if (!self.didSetupViewConstraints)
    {
        [self addControls];

        [self.webView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [self.webView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.webView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [self.webView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:70];

        [self.progressIndicator autoCenterInSuperview];

        [self.cancelButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:22];
        [self.cancelButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:22];

        self.didSetupViewConstraints = YES;
    }

    [super updateViewConstraints];
}

#pragma mark - Private Methods

- (void)loadRequestWithSource:(FPSource*)source
                      success:(FPAuthSuccessBlock)success
                      failure:(FPAuthFailureBlock)failure
{
    self.successBlock = success;
    self.failureBlock = failure;

    NSString *urlString = [NSString stringWithFormat:@"%@/api/client/%@/auth/open?m=*/*&key=%@&id=0&modal=false",
                           fpBASE_URL,
                           self.service,
                           fpAPIKEY];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [self.progressIndicator startAnimation:self];
    [self.webView.mainFrame loadRequest:request];
}

#pragma mark - WebViewFrameLoadDelegate Methods

- (void)                    webView:(WebView *)sender
    didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    NSURL *url = sender.mainFrame.provisionalDataSource.request.URL;

    DLog(@"Started loading %@", url);

    [self.progressIndicator startAnimation:self];
}

- (void)                                       webView:(WebView *)sender
    didReceiveServerRedirectForProvisionalLoadForFrame:(WebFrame *)frame
{
    NSURL *url = sender.mainFrame.provisionalDataSource.request.URL;

    DLog(@"Redirecting to %@", url);
}

- (void)          webView:(WebView *)sender
    didFinishLoadForFrame:(WebFrame *)frame
{
    [self.progressIndicator stopAnimation:self];

    NSURL *url = sender.mainFrame.dataSource.request.URL;

    if ([url.path isEqualToString:@"/dialog/open"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:FPPickerDidAuthenticateAgainstSourceNotification
                                                            object:self.source];

        [self closeSheet:self];
        self.successBlock();

        return;
    }

    int width = (int)self.view.bounds.size.width;

    NSString *js = [NSString stringWithFormat:
                    @"var meta = document.createElement('meta'); " \
                    "meta.setAttribute( 'name', 'viewport' ); " \
                    "meta.setAttribute( 'content', 'width = %d, initial-scale = 1.0, user-scalable = yes' ); " \
                    "document.getElementsByTagName('head')[0].appendChild(meta)", width
                   ];

    [self.webView stringByEvaluatingJavaScriptFromString:js];

    if ([self.settings[@"HideAllLinks"] boolValue])
    {
        NSString *xui = [FPUtils xuiJSString];
        NSString *linkRemoval = @"x$('a').setStyle('display', 'none')";

        [self.webView stringByEvaluatingJavaScriptFromString:xui];
        [self.webView stringByEvaluatingJavaScriptFromString:linkRemoval];
    }

    [self.progressIndicator stopAnimation:self];
}

- (void)         webView:(WebView *)sender
    didFailLoadWithError:(NSError *)error
                forFrame:(WebFrame *)frame
{
    if (error.code == NSURLErrorCancelled)
    {
        // This will typically happen when user requests to close the authentication sheet.

        DLog(@"User cancelled load request.");
    }
    else
    {
        self.failureBlock(error);
    }
}

#pragma mark - Actions

- (IBAction)closeSheet:(id)sender
{
    [self.webView stopLoading:self];

    [self.webView.mainFrame loadHTMLString:@""
                                   baseURL:nil];

    // In the case that the focus was on a text field,
    // this will force the text field to end editing
    // so changes to the field can be confirmed before closing the sheet

    [self.view.window makeFirstResponder:nil];

    // End sheet and order out

    [NSApp endSheet:self.view.window];
    [self.view.window orderOut:sender];
}

#pragma mark - Private Methods

- (void)addControls
{
    [self.view addSubview:self.webView];
    [self.webView addSubview:self.progressIndicator];
    [self.view addSubview:self.cancelButton];
}

@end
