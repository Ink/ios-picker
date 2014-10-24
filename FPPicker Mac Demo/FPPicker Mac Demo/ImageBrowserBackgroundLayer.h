#import <Quartz/Quartz.h>
#import <Cocoa/Cocoa.h>

@interface ImageBrowserBackgroundLayer : CALayer

@property (weak) IKImageBrowserView *owner;

@end
