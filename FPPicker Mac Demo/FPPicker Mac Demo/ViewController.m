//
//  ViewController.m
//  FPPicker Mac Demo
//
//  Created by Ruben Nine on 18/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "ViewController.h"
#import "ImageBrowserBackgroundLayer.h"
#import "ImageBrowserItem.h"

@import FPPickerMac;

@interface ViewController () <FPPickerControllerDelegate,
                              FPSaveControllerDelegate>

@property (nonatomic, strong) FPPickerController *pickerController;
@property (nonatomic, strong) FPSaveController *saveController;

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *importedImages;

@end

@implementation ViewController

#pragma mark - Accessors

- (FPPickerController *)pickerController
{
    if (!_pickerController)
    {
        _pickerController = [FPPickerController new];

        _pickerController.delegate = self;
    }

    return _pickerController;
}

- (FPSaveController *)saveController
{
    if (!_saveController)
    {
        _saveController = [FPSaveController new];

        _saveController.delegate = self;
    }

    return _saveController;
}

- (NSMutableArray *)images
{
    if (!_images)
    {
        _images = [NSMutableArray new];
    }

    return _images;
}

- (NSMutableArray *)importedImages
{
    if (!_importedImages)
    {
        _importedImages = [NSMutableArray new];
    }

    return _importedImages;
}

#pragma mark - Public Methods


- (void)awakeFromNib
{
    self.imageBrowser.delegate = self;
    self.imageBrowser.dataSource = self;

    // Allow single selection only

    self.imageBrowser.allowsMultipleSelection = NO;

    // Allow reordering, animations and set the dragging destination delegate.

    self.imageBrowser.allowsReordering = YES;
    self.imageBrowser.animates = YES;

    // customize the appearance

    self.imageBrowser.cellsStyleMask = IKCellsStyleTitled | IKCellsStyleOutlined;

    // background layer

    ImageBrowserBackgroundLayer *backgroundLayer = [ImageBrowserBackgroundLayer new];

    self.imageBrowser.backgroundLayer = backgroundLayer;

    backgroundLayer.owner = self.imageBrowser;

    //-- change default font
    // create a centered paragraph style

    NSMutableParagraphStyle *paraphStyle = [NSMutableParagraphStyle new];

    paraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paraphStyle.alignment = NSCenterTextAlignment;

    NSMutableDictionary *attributes = [NSMutableDictionary new];

    attributes[NSFontAttributeName] = [NSFont systemFontOfSize:12];
    attributes[NSParagraphStyleAttributeName] = paraphStyle;
    attributes[NSForegroundColorAttributeName] = [NSColor blackColor];

    [self.imageBrowser setValue:attributes
                         forKey:IKImageBrowserCellsTitleAttributesKey];

    attributes = [NSMutableDictionary new];

    attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:12];
    attributes[NSParagraphStyleAttributeName] = paraphStyle;
    attributes[NSForegroundColorAttributeName] = [NSColor whiteColor];

    [self.imageBrowser setValue:attributes
                         forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];

    // change intercell spacing

    self.imageBrowser.intercellSpacing = NSMakeSize(10, 80);

    // change selection color

    [self.imageBrowser setValue:[NSColor colorWithCalibratedRed:1 green:0 blue:0.5 alpha:1.0]
                         forKey:IKImageBrowserSelectionColorKey];

    // set initial zoom value

    self.imageBrowser.zoomValue = 0.5;
}

#pragma mark - Actions

- (IBAction)selectImageAction:(id)sender
{
    self.pickerController.sourceNames = @[
        FPSourceDropbox,
        FPSourceFlickr,
        FPSourceGithub,
        FPSourceBox,
        FPSourceGoogleDrive,
        FPSourceSkydrive,
        FPSourceGmail,
        FPSourceImagesearch,
        FPSourceCloudDrive
    ];

    self.pickerController.dataTypes = @[
        @"image/*"
    ];

    [self.pickerController open];
}

- (IBAction)saveImageAction:(id)sender
{
    self.saveController.sourceNames = @[
        FPSourceDropbox,
        FPSourceBox,
        FPSourceGoogleDrive,
        FPSourceSkydrive,
        FPSourceCloudDrive
    ];

    NSUInteger selectedIndex = self.imageBrowser.selectionIndexes.firstIndex;

    if (selectedIndex != NSNotFound)
    {
        ImageBrowserItem *browserItem = self.images[selectedIndex];

        CGImageRef CGImage = [browserItem.image CGImageForProposedRect:nil
                                                               context:nil
                                                                 hints:nil];

        NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:CGImage];
        NSData *bitmapData;

        if ([browserItem.mimetype isEqualToString:@"image/jpeg"])
        {
            bitmapData = [bitmapRep representationUsingType:NSJPEGFileType
                                                 properties:nil];
        }
        else if ([browserItem.mimetype isEqualToString:@"image/png"])
        {
            bitmapData = [bitmapRep representationUsingType:NSPNGFileType
                                                 properties:nil];
        }
        else
        {
            [NSException raise:NSInvalidArgumentException
                        format:@"Unhandled image format: %@", browserItem.mimetype];
        }

        self.saveController.data = bitmapData;
        self.saveController.dataType = browserItem.mimetype;
        self.saveController.proposedFilename = browserItem.title;

        [self.saveController open];
    }
    else
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Image missing"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"No image selected."];

        [alert runModal];
    }
}

- (IBAction)zoomSliderDidChange:(id)sender
{
    self.imageBrowser.zoomValue = [sender floatValue];

    [self.imageBrowser setNeedsDisplay:YES];
}

#pragma mark - FPPickerControllerDelegate Methods

- (void)                  fpPickerController:(FPPickerController *)pickerController
    didFinishPickingMultipleMediaWithResults:(NSArray *)results
{
    for (FPMediaInfo *info in results)
    {
        NSLog(@"Got media: %@", info);

        if (info.containsImageAtMediaURL)
        {
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:info.mediaURL];

            ImageBrowserItem *item = [ImageBrowserItem new];

            item.image = image;
            item.title = info.filename;
            item.mimetype = [self mimetypeFromFilename:info.filename];

            [self.importedImages addObject:item];
            [self updateDatasource];
        }
    }
}

- (void)fpPickerControllerDidCancel:(FPPickerController *)pickerController
{
    NSLog(@"Picker was cancelled.");
}

#pragma mark - FPSaveControllerDelegate Methods

- (void)        fpSaveController:(FPSaveController *)saveController
    didFinishSavingMediaWithInfo:(FPMediaInfo *)info
{
    NSLog(@"Saved media: %@", info);

    NSAlert *alert = [NSAlert alertWithMessageText:@"Image saved"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"The image was successfully saved!"];

    [alert runModal];
}

- (void)fpSaveController:(FPSaveController *)saveController
                didError:(NSError *)error
{
    NSLog(@"Error saving media: %@", error);

    NSAlert *alert = [NSAlert alertWithMessageText:@"Error saving image"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"The image could not be uploaded."];

    [alert runModal];
}

- (void)fpSaveControllerDidCancel:(FPSaveController *)saveController
{
    NSLog(@"Saving was cancelled.");
}

#pragma mark - IKImageBrowserDataSource Methods

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
    return self.images.count;
}

- (id)imageBrowser:(IKImageBrowserView *)view
       itemAtIndex:(NSUInteger)index
{
    return self.images[index];
}

- (void)    imageBrowser:(IKImageBrowserView *)view
    removeItemsAtIndexes:(NSIndexSet *)indexes
{
    [self.images removeObjectsAtIndexes:indexes];
}

- (BOOL)  imageBrowser:(IKImageBrowserView *)aBrowser
    moveItemsAtIndexes:(NSIndexSet *)indexes
               toIndex:(NSUInteger)destinationIndex;
{
    NSUInteger index;
    NSMutableArray *temporaryArray;

    temporaryArray = [NSMutableArray new];

    // First remove items from the data source and keep them in a temporary array.

    for (index = indexes.lastIndex; index != NSNotFound; index = [indexes indexLessThanIndex:index])
    {
        if (index < destinationIndex)
        {
            destinationIndex--;
        }

        id obj = self.images[index];
        [temporaryArray addObject:obj];
        [self.images removeObjectAtIndex:index];
    }

    // Then insert the removed items at the appropriate location.

    NSUInteger n = temporaryArray.count;

    for (index = 0; index < n; index++)
    {
        [self.images insertObject:temporaryArray[index]
                          atIndex:destinationIndex];
    }

    return YES;
}

#pragma mark - Private Methods

- (void)updateDatasource
{
    [self.images addObjectsFromArray:self.importedImages];
    [self.importedImages removeAllObjects];
    [self.imageBrowser reloadData];
}

- (NSString *)mimetypeFromFilename:(NSString *)filename
{
    CFStringRef fileExtension = (__bridge CFStringRef)filename.pathExtension;

    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            fileExtension,
                                                            NULL);

    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI,
                                                           kUTTagClassMIMEType);

    CFRelease(UTI);

    return (__bridge_transfer NSString *)MIMEType;
}

@end
