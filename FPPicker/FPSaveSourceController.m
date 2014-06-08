//
//  FPSaveSourceController.m
//  FPPicker
//
//  Created by Liyan David Chang on 7/8/12.
//  Copyright (c) 2012 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPSaveSourceController.h"

@interface FPSaveSourceController ()

@property (strong) UITextField *textField;
@property (strong) UIBarButtonItem* saveButton;

@end

@implementation FPSaveSourceController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];

    if (self)
    {
        // Custom initialization
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *flexibleSpace;

    flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                  target:nil
                                                                  action:nil];

    NSLog(@"Source: %@ Path: %@ %@", self.sourceType.identifier, self.path, [NSString stringWithFormat:@"%@/", self.sourceType.rootUrl]);

    if ((self.sourceType.identifier == FPSourceFacebook ||
         self.sourceType.identifier == FPSourcePicasa) &&
        [self.path isEqualToString:[NSString stringWithFormat:@"%@/", self.sourceType.rootUrl]])
    {
        NSLog(@"SPECIAL");

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200, 21.0)];

        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold"
                                          size:18];

        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = @"Choose an Album";
        titleLabel.textAlignment = NSTextAlignmentCenter;

        UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];

        self.toolbarItems = @[flexibleSpace, title, flexibleSpace];
    }
    else
    {
        FPSaveController *fpsave = (FPSaveController *)self.fpdelegate;

        self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                           style:UIBarButtonItemStyleDone
                                                          target:self
                                                          action:@selector(saveAction:)];

        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 210, 31)];

        self.textField.placeholder = @"filename";
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.clipsToBounds = YES;
        self.textField.delegate = self;

        if (fpsave.proposedFilename)
        {
            self.textField.text = fpsave.proposedFilename;
        }

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 24)];

        label.text = [fpsave getExtensionString];
        label.textColor = [UIColor grayColor];

        self.textField.rightViewMode = UITextFieldViewModeAlways;
        self.textField.rightView = label;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.borderStyle = UITextBorderStyleRoundedRect;

        UIBarButtonItem *filename = [[UIBarButtonItem alloc] initWithCustomView:self.textField];

        self.toolbarItems = @[flexibleSpace, filename, self.saveButton];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.toolbarHidden = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.textField];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    FPSaveController *fpsave = (FPSaveController *)self.fpdelegate;

    if (fpsave.proposedFilename)
    {
        self.textField.text = fpsave.proposedFilename;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.textField.text)
    {
        FPSaveController *fpsave = (FPSaveController *)self.fpdelegate;
        fpsave.proposedFilename = self.textField.text;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (fpDEVICE_TYPE == fpDEVICE_TYPE_IPHONE)
    {
        [UIView beginAnimations:nil
                        context:NULL];

        [UIView setAnimationDuration:0.3];

        CGRect frame = self.navigationController.toolbar.frame;

        frame.origin.y -= 216;

        self.navigationController.toolbar.frame = frame;

        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (fpDEVICE_TYPE == fpDEVICE_TYPE_IPHONE)
    {
        [UIView beginAnimations:nil
                        context:NULL];

        [UIView setAnimationDuration:0.3];

        CGRect frame = self.navigationController.toolbar.frame;

        frame.origin.y += 216;

        self.navigationController.toolbar.frame = frame;

        [UIView commitAnimations];
    }
}

- (void)saveAction:(id)sender
{
    [self.fpdelegate FPSourceController:self
                   didPickMediaWithInfo:nil];

    NSLog(@"Path %@", self.path);

    FPSaveController *saveC = (FPSaveController *)self.fpdelegate;

    [saveC saveFileName:self.textField.text
                     To:self.path];
}

- (void)objectSelectedAtIndex:(NSInteger)index
{
    NSMutableDictionary *obj = self.contents[index];

    if (YES == [obj[@"is_dir"] boolValue])
    {
        FPSaveSourceController *subController = [FPSaveSourceController new];

        subController.path = obj[@"link_path"];
        subController.sourceType = self.sourceType;
        subController.fpdelegate = self.fpdelegate;

        [self.navigationController pushViewController:subController
                                             animated:YES];

        return;
    }
    else
    {
        self.textField.text = [obj[@"filename"] stringByDeletingPathExtension];

        [self textFieldDidChange:self.textField];
    }

    NSLog(@"selected");

    return;
}

- (void)objectSelectedAtIndex:(NSInteger)index withThumbnail:(UIImage *)thumbnail
{
    [self objectSelectedAtIndex:index];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self saveAction:nil];

    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    [self updateTextFieldButton];
}

- (void)updateTextFieldButton
{
    if (self.sourceType.overwritePossible)
    {
        // If it can overwite, warn the user.

        for (NSMutableDictionary *obj in self.contents)
        {
            FPSaveController *saveC = (FPSaveController *) self.fpdelegate;
            NSString* proposedName = [self.textField.text stringByAppendingString:[saveC getExtensionString]];

            if ([obj[@"filename"] isEqualToString:proposedName])
            {
                self.saveButton.title = @"Overwrite";

                if ([fpDEVICE_VERSION doubleValue] >= 5.0)
                {
                    self.saveButton.tintColor = [UIColor redColor];
                }

                CGRect frameRect = self.textField.frame;

                frameRect.size.width = 183;

                self.textField.frame = frameRect;

                return;
            }
        }

        // Reset to default

        self.saveButton.title = @"Save";

        if ([fpDEVICE_VERSION doubleValue] >= 5.0)
        {
            NSLog(@">=version5");

            self.saveButton.tintColor = nil;
        }

        CGRect frameRect = self.textField.frame;

        frameRect.size.width = 210;

        self.textField.frame = frameRect;
    }
}

- (void)afterReload
{
    [self updateTextFieldButton];
    [super afterReload];
}

@end
