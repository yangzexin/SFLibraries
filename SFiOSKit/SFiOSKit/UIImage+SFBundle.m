//
//  UIImage+SFBundle.m
//  SFiOSKit
//
//  Created by yangzexin on 2/13/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "UIImage+SFBundle.h"

@interface SFBundleImageCache : NSObject

+ (instancetype)sharedInstance;

- (void)setImage:(UIImage *)image forName:(NSString *)name;
- (UIImage *)imageWithName:(NSString *)name;

@end

@interface SFBundleImageCache ()

@property (nonatomic, strong) NSMutableDictionary *keyImageNameValueImage;

@end

@implementation SFBundleImageCache

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    
    self.keyImageNameValueImage = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_memoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    return self;
}

- (void)_memoryWarningNotification:(id)noti
{
    [self.keyImageNameValueImage removeAllObjects];
}

- (void)setImage:(UIImage *)image forName:(NSString *)name
{
    [_keyImageNameValueImage setObject:image forKey:name];
}

- (UIImage *)imageWithName:(NSString *)name
{
    return [_keyImageNameValueImage objectForKey:name];
}

@end

@implementation UIImage (SFBundle)

+ (instancetype)sf_imageNamed:(NSString *)name bundle:(NSBundle *)bundle
{
    NSString *imageNameWithoutExtension = [name stringByDeletingPathExtension];
    NSString *extension = [name pathExtension];
    
    NSString *bundlePath = [bundle resourcePath];
    
    NSMutableArray *fileExtensions = [NSMutableArray arrayWithArray:@[@"png", @"jpg", @"jpeg", @"tiff"]];
    if (extension.length != 0) {
        [fileExtensions removeObject:extension];
        [fileExtensions insertObject:extension atIndex:0];
    }
    NSMutableArray *nameSuffixes = [NSMutableArray arrayWithArray:@[@"", @"@2x", @"@3x"]];
    NSDictionary *keyNameSuffixValueScale = @{@"" : @(1), @"@2x" : @(2), @"@3x" : @(3)};
    NSInteger scale = (NSInteger)[[UIScreen mainScreen] scale];
    if (scale != 1) {
        [nameSuffixes removeObject:[NSString stringWithFormat:@"@%ldx", (long)scale]];
        [nameSuffixes insertObject:[NSString stringWithFormat:@"@%ldx", (long)scale] atIndex:0];
    }
    
    for (NSString *fileExtension in fileExtensions) {
        for (NSInteger i = 0; i < nameSuffixes.count; ++i) {
            NSString *suffix = [nameSuffixes objectAtIndex:i];
            NSString *tmpFileName = [NSString stringWithFormat:@"%@%@.%@", imageNameWithoutExtension, suffix, fileExtension];
            NSString *tmpFilePath = [bundlePath stringByAppendingPathComponent:tmpFileName];
            NSNumber *scaleNum = [keyNameSuffixValueScale objectForKey:suffix];
            NSInteger scale = 1;
            if (scaleNum) {
                scale = [scaleNum integerValue];
            }
            if ([fileExtension isEqualToString:@"tiff"]) {
                scale = (NSInteger)([UIScreen mainScreen].scale);
            }
            UIImage *image = [[SFBundleImageCache sharedInstance] imageWithName:tmpFileName];
            
            if (image) {
                return image;
            } else {
                image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:tmpFilePath] scale:scale];
                if (image) {
                    [[SFBundleImageCache sharedInstance] setImage:image forName:tmpFileName];
                    
                    return image;
                }
            }
        }
    }
    
    return nil;
}

@end
