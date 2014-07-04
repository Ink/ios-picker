//
//  FPSourceListController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import "FPSourceListController.h"
#import "FPUtils.h"
#import "FPLocalAlbumController.h"
#import "FPSourceController.h"
#import "FPSaveSourceController.h"
#import "FPSaveController.h"
#import "FPSearchController.h"
#import "FPInfoViewController.h"

@implementation FPSourceListController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the text of back button to be "back", regardless of title.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];

    [btn addTarget:self
               action:@selector(infoButtonRequest)
     forControlEvents:UIControlEventTouchUpInside];

    btn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    //NSLog(@"sources: %@", sourceNames);

    if (!self.sourceNames)
    {
        self.sourceNames = @[
            FPSourceCamera,
            FPSourceCameraRoll,
            FPSourceDropbox,
            FPSourceFacebook,
            FPSourceGmail,
            FPSourceBox,
            FPSourceGithub,
            FPSourceGoogleDrive,
            FPSourceInstagram,
            FPSourceFlickr,
            FPSourceEvernote,
            FPSourcePicasa,
            FPSourceSkydrive,
            FPSourceImagesearch
                           ];
    }

    if (!self.dataTypes)
    {
        self.dataTypes = @[@"*/*"];
    }

    NSMutableArray *local = [NSMutableArray array];
    NSMutableArray *cloud = [NSMutableArray array];

    for (NSString *source in self.sourceNames)
    {
        FPSource *sourceObj = [FPSource new];

        sourceObj.identifier = source;

        if (source == FPSourceCamera)
        {
            sourceObj.name = @"Camera";
            sourceObj.icon = @"glyphicons_011_camera";
            sourceObj.rootUrl = @"/Camera";
            sourceObj.open_mimetypes = @[@"video/quicktime", @"image/jpeg", @"image/png"];
            sourceObj.save_mimetypes = @[]; // TODO: Really needed?
            sourceObj.overwritePossible = NO;
            sourceObj.externalDomains = @[]; // TODO: Really needed?
        }
        else if (source == FPSourceCameraRoll)
        {
            sourceObj.name = @"Albums";
            sourceObj.icon = @"glyphicons_008_film";
            sourceObj.rootUrl = @"/Albums";
            sourceObj.open_mimetypes = @[@"image/jpeg", @"image/png", @"video/quicktime"];
            sourceObj.save_mimetypes = @[@"image/jpeg", @"image/png"];
            sourceObj.overwritePossible = NO;
            sourceObj.externalDomains = @[]; // TODO: Really needed?
        }
        else if (source == FPSourceBox)
        {
            sourceObj.name = @"Box";
            sourceObj.icon = @"glyphicons_sb2_box";
            sourceObj.rootUrl = @"/Box";
            sourceObj.open_mimetypes = @[@"*/*"];
            sourceObj.save_mimetypes = @[@"*/*"];
            sourceObj.overwritePossible = YES;
            sourceObj.externalDomains = @[@"https://www.box.com"];
        }
        else if (source == FPSourceDropbox)
        {
            sourceObj.name = @"Dropbox";
            sourceObj.icon = @"glyphicons_361_dropbox";
            sourceObj.rootUrl = @"/Dropbox";
            sourceObj.open_mimetypes = @[@"*/*"];
            sourceObj.save_mimetypes = @[@"*/*"];
            sourceObj.overwritePossible = YES;
            sourceObj.externalDomains = @[@"https://www.dropbox.com"];
        }
        else if (source == FPSourceFacebook)
        {
            sourceObj.name = @"Facebook";
            sourceObj.icon = @"glyphicons_390_facebook";
            sourceObj.rootUrl = @"/Facebook";
            sourceObj.open_mimetypes = @[@"image/jpeg"];
            sourceObj.save_mimetypes = @[@"image/*"];
            sourceObj.overwritePossible = NO;
            sourceObj.externalDomains = @[@"https://www.facebook.com"];
        }
        else if (source == FPSourceGithub)
        {
            sourceObj.name = @"Github";
            sourceObj.icon = @"glyphicons_381_github";
            sourceObj.rootUrl = @"/Github";
            sourceObj.open_mimetypes = @[@"*/*"];
            sourceObj.save_mimetypes = @[]; // TODO: Really needed?
            sourceObj.overwritePossible = NO;
            sourceObj.externalDomains = @[@"https://www.github.com"];
        }
        else if (source == FPSourceGmail)
        {
            sourceObj.name = @"Gmail";
            sourceObj.icon = @"glyphicons_sb1_gmail";
            sourceObj.rootUrl = @"/Gmail";
            sourceObj.open_mimetypes = @[@"*/*"];
            sourceObj.save_mimetypes = @[]; // TODO: Really needed?
            sourceObj.overwritePossible = NO;
            sourceObj.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];
        }
        else if (source == FPSourceImagesearch)
        {
            sourceObj.name = @"Web Images";
            sourceObj.icon = @"glyphicons_027_search";
            sourceObj.rootUrl = @"/Imagesearch";
            sourceObj.open_mimetypes = @[@"image/jpeg"];
            sourceObj.save_mimetypes = @[]; // TODO: Really needed?
            sourceObj.overwritePossible = NO;
            sourceObj.externalDomains = @[]; // TODO: Really needed?
        }
        else if (source == FPSourceGoogleDrive)
        {
            sourceObj.name = @"Google Drive";
            sourceObj.icon = @"GoogleDrive";
            sourceObj.rootUrl = @"/GoogleDrive";
            sourceObj.open_mimetypes = @[@"*/*"];
            sourceObj.save_mimetypes = @[@"*/*"];
            sourceObj.overwritePossible = NO;
            sourceObj.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];
        }
        else if (source == FPSourceFlickr)
        {
            sourceObj.name = @"Flickr";
            sourceObj.icon = @"glyphicons_395_flickr";
            sourceObj.rootUrl = @"/Flickr";
            sourceObj.open_mimetypes = @[@"image/*"];
            sourceObj.save_mimetypes = @[@"image/*"];
            sourceObj.overwritePossible = NO;
            sourceObj.externalDomains = @[@"https://*.flickr.com", @"http://*.flickr.com"];
        }
        else if (source == FPSourcePicasa)
        {
            sourceObj.name = @"Picasa";
            sourceObj.icon = @"glyphicons_366_picasa";
            sourceObj.rootUrl = @"/Picasa";
            sourceObj.open_mimetypes = @[@"image/*"];
            sourceObj.save_mimetypes = @[@"image/*"];
            sourceObj.overwritePossible = YES;
            sourceObj.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];
        }
        else if (source == FPSourceInstagram)
        {
            sourceObj.name = @"Instagram";
            sourceObj.icon = @"Instagram";
            sourceObj.rootUrl = @"/Instagram";
            sourceObj.open_mimetypes = @[@"image/jpeg"];
            sourceObj.save_mimetypes = @[]; // TODO: Really needed?
            sourceObj.overwritePossible = YES;
            sourceObj.externalDomains = @[@"https://www.instagram.com",  @"https://instagram.com"];
        }
        else if (source == FPSourceSkydrive)
        {
            sourceObj.name = @"OneDrive";
            sourceObj.icon = @"glyphicons_sb3_skydrive";
            sourceObj.rootUrl = @"/OneDrive";
            sourceObj.open_mimetypes = @[@"*/*"];
            sourceObj.save_mimetypes = @[@"*/*"];
            sourceObj.overwritePossible = YES;
            sourceObj.externalDomains = @[@"https://login.live.com",  @"https://skydrive.live.com"];
        }
        else if (source == FPSourceEvernote)
        {
            sourceObj.name = @"Evernote";
            sourceObj.icon = @"glyphicons_371_evernote";
            sourceObj.rootUrl = @"/Evernote";
            sourceObj.open_mimetypes = @[@"*/*"];
            sourceObj.save_mimetypes = @[@"*/*"];
            sourceObj.overwritePossible = YES;
            sourceObj.externalDomains = @[@"https://www.evernote.com",  @"https://evernote.com"];
        }

        NSArray *source_mimetypes;

        if ([self.fpdelegate class] == [FPSaveController class])
        {
            source_mimetypes = sourceObj.save_mimetypes;
        }
        else
        {
            source_mimetypes = sourceObj.open_mimetypes;
        }

        if ([self mimetypeCheck:source_mimetypes
                        against:self.dataTypes])
        {
            sourceObj.mimetypes = self.dataTypes;

            if (source == FPSourceCamera ||
                source == FPSourceCameraRoll)
            {
                [local addObject:sourceObj];
            }
            else
            {
                [cloud addObject:sourceObj];
            }
        }
    }

    NSString *cloudTitle = @"Cloud";

    if (!self.title)
    {
        [self setTitle:@"Filepicker.io"];
    }
    else
    {
        cloudTitle = @"Cloud via Filepicker.io";
    }


    self.sources = [NSMutableDictionary dictionary];

    if (local.count > 0)
    {
        self.sources[@"local"] = local;
    }

    if (cloud.count > 0)
    {
        self.sources[cloudTitle] = cloud;
    }

    if (local.count + cloud.count == 0)
    {
        //No services
        UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 200, 200, 20)];

        [emptyLabel setTextColor:[UIColor grayColor]];
        emptyLabel.text = @"No Services Available";

        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self.view addSubview:emptyLabel];
    }


    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(cancelButtonRequest:)];

    self.navigationItem.leftBarButtonItem = anotherButton;
}

- (void)viewDidUnload
{
    self.sourceNames = nil;
    self.sources = nil;
    self.fpdelegate = nil;
    self.imageDelegate = nil;
    self.dataTypes = nil;

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sources.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.sources.count <= 1)
    {
        return nil;
    }
    else
    {
        return [self.sources allKeys][section];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sourceCategory = [self.sources allKeys][section];

    return [self.sources[sourceCategory] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = fpCellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }

    NSString *sourceCategory = [self.sources allKeys][indexPath.section];
    FPSource *source = self.sources[sourceCategory][indexPath.row];

    cell.textLabel.text = source.name;

    if ([self.fpdelegate class] == [FPSaveController class] &&
        source.identifier == FPSourceCameraRoll)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSString *imageFilePath = [[FPUtils frameworkBundle] pathForResource:source.icon
                                                                  ofType:@"png"];

    cell.imageView.image = [UIImage imageWithContentsOfFile:imageFilePath];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Selecting %d", indexPath.row);

    NSString *sourceCategory = [self.sources allKeys][indexPath.section];
    FPSource *source = self.sources[sourceCategory][indexPath.row];

    //NSLog(@"Source %@", source);

    if (source.identifier == FPSourceCamera)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imgPicker = [UIImagePickerController new];

            imgPicker.delegate = self.imageDelegate;
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;

            if ([self.fpdelegate isKindOfClass:[FPPickerController class]])
            {
                FPPickerController *picker = (FPPickerController *)self.fpdelegate;

                //UIImagePickerController Properties

                NSArray *allMediaTypes =
                    [UIImagePickerController availableMediaTypesForSourceType:imgPicker.sourceType];

                NSMutableArray *wantedMediaTypes = [NSMutableArray array];

                NSLog(@"ALL TYPES: %@", allMediaTypes);

                if ([allMediaTypes containsObject:(NSString *)kUTTypeImage])
                {
                    NSLog(@"CAN DO IMAGES");

                    NSArray *images = @[@"image/jpeg", @"image/png"];

                    NSLog(@"SHOULD DO IMAGES");

                    if ([self mimetypeCheck:images
                                    against:self.dataTypes])
                    {
                        [wantedMediaTypes addObject:(NSString *)kUTTypeImage];
                    }
                }

                if ([allMediaTypes containsObject:(NSString *)kUTTypeMovie])
                {
                    NSLog(@"CAN DO VIDEO");

                    if ([self.dataTypes containsObject:(NSString *)@"video/quicktime"])
                    {
                        NSLog(@"SHOULD DO VIDEO");
                        [wantedMediaTypes addObject:(NSString *)kUTTypeMovie];
                    }
                }

                imgPicker.mediaTypes = wantedMediaTypes;
                imgPicker.allowsEditing = picker.allowsEditing;
                imgPicker.videoQuality = picker.videoQuality;
                imgPicker.videoMaximumDuration = picker.videoMaximumDuration;
                imgPicker.showsCameraControls = picker.showsCameraControls;
                imgPicker.cameraOverlayView = picker.cameraOverlayView;
                imgPicker.cameraViewTransform = picker.cameraViewTransform;
                imgPicker.cameraDevice = picker.cameraDevice;
                imgPicker.cameraFlashMode = picker.cameraFlashMode;
            }

            [[UIApplication sharedApplication] setStatusBarHidden:YES];

            [self presentViewController:imgPicker
                               animated:YES
                             completion:nil];
        }
        else
        {
            UIAlertView *alertView;

            alertView = [[UIAlertView alloc] initWithTitle:@"No Camera Available"
                                                   message:@"This device doesn't seem to have a camera available."
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
            [alertView show];
        }
    }
    else if (source.identifier == FPSourceCameraRoll)
    {
        if ([self.fpdelegate class] == [FPSaveController class])
        {
            FPSaveController *saveC = (FPSaveController *)self.fpdelegate;

            [saveC saveFileLocally];
        }
        else
        {
            FPLocalAlbumController *sView = [FPLocalAlbumController new];

            sView.sourceType = source;
            sView.fpdelegate = self.fpdelegate;
            sView.selectMultiple = self.selectMultiple;
            sView.maxFiles = self.maxFiles;

            [self.navigationController pushViewController:sView
                                                 animated:NO];
        }
    }
    else if (source.identifier == FPSourceImagesearch)
    {
        FPSearchController *sView = [FPSearchController new];

        sView.sourceType = source;
        sView.fpdelegate = self.fpdelegate;
        sView.selectMultiple = self.selectMultiple;
        sView.maxFiles = self.maxFiles;

        [self.navigationController pushViewController:sView
                                             animated:NO];
    }
    else
    {
        FPSourceController *sView;

        if ([self.fpdelegate class] == [FPSaveController class])
        {
            sView = [FPSaveSourceController new];
        }
        else
        {
            sView = [FPSourceController new];
        }

        sView.sourceType = source;
        sView.fpdelegate = self.fpdelegate;
        sView.selectMultiple = self.selectMultiple;
        sView.maxFiles = self.maxFiles;

        [self.navigationController pushViewController:sView
                                             animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.contentSizeForViewInPopover = fpWindowSize;

    [super viewWillAppear:animated];
}

- (BOOL)mimetypeCheck:(NSArray *)mimes1 against:(NSArray *)mimes2
{
    if (mimes1.count == 0 || mimes2.count == 0)
    {
        return NO;
    }

    for (NSString *mimetype1 in mimes1)
    {
        for (NSString *mimetype2 in mimes2)
        {
            if ([mimetype1 isEqualToString:@"*/*"] ||
                [mimetype2 isEqualToString:@"*/*"])
            {
                return YES;
            }

            if ([mimetype1 isEqualToString:mimetype2])
            {
                return YES;
            }

            NSArray *splitType1 = [mimetype1 componentsSeparatedByString:@"/"];
            NSArray *splitType2 = [mimetype2 componentsSeparatedByString:@"/"];

            if ([splitType1[0] isEqualToString:splitType2[0]])
            {
                return YES;
            }
        }
    }

    return NO;
}

- (void)cancelButtonRequest:(id)sender
{
    NSLog(@"Cancel Button Pressed on Source List");

    [self.fpdelegate FPSourceControllerDidCancel:nil];
}

- (void)infoButtonRequest
{
    NSLog(@"Info Button Pressed on Source List");

    FPInfoViewController *info = [FPInfoViewController new];

    [self.navigationController pushViewController:info
                                         animated:YES];
}

@end
