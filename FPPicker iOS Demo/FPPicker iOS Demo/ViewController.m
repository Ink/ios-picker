//
//  ViewController.m
//  FPPicker iOS Demo
//
//  Created by Ruben Nine on 13/06/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "ViewController.h"

@import FPPicker;

@interface ViewController () <FPPickerControllerDelegate,
                              FPSaveControllerDelegate>

@property (nonatomic, retain) FPSaveController *fpSave;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    else
    {
        return YES;
    }
}

- (IBAction)pickerAction:(id)sender
{
    /*
     * Create the object
     */
    FPPickerController *fpController = [FPPickerController new];

    /*
     * Set the delegate
     */
    fpController.fpdelegate = self;

    /*
     * Ask for specific data types. (Optional) Default is all files.
     */
    fpController.dataTypes = @[@"image/*"];
    //fpController.dataTypes = @[@"image/*", @"video/quicktime"];

    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //fpController.sourceNames = [[NSArray alloc] initWithObjects: FPSourceImagesearch, nil];

    /*
     * Enable multselect (Optional) Default is single select
     */
    fpController.selectMultiple = YES;

    /*
     * Specify the maximum number of files (Optional) Default is 0, no limit
     */
    fpController.maxFiles = 5;

    /*
     * Display it.
     */
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:fpController];

    self.myPopoverController = popoverController;
    self.myPopoverController.popoverContentSize = CGSizeMake(320, 520);

    [self.myPopoverController presentPopoverFromRect:[sender frame]
                                              inView:self.view
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
}

- (IBAction)pickerModalAction:(id)sender
{
    /*
     * Create the object
     */
    FPPickerController *fpController = [FPPickerController new];

    /*
     * Set the delegate
     */
    fpController.fpdelegate = self;

    /*
     * Ask for specific data types. (Optional) Default is all files.
     */
    fpController.dataTypes = @[@"image/*"];
    //fpController.dataTypes = [NSArray arrayWithObjects:@"image/*", @"video/quicktime", nil];

    fpController.shouldUpload = YES;

    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //fpController.sourceNames = [[NSArray alloc] initWithObjects: FPSourceImagesearch, nil];

    /*
     * Enable multselect (Optional) Default is single select
     */
    fpController.selectMultiple = YES;

    /*
     * Specify the maximum number of files (Optional) Default is 0, no limit
     */
    fpController.maxFiles = 10;

    /*
     * Display it.
     */
    [self presentViewController:fpController
                       animated:YES
                     completion:nil];
}

- (IBAction)savingAction:(id)sender
{
    UIImage *firstImage;

    if (!self.imageView.image &&
        !self.imageView.animationImages)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Nothing to Save"
                                                          message:@"Select an image first."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];

        [message show];

        return;
    }

    if (self.imageView.image)
    {
        firstImage = self.imageView.image;
    }
    else if (self.imageView.animationImages)
    {
        // For the purposes of our demo, we will simply use the first image

        firstImage = self.imageView.animationImages[0];
    }

    NSData *imgData = UIImagePNGRepresentation(firstImage);

    /*
     * Create the object
     */
    self.fpSave = [FPSaveController new];

    /*
     * Set the delegate
     */
    self.fpSave.fpdelegate = self;

    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //self.fpSave.sourceNames = @[FPSourceDropbox, FPSourceFacebook, FPSourceBox];

    /*
     * Set the data and data type to be saved.
     */
    self.fpSave.data = imgData;
    self.fpSave.dataType = @"image/png";

    /*
     * Display it.
     */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:self.fpSave];

        self.myPopoverController = popoverController;
        self.myPopoverController.popoverContentSize = CGSizeMake(320, 520);

        [self.myPopoverController presentPopoverFromRect:[sender frame]
                                                  inView:self.view
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
    }
    else
    {
        [self presentViewController:self.fpSave
                           animated:YES
                         completion:nil];
    }
}

#pragma mark - FPPickerControllerDelegate Methods

- (void)FPPickerController:(FPPickerController *)pickerController
      didPickMediaWithInfo:(FPMediaInfo *)info
{
}

- (void)       FPPickerController:(FPPickerController *)pickerController
    didFinishPickingMediaWithInfo:(FPMediaInfo *)info
{
    NSLog(@"FILE CHOSEN: %@", info);

    if (info)
    {
        if (info.containsImageAtMediaURL)
        {
            self.imageView.image = [UIImage imageWithContentsOfFile:info.mediaURL.path];
        }

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            [self.myPopoverController dismissPopoverAnimated:YES];
        }

        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
    else
    {
        NSLog(@"Nothing was picked.");
    }
}

- (void)                  FPPickerController:(FPPickerController *)pickerController
    didFinishPickingMultipleMediaWithResults:(NSArray *)results
{
    NSLog(@"FILES CHOSEN: %@", results);

    if (results.count == 0)
    {
        NSLog(@"Nothing was picked.");

        return;
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.myPopoverController dismissPopoverAnimated:YES];
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];

    // Making a little carousel effect with the images

    NSMutableArray *images = [NSMutableArray arrayWithCapacity:results.count];

    for (FPMediaInfo *info in results)
    {
        // Check if uploaded file is an image to add it to carousel

        if (info.containsImageAtMediaURL)
        {
            UIImage *image = [UIImage imageWithContentsOfFile:info.mediaURL.path];

            [images addObject:image];
        }
    }

    self.imageView.animationImages = images;
    self.imageView.animationRepeatCount = 100.f;
    self.imageView.animationDuration = 2.f * images.count; // 2 seconds per image

    [self.imageView startAnimating];
}

- (void)FPPickerControllerDidCancel:(FPPickerController *)pickerController
{
    NSLog(@"FP Cancelled Open");

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.myPopoverController dismissPopoverAnimated:YES];
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - FPSaveControllerDelegate Methods

- (void)        FPSaveController:(FPSaveController *)saveController
    didFinishSavingMediaWithInfo:(FPMediaInfo *)info
{
    NSLog(@"FP finished saving with info %@", info);

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.myPopoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [self.fpSave dismissViewControllerAnimated:YES
                                        completion:nil];
    }
}

- (void)FPSaveControllerDidCancel:(FPSaveController *)saveController
{
    NSLog(@"FP Cancelled Save");

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.myPopoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [self.fpSave dismissViewControllerAnimated:YES
                                        completion:nil];
    }
}

- (void)FPSaveController:(FPSaveController *)saveController
                didError:(NSError *)error
{
    NSLog(@"FP Error: %@", error);
}

@end
