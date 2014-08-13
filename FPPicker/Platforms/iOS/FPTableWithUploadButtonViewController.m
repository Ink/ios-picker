//
//  FPTableWithUploadButtonViewController.m
//  FPPicker
//
//  Created by Brett van Zuiden on 12/3/13.
//  Copyright (c) 2013 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPTableWithUploadButtonViewController.h"
#import "UIApplication+FPAppDimensions.h"

@interface FPTableWithUploadButtonViewController ()

@property (nonatomic, strong) UIButton *uploadButton;
@property (nonatomic, strong) UIView *uploadButtonContainer;

@end

@implementation FPTableWithUploadButtonViewController

static const CGFloat UPLOAD_BUTTON_CONTAINER_HEIGHT = 45.f;

// For displaying the uploading text, number of files
static UIColor *HAPPY_COLOR;

// For displaying an invalid number of files
static UIColor *ANGRY_COLOR;

+ (void)initialize
{
    //#4cd964
    HAPPY_COLOR = [UIColor colorWithRed:0.298f green:0.851f blue:0.392f alpha:1.f];
    //ff3b30
    ANGRY_COLOR = [UIColor colorWithRed:1.f green:0.231 blue:0.088 alpha:1.f];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];

    if (self)
    {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    if (self.selectMultiple)
    {
        // Adding a button on the bottom that allows you to finish your upload

        CGRect bounds = self.view.bounds;

        // Pinned to the bottom

        self.uploadButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                              bounds.size.height - UPLOAD_BUTTON_CONTAINER_HEIGHT,
                                                                              bounds.size.width,
                                                                              UPLOAD_BUTTON_CONTAINER_HEIGHT)];
        self.uploadButtonContainer.hidden = YES;

        //#F7F7F7
        UIColor *uploadButtonBackgroundColor = [UIColor colorWithHue:0
                                                          saturation:0
                                                          brightness:.97f
                                                               alpha:0.98f];

        self.uploadButtonContainer.backgroundColor = uploadButtonBackgroundColor;
        self.uploadButtonContainer.opaque = NO;
        self.uploadButtonContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                                                      UIViewAutoresizingFlexibleWidth;

        self.uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

        self.uploadButton.frame = CGRectMake(0,
                                             0,
                                             bounds.size.width,
                                             UPLOAD_BUTTON_CONTAINER_HEIGHT);

        self.uploadButton.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                             UIViewAutoresizingFlexibleHeight;

        [self.uploadButton addTarget:self
                              action:@selector(uploadButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];

        [self.uploadButton setTintColor:HAPPY_COLOR];

        [self.uploadButtonContainer addSubview:self.uploadButton];
        [self.navigationController.view addSubview:self.uploadButtonContainer];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.uploadButtonContainer removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUploadButton:(NSInteger)count
{
    if (count == 0)
    {
        if (self.uploadButtonContainer.hidden)
        {
            // No-op
        }
        else
        {
            // Hide the upload button - slide out from bottom

            [UIView animateWithDuration:0.2f
                             animations: ^{
                [self moveUploadButtonContainerOffscreen:YES];
            } completion: ^(BOOL finished) {
                if (finished)
                {
                    self.uploadButtonContainer.hidden = YES;
                }
            }];
        }
    }
    else
    {
        if (self.uploadButtonContainer.hidden)
        {
            // Show thyself - slide up from bottom
            // Ensure we're on top of all our various children

            [self.navigationController.view addSubview:self.uploadButtonContainer];
            [self moveUploadButtonContainerOffscreen:YES];

            self.uploadButtonContainer.hidden = NO;

            [UIView animateWithDuration:0.2f
                             animations: ^{
                [self moveUploadButtonContainerOffscreen:NO];
            }];
        }

        if (count > self.maxFiles && self.maxFiles != 0)
        {
            NSString *title;

            [self.uploadButton setEnabled:NO];

            if (self.maxFiles == 1)
            {
                title = @"Maximum 1 file";
            }
            else
            {
                title = [NSString stringWithFormat:@"Maximum %ld files", (long)self.maxFiles];
            }

            [self.uploadButton setTitle:title
                               forState:UIControlStateDisabled];

            [self.uploadButton setTitleColor:ANGRY_COLOR
                                    forState:UIControlStateDisabled];
        }
        else
        {
            NSString *title;

            [self.uploadButton setEnabled:YES];

            if (count == 1)
            {
                title = @"Upload 1 file";
            }
            else
            {
                title = [NSString stringWithFormat:@"Upload %ld files", (long)count];
            }

            [self.uploadButton setTitle:title
                               forState:UIControlStateNormal];
        }
    }
}

- (void)uploadButtonTapped:(id)sender
{
    [self.uploadButton setEnabled:NO];

    [self.uploadButton setTitleColor:HAPPY_COLOR
                            forState:UIControlStateDisabled];

    [self.uploadButton setTitle:@"Uploading files"
                       forState:UIControlStateDisabled];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSAssert(NO, @"This method must be implemented by subclasses.");

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"This method must be implemented by subclasses.");

    return nil;
}

#pragma mark - Private Methods

- (void)moveUploadButtonContainerOffscreen:(BOOL)shouldHide
{
    CGSize screenSize = [UIApplication FPCurrentSize];

    CGRect frame = CGRectMake(0,
                              screenSize.height,
                              screenSize.width,
                              UPLOAD_BUTTON_CONTAINER_HEIGHT);

    if (!shouldHide)
    {
        frame.origin.y -= UPLOAD_BUTTON_CONTAINER_HEIGHT;
    }

    self.uploadButtonContainer.frame = frame;
}

@end
