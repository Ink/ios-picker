//
//  FPTableWithUploadButtonViewController.m
//  FPPicker
//
//  Created by Brett van Zuiden on 12/3/13.
//  Copyright (c) 2013 Filepicker.io. All rights reserved.
//

#import "FPTableWithUploadButtonViewController.h"
#import "UIApplication+FPAppDimensions.h"

@interface FPTableWithUploadButtonViewController ()

@property (nonatomic, strong) UIBarButtonItem *uploadBarButton;

@end

@implementation FPTableWithUploadButtonViewController

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
        [self setUploadButtonColor:HAPPY_COLOR];
    }
}

-(void)setUploadButtonColor:(UIColor*)color{
    NSDictionary *colorAttribute  = [NSDictionary dictionaryWithObject: color
                                                                     forKey: NSForegroundColorAttributeName];
    
    [self.uploadBarButton setTitleTextAttributes:colorAttribute forState:UIControlStateNormal];
    [self.uploadBarButton setTitleTextAttributes:colorAttribute forState:UIControlStateDisabled];
    
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
            [self setUploadButtonColor:ANGRY_COLOR];

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
            [self setUploadButtonColor:HAPPY_COLOR];
        }
    }
}

- (void)uploadButtonTapped:(id)sender
{
    [self.uploadBarButton setEnabled:NO];
    
    [self setUploadButtonColor:HAPPY_COLOR];

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
