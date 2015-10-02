//
//  FPSourceListController.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io. All rights reserved.
//

#import "FPSourceListController.h"
#import "FPInternalHeaders.h"
#import "FPLocalAlbumController.h"
#import "FPSourceController.h"
#import "FPSaveSourceController.h"
#import "FPSaveController.h"
#import "FPSearchController.h"
#import "FPInfoViewController.h"
#import "FPImagePickerController.h"
#import "FPSource+SupportedSources.h"
#import "FPTableViewCell.h"

@implementation FPSourceListController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupNavigationButtons];
    [self setupSourceList];
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

#pragma mark - UITableViewDataSource Methods

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
    FPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        cell = [[FPTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier :CellIdentifier];

        cell.selectionStyle = UITableViewCellSelectionStyleDefault;

        UIView *bgColorView = [UIView new];
        bgColorView.backgroundColor = [FPTableViewCell appearance].selectedBackgroundColor;
        cell.selectedBackgroundView = bgColorView;
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

    cell.imageView.image = [[UIImage imageWithContentsOfFile:imageFilePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

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

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Selecting %d", indexPath.row);

    NSString *sourceCategory = [self.sources allKeys][indexPath.section];
    FPSource *source = self.sources[sourceCategory][indexPath.row];

    //NSLog(@"Source %@", source);

    if (source.identifier == FPSourceCamera)
    {
        if ([FPImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            FPImagePickerController *imgPicker = [FPImagePickerController new];

            imgPicker.delegate = self.imageDelegate;
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imgPicker.source = source;

            if ([self.fpdelegate isKindOfClass:[FPPickerController class]])
            {
                FPPickerController *picker = (FPPickerController *)self.fpdelegate;

                //FPImagePickerController Properties

                NSArray *allMediaTypes =
                    [FPImagePickerController availableMediaTypesForSourceType:imgPicker.sourceType];

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

                    NSArray *videos = @[@"video/quicktime"];

                    if ([self mimetypeCheck:videos
                                    against:self.dataTypes])
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
                imgPicker.disableFrontCameraLivePreviewMirroring = picker.disableFrontCameraLivePreviewMirroring;
            }

            [self presentViewController:imgPicker
                               animated:YES
                             completion:nil];
        }
        else
        {
            NSString *errorTitle = @"No Camera Available";
            NSString *errorMessage = @"This device doesn't seem to have a camera available.";

            if (![FPUtils currentAppIsAppExtension])
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:errorTitle
                                                                               message:errorMessage
                                                                        preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault
                                                           handler: ^(UIAlertAction * action)
                {
                    [tableView deselectRowAtIndexPath:indexPath
                                             animated:NO];
                }];

                [alert addAction:ok];

                [self presentViewController:alert
                                   animated:YES
                                 completion:nil];
            }
            else
            {
                NSForceLog(@"ERROR: %@", errorMessage);

                [tableView deselectRowAtIndexPath:indexPath
                                         animated:NO];
            }
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

            sView.source = source;
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

        sView.source = source;
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

        sView.source = source;
        sView.fpdelegate = self.fpdelegate;
        sView.selectMultiple = self.selectMultiple;
        sView.maxFiles = self.maxFiles;

        [self.navigationController pushViewController:sView
                                             animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self.fpdelegate sourceControllerDidCancel:nil];
}

- (IBAction)displayInfo:(id)sender
{
    FPInfoViewController *info = [FPInfoViewController new];

    [self.navigationController pushViewController:info
                                         animated:YES];
}

#pragma mark - Private Methods

- (BOOL)mimetypeCheck:(NSArray *)mimes1
              against:(NSArray *)mimes2
{
    if (mimes1.count == 0 ||
        mimes2.count == 0)
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

- (void)setupNavigationButtons
{
    // Set the text of back button to be "back", regardless of title.

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancel:)];

    self.navigationItem.leftBarButtonItem = cancelButton;

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];

    [infoButton addTarget:self
                   action:@selector(displayInfo:)
         forControlEvents:UIControlEventTouchUpInside];

    infoButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
}

- (NSArray *)filterSourceList
{
    NSArray *allSources = [FPSource allMobileSources];
    NSMutableArray *filteredSource = [NSMutableArray array];

    for (NSString* identifier in self.sourceNames)
    {
        for (FPSource *source in allSources)
        {
            if ([source.identifier isEqualToString:identifier])
            {
                [filteredSource addObject:source];
            }
        }
    }

    return filteredSource;
}

- (void)setupSourceList
{
    NSMutableArray *localSources = [NSMutableArray array];
    NSMutableArray *remoteSources = [NSMutableArray array];

    NSArray *activeSources;

    if (self.sourceNames)
    {
        activeSources = [self filterSourceList];
    }
    else
    {
        activeSources = [FPSource allMobileSources];
    }

    for (FPSource *source in activeSources)
    {
        NSArray *sourceMimetypes;

        if ([self.fpdelegate isKindOfClass:[FPSaveController class]])
        {
            sourceMimetypes = source.saveMimetypes;
        }
        else
        {
            sourceMimetypes = source.openMimetypes;
        }

        if ([self mimetypeCheck:sourceMimetypes
                        against:self.dataTypes])
        {
            source.mimetypes = self.dataTypes;

            if (source.identifier == FPSourceCamera ||
                source.identifier == FPSourceCameraRoll)
            {
                [localSources addObject:source];
            }
            else
            {
                [remoteSources addObject:source];
            }
        }
    }

    if (!self.dataTypes)
    {
        self.dataTypes = @[@"*/*"];
    }

    NSString *remoteTitle = @"Cloud";

    if (!self.title)
    {
        [self setTitle:@"Filepicker.io"];
    }
    else
    {
        remoteTitle = @"Cloud via Filepicker.io";
    }

    NSMutableDictionary *mSources = [NSMutableDictionary dictionary];

    if (localSources.count > 0)
    {
        mSources[@"Local"] = [localSources copy];
    }

    if (remoteSources.count > 0)
    {
        mSources[remoteTitle] = [remoteSources copy];
    }

    self.sources = [mSources copy];

    if (localSources.count + remoteSources.count == 0)
    {
        //No services

        UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 200, 200, 20)];

        emptyLabel.textColor = [UIColor grayColor];
        emptyLabel.text = @"No Services Available";

        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self.view addSubview:emptyLabel];
    }
}

@end
