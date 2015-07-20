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

- (instancetype)initWithSourceIdentifier:(NSString *)identifier
{
    self = [self init];

    if (self)
    {
        NSArray *allSources = [FPSource allSources];

        NSUInteger matchingIndex = [allSources indexOfObjectPassingTest: ^BOOL (id obj, NSUInteger idx, BOOL *stop) {
            FPSource *source = (FPSource *)obj;

            return source.identifier == identifier;
        }];

        if (matchingIndex != NSNotFound)
        {
            return allSources[matchingIndex];
        }
        else
        {
            return nil;
        }
    }

    return self;
}

+ (FPSource *)sourceWithIdentifier:(NSString *)identifier
{
    return [[FPSource alloc] initWithSourceIdentifier:identifier];
}

+ (NSArray *)allSources
{
    return [self.allMobileSources arrayByAddingObjectsFromArray:self.localDesktopSources];
}

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
        source.rootPath = @"/Camera";
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
        source.rootPath = @"/Albums";
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
        source.rootPath = @"/computer";
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
        source.rootPath = @"/Dropbox";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://www.dropbox.com"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Facebook
    {
        source = [FPSource new];

        source.identifier = FPSourceFacebook;
        source.name = @"Facebook";
        source.icon = @"glyphicons_390_facebook";
        source.rootPath = @"/Facebook";
        source.openMimetypes = @[@"image/jpeg"];
        source.saveMimetypes = @[@"image/*"];
        source.overwritePossible = NO;
        source.externalDomains = @[@"https://www.facebook.com"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Gmail
    {
        source = [FPSource new];

        source.identifier = FPSourceGmail;
        source.name = @"Gmail";
        source.icon = @"glyphicons_sb1_gmail";
        source.rootPath = @"/Gmail";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[];
        source.overwritePossible = NO;
        source.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Box
    {
        source = [FPSource new];

        source.identifier = FPSourceBox;
        source.name = @"Box";
        source.icon = @"glyphicons_sb2_box";
        source.rootPath = @"/Box";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://www.box.com"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Github
    {
        source = [FPSource new];

        source.identifier = FPSourceGithub;
        source.name = @"Github";
        source.icon = @"glyphicons_381_github";
        source.rootPath = @"/Github";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[];
        source.overwritePossible = NO;
        source.externalDomains = @[@"https://www.github.com"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Google Drive
    {
        source = [FPSource new];

        source.identifier = FPSourceGoogleDrive;
        source.name = @"Google Drive";
        source.icon = @"GoogleDrive";
        source.rootPath = @"/GoogleDrive";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = NO;
        source.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Instagram
    {
        source = [FPSource new];

        source.identifier = FPSourceInstagram;
        source.name = @"Instagram";
        source.icon = @"Instagram";
        source.rootPath = @"/Instagram";
        source.openMimetypes = @[@"image/jpeg"];
        source.saveMimetypes = @[];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://www.instagram.com",  @"https://instagram.com"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Flickr
    {
        source = [FPSource new];

        source.identifier = FPSourceFlickr;
        source.name = @"Flickr";
        source.icon = @"glyphicons_395_flickr";
        source.rootPath = @"/Flickr";
        source.openMimetypes = @[@"image/*"];
        source.saveMimetypes = @[@"image/*"];
        source.overwritePossible = NO;
        source.externalDomains = @[@"https://*.flickr.com", @"http://*.flickr.com"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Evernote
    {
        source = [FPSource new];

        source.identifier = FPSourceEvernote;
        source.name = @"Evernote";
        source.icon = @"glyphicons_371_evernote";
        source.rootPath = @"/Evernote";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://www.evernote.com",  @"https://evernote.com"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Picasa
    {
        source = [FPSource new];

        source.identifier = FPSourcePicasa;
        source.name = @"Picasa";
        source.icon = @"glyphicons_366_picasa";
        source.rootPath = @"/Picasa";
        source.openMimetypes = @[@"image/*"];
        source.saveMimetypes = @[@"image/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://www.google.com", @"https://accounts.google.com", @"https://google.com"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Skydrive
    {
        source = [FPSource new];

        source.identifier = FPSourceSkydrive;
        source.name = @"OneDrive";
        source.icon = @"glyphicons_sb3_skydrive";
        source.rootPath = @"/OneDrive";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://login.live.com",  @"https://skydrive.live.com"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Amazon Cloud Drive
    {
        source = [FPSource new];

        source.identifier = FPSourceCloudDrive;
        source.name = @"Amazon Cloud Drive";
        source.icon = @"CloudDrive";
        source.rootPath = @"/Clouddrive";
        source.openMimetypes = @[@"*/*"];
        source.saveMimetypes = @[@"*/*"];
        source.overwritePossible = YES;
        source.externalDomains = @[@"https://www.amazon.com/clouddrive"];
        source.requiresAuth = YES;

        [sources addObject:source];
    }

    // Web image search
    {
        source = [FPSource new];

        source.identifier = FPSourceImagesearch;
        source.name = @"Web Images";
        source.icon = @"glyphicons_027_search";
        source.rootPath = @"/Imagesearch";
        source.openMimetypes = @[@"image/jpeg"];
        source.saveMimetypes = @[];
        source.overwritePossible = NO;
        source.externalDomains = @[];
        source.requiresAuth = NO;

        [sources addObject:source];
    }

    return [sources copy];
}

@end
