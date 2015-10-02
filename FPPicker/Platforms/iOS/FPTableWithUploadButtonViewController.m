//
//  FPTableWithUploadButtonViewController.m
//  FPPicker
//
//  Created by Brett van Zuiden on 12/3/13.
//  Copyright (c) 2013 Filepicker.io. All rights reserved.
//

#import "FPTableWithUploadButtonViewController.h"
#import "FPBarButtonItem.h"

@interface FPTableWithUploadButtonViewController ()

@property (nonatomic, strong) UIBarButtonItem *uploadBarButton;

@end

@implementation FPTableWithUploadButtonViewController

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
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

        UIBarButtonItem *flexibleSpace;

        flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                      target:nil
                                                                      action:nil];

        self.navigationController.toolbarHidden = YES;

        self.uploadBarButton = [[UIBarButtonItem alloc]initWithTitle:@""
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(uploadButtonTapped:)];

        self.toolbarItems = @[flexibleSpace, self.uploadBarButton, flexibleSpace];
        [self setToolbarTintColor:[FPBarButtonItem appearance].happyTextColor];

        self.navigationController.toolbar.barTintColor = [FPBarButtonItem appearance].backgroundColor;
    }
}

- (void)setToolbarTintColor:(UIColor*)color
{
    self.navigationController.toolbar.tintColor = color;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideUploadButton];
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
        if (self.navigationController.toolbarHidden)
        {
            // No-op
        }
        else
        {
            [self hideUploadButton];
        }
    }
    else
    {
        if (self.navigationController.toolbarHidden)
        {
            // Show thyself - slide up from bottom
            // Ensure we're on top of all our various children

            self.navigationController.toolbarHidden = YES;

            [UIView animateWithDuration:0.2f
                             animations: ^
            {
                self.navigationController.toolbarHidden = NO;
            }];
        }

        if (count > self.maxFiles && self.maxFiles != 0)
        {
            NSString *title;

            [self.uploadBarButton setEnabled:NO];

            if (self.maxFiles == 1)
            {
                title = @"Maximum 1 file";
            }
            else
            {
                title = [NSString stringWithFormat:@"Maximum %ld files", (long)self.maxFiles];
            }


            [self.uploadBarButton setTitle:title];
            [self setToolbarTintColor:[FPBarButtonItem appearance].angryTextColor];
        }
        else
        {
            NSString *title;

            [self.uploadBarButton setEnabled:YES];

            if (count == 1)
            {
                title = @"Upload 1 file";
            }
            else
            {
                title = [NSString stringWithFormat:@"Upload %ld files", (long)count];
            }

            [self.uploadBarButton setTitle:title];
            [self setToolbarTintColor:[FPBarButtonItem appearance].happyTextColor];
        }
    }
}

- (void)uploadButtonTapped:(id)sender
{
    [self.uploadBarButton setEnabled:NO];

    [self setToolbarTintColor:[FPBarButtonItem appearance].happyTextColor];

    [self.uploadBarButton setTitle:@"Uploading files"];
}

- (void)hideUploadButton
{
    [UIView animateWithDuration:0.2f
                     animations: ^
    {
        self.navigationController.toolbarHidden = YES;
    }];
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

@end
