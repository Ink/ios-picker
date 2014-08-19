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

@interface FPAuthController ()

@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, copy) FPAuthSuccessBlock successBlock;
@property (nonatomic, copy) FPAuthFailureBlock failureBlock;

@end

@implementation FPAuthController

#pragma mark - Accessors

- (NSDictionary *)settings
{
    if (!_settings)
    {
        _settings = [FPUtils settings];
    }

    return _settings;
}

#pragma mark - Public Methods

- (void)displayAuthSheetWithSource:(FPSource *)source
                     inModalWindow:(NSWindow *)modalWindow
                     modalDelegate:(id)modalDelegate
                    didEndSelector:(SEL)didEndSelector
                           success:(FPAuthSuccessBlock)success
                           failure:(FPAuthFailureBlock)failure
{
    [self loadRequestWithSource:source
                        success:success
                        failure:failure];

    [NSApp beginSheet:self.view.window
       modalForWindow:modalWindow
        modalDelegate:modalDelegate
       didEndSelector:didEndSelector
          contextInfo:nil];
}

#pragma mark - Private Methods

- (void)loadRequestWithSource:(FPSource*)source
                      success:(FPAuthSuccessBlock)success
                      failure:(FPAuthFailureBlock)failure
{
    self.successBlock = success;
    self.failureBlock = failure;

    self.service = source.identifier;
    self.title = source.name;

    NSString *urlString = [NSString stringWithFormat:@"%@/api/client/%@/auth/open?m=*/*&key=%@&id=0&modal=false",
                           fpBASE_URL,
                           self.service,
                           fpAPIKEY];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

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

    if ([url.path isEqualToString:@"/dialog/open"])
    {
        [self closeSheet:self];
        self.successBlock();

        return;
    }
}

- (void)          webView:(WebView *)sender
    didFinishLoadForFrame:(WebFrame *)frame
{
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

@end
