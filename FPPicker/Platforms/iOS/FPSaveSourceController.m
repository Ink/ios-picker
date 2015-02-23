//
//  FPSaveSourceController.m
//  FPPicker
//
//  Created by Liyan David Chang on 7/8/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPSaveSourceController.h"
#import "FPInternalHeaders.h"

@interface FPSaveSourceController ()

@property (strong) UITextField *textField;
@property (strong) UIBarButtonItem *saveButton;

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

    if ((self.source.identifier == FPSourceFacebook ||
         self.source.identifier == FPSourcePicasa) &&
        [self.path isEqualToString:[NSString stringWithFormat:@"%@/", self.source.rootPath]])
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

-(void)fileSelectedAtIndex:(NSInteger)index
                   forView:(UIView*)view
             withThumbnail:(UIImage *)thumbnail
{
    //do nothing - user can select only directory
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
    [super viewDidAppear:animated];

    FPSaveController *fpsave = (FPSaveController *)self.fpdelegate;

    if (fpsave.proposedFilename)
    {
        self.textField.text = fpsave.proposedFilename;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (self.textField.text)
    {
        FPSaveController *fpsave = (FPSaveController *)self.fpdelegate;
        fpsave.proposedFilename = self.textField.text;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
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
    [self.fpdelegate sourceController:self
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
        subController.source = self.source;
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
    if (self.source.overwritePossible)
    {
        // If it can overwite, warn the user.

        for (NSMutableDictionary *obj in self.contents)
        {
            FPSaveController *saveC = (FPSaveController *)self.fpdelegate;
            NSString *proposedName = [self.textField.text stringByAppendingString:[saveC getExtensionString]];

            if ([obj[@"filename"] isEqualToString:proposedName])
            {
                self.saveButton.title = @"Overwrite";
                self.saveButton.tintColor = [UIColor redColor];

                CGRect frameRect = self.textField.frame;

                frameRect.size.width = 183;

                self.textField.frame = frameRect;

                return;
            }
        }

        // Reset to default

        self.saveButton.title = @"Save";
        self.saveButton.tintColor = nil;

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

- (void)pushDirectoryControllerForPath:(NSString*)path{
    FPSaveSourceController *subController = [FPSaveSourceController new];
    
    subController.path = path;
    subController.source = self.source;
    subController.fpdelegate = self.fpdelegate;
    subController.selectMultiple = self.selectMultiple;
    subController.maxFiles = self.maxFiles;
    
    [self.navigationController pushViewController:subController
                                         animated:YES];
}

@end
