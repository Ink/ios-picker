//
//  FPInfoViewController.m
//  FPPicker
//
//  Created by Liyan David Chang on 1/7/13.
//  Copyright (c) 2013 Filepicker.io. All rights reserved.
//

#import "FPInfoViewController.h"

@implementation FPInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];

    if (self)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"About Filepicker.io";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGRect bounds = self.view.bounds;

    self.view.backgroundColor = [UIColor whiteColor];


    // Logo

    NSString *logoFilePath = [[FPUtils frameworkBundle] pathForResource:@"logo_small"
                                                                 ofType:@"png"];

    UIImage *logo = [UIImage imageWithContentsOfFile:logoFilePath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:logo];

    [self.view addSubview:imageView];

    CGPoint center = CGPointMake(self.view.center.x, logo.size.height);
    imageView.center = center;

    // Description

    UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,
                                                                      CGRectGetMaxY(imageView.frame),
                                                                      CGRectGetWidth(bounds) - 24,
                                                                      200)];
    headingLabel.tag = -1;
    headingLabel.textColor = [UIColor grayColor];
    headingLabel.font = [UIFont systemFontOfSize:15];
    headingLabel.textAlignment = NSTextAlignmentCenter;
    headingLabel.text = @"Filepicker.io is a trusted provider that helps\n applications connect with your content,\n no matter where you store it. \n\nYour information and files are secure and\n your username and password\n are never stored.\n\nMore information at\nhttps://www.filepicker.io";
    headingLabel.numberOfLines = 0;
    headingLabel.lineBreakMode = NSLineBreakByWordWrapping;

    [self.view addSubview:headingLabel];


    // Footer

    UILabel *legalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    CGRectGetHeight(bounds) - 30,
                                                                    CGRectGetWidth(bounds),
                                                                    30)];

    legalLabel.textColor = [UIColor grayColor];
    legalLabel.font = [UIFont systemFontOfSize:12];
    legalLabel.textAlignment = NSTextAlignmentCenter;
    legalLabel.text = @"Filepicker.io 2012, 2013";

    [self.view addSubview:legalLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
