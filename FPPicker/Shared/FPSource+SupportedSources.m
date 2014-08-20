//
//  FPSource+SupportedSources.m
//  FPPicker
//
//  Created by Ruben Nine on 20/08/14.
//  Copyright (c) 2014 Filepicker.io. All rights reserved.
//

#import "FPSource+SupportedSources.h"
#import "FPConstants.h"

@implementation FPSource (SupportedSources)

+ (NSArray *)allMobileSources
{
    return [[FPSource localMobileSources] arrayByAddingObjectsFromArray:[FPSource remoteSources]];
}

+ (NSArray *)allDesktopSources
{
    return [[FPSource localDesktopSources] arrayByAddingObjectsFromArray:[FPSource remoteSources]];
}

+ (NSArray *)localMobileSources
{
    NSMutableArray *sources = [NSMutableArray array];

    FPSource *source;

    // Camera
    {
        source = [FPSource new];

        source.identifier = FPSourceCamera;
        source.name = @"Camera";
        source.icon = @"glyphicons_011_camera";
        source.rootUrl = @"/Camera";
        source.openMimetypes = @[@"video/quicktime", @"image/jpeg", @"image/png"];
        source.saveMimetypes = @[];
        source.overwritePossible = NO;
        source.externalDomains = @[];

        [sources addObject:source];
    }

    // Albums
    {
        source = [FPSource new];

        source.identifier = FPSourceCameraRoll;
        source.name = @"Albums";
        source.icon = @"glyphicons_008_film";
        source.rootUrl = @"/Albums";
        source.openMimetypes = @[@"image/jpeg", @"image/png", @"video/quicktime"];
        source.saveMimetypes = @[@"image/jpeg", @"image/png"];
        source.overwritePossible = NO;
        source.externalDomains = @[];

        [sources addObject:source];
    }

    return [sources copy];
}

+ (NSArray *)localDesktopSources
{
    NSMutableArray *sources = [NSMutableArray array];

    FPSource *source;

    // Local File(s)
    {
        source = [FPSource new];

        source.identifier = FPSourceFilesystem;
        source.name = @"Local File(s)";
        source.icon = @"glyphicons_020_home";
        source.rootUrl = @"/computer";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[];

        [sources addObject:source];
    }

    return [sources copy];
}

+ (NSArray *)remoteSources
{
    NSMutableArray *sources = [NSMutableArray array];

    FPSource *source;

    // Dropbox
    {
        source = [FPSource new];

        source.identifier = FPSourceDropbox;
        source.name = @"Dropbox";
        source.icon = @"glyphicons_361_dropbox";
        source.rootUrl = @"/Dropbox";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://www.dropbox.com"];

        [sources addObject:source];
    }

    // Facebook
    {
        source = [FPSource new];

        source.identifier = FPSourceFacebook;
        source.name = @"Facebook";
        source.icon = @"glyphicons_390_facebook";
        source.rootUrl = @"/Facebook";
        source.openMimetypes = @[@"image/jpeg"];
        source.saveMimetypes = @[@"image/*"];
        source.overwritePossible = NO;
        source.externalDomains = @[@"https://www.facebook.com"];

        [sources addObject:source];
    }

    // Gmail
    {
        source = [FPSource new];

        source.identifier = FPSourceGmail;
        source.name = @"Gmail";
        source.icon = @"glyphicons_sb1_gmail";
        source.rootUrl = @"/Gmail";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[];
        source.overwritePossible = NO;
        source.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];

        [sources addObject:source];
    }

    // Box
    {
        source = [FPSource new];

        source.identifier = FPSourceBox;
        source.name = @"Box";
        source.icon = @"glyphicons_sb2_box";
        source.rootUrl = @"/Box";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://www.box.com"];

        [sources addObject:source];
    }

    // Github
    {
        source = [FPSource new];

        source.identifier = FPSourceGithub;
        source.name = @"Github";
        source.icon = @"glyphicons_381_github";
        source.rootUrl = @"/Github";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[];
        source.overwritePossible = NO;
        source.externalDomains = @[@"https://www.github.com"];

        [sources addObject:source];
    }

    // Google Drive
    {
        source = [FPSource new];

        source.identifier = FPSourceGoogleDrive;
        source.name = @"Google Drive";
        source.icon = @"GoogleDrive";
        source.rootUrl = @"/GoogleDrive";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = NO;
        source.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];

        [sources addObject:source];
    }

    // Instagram
    {
        source = [FPSource new];

        source.identifier = FPSourceInstagram;
        source.name = @"Instagram";
        source.icon = @"Instagram";
        source.rootUrl = @"/Instagram";
        source.openMimetypes = @[@"image/jpeg"];
        source.saveMimetypes = @[];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://www.instagram.com",  @"https://instagram.com"];

        [sources addObject:source];
    }

    // Flickr
    {
        source = [FPSource new];

        source.identifier = FPSourceFlickr;
        source.name = @"Flickr";
        source.icon = @"glyphicons_395_flickr";
        source.rootUrl = @"/Flickr";
        source.openMimetypes = @[@"image/*"];
        source.saveMimetypes = @[@"image/*"];
        source.overwritePossible = NO;
        source.externalDomains = @[@"https://*.flickr.com", @"http://*.flickr.com"];

        [sources addObject:source];
    }

    // Evernote
    {
        source = [FPSource new];

        source.identifier = FPSourceEvernote;
        source.name = @"Evernote";
        source.icon = @"glyphicons_371_evernote";
        source.rootUrl = @"/Evernote";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://www.evernote.com",  @"https://evernote.com"];

        [sources addObject:source];
    }

    // Picasa
    {
        source = [FPSource new];

        source.identifier = FPSourcePicasa;
        source.name = @"Picasa";
        source.icon = @"glyphicons_366_picasa";
        source.rootUrl = @"/Picasa";
        source.openMimetypes = @[@"image/*"];
        source.saveMimetypes = @[@"image/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];

        [sources addObject:source];
    }

    // Skydrive
    {
        source = [FPSource new];

        source.identifier = FPSourceSkydrive;
        source.name = @"OneDrive";
        source.icon = @"glyphicons_sb3_skydrive";
        source.rootUrl = @"/OneDrive";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://login.live.com",  @"https://skydrive.live.com"];

        [sources addObject:source];
    }

    // Web image search
    {
        source = [FPSource new];

        source.identifier = FPSourceImagesearch;
        source.name = @"Web Images";
        source.icon = @"glyphicons_027_search";
        source.rootUrl = @"/Imagesearch";
        source.openMimetypes = @[@"image/jpeg"];
        source.saveMimetypes = @[];
        source.overwritePossible = NO;
        source.externalDomains = @[];

        [sources addObject:source];
    }

    return [sources copy];
}

@end
