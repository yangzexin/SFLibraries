//
//  UIView+SFDownloadImage.m
//  SFiOSKit
//
//  Created by yangzexin on 7/5/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "UIView+SFDownloadImage.h"

#import <ImageIO/ImageIO.h>

#import "NSObject+SFObjectAssociation.h"
#import "NSValue+SFBlock.h"
#import "NSString+SFAddition.h"

static NSOperationQueue *SFSharedDownloadImageQueue();
static NSString *SFDownloadImageFolderPath();
static NSMutableDictionary *SFKeyURLValueOperation();
static void SFDownloadImage(NSURL *url, CGSize maxSize, void(^completion)(UIImage *image, NSError *error), void(^previousCompletion)(UIImage *image, NSError *error));

@interface SFDownloadImageOperation : NSOperation

- (id)initWithURL:(NSURL *)url;

@end

@interface SFDownloadImageOperation ()

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) NSMutableArray *callbacks;

@property (nonatomic, assign) CGSize maxSize;

@property (nonatomic, copy) void(^whenFinished)();

@end

@implementation SFDownloadImageOperation

- (void)dealloc
{
//#ifdef DEBUG
//    NSLog(@"%@ <%@> dealloc", NSStringFromClass([self class]), self.url);
//#endif
}

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    
    self.url = url;
    self.callbacks = [NSMutableArray array];
    
    return self;
}

- (void)main
{
    NSError *error = nil;
    NSString *fileName = [self.url.absoluteString sf_stringByEncryptingUsingMD5];
    NSString *filePath = [SFDownloadImageFolderPath() stringByAppendingPathComponent:fileName];
    NSData *data = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName isDirectory:nil]) {
        data = [NSData dataWithContentsOfURL:self.url options:0 error:&error];
        [data writeToFile:filePath atomically:YES];
        data = nil;
    }
    
    UIImage *image = nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:filePath], NULL);
    if (imageSource){
        CGImageRef imgRef = NULL;
        if (CGSizeEqualToSize(self.maxSize, CGSizeZero)) {
            imgRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
        } else {
            NSDictionary *options = @{(id)kCGImageSourceCreateThumbnailWithTransform : (id)kCFBooleanFalse
                                      , (id)kCGImageSourceCreateThumbnailFromImageIfAbsent : (id)kCFBooleanTrue
                                      , (id)kCGImageSourceThumbnailMaxPixelSize : (id)[NSNumber numberWithFloat:self.maxSize.width]
                                      };
            imgRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
        }
        
        image = [UIImage imageWithCGImage:imgRef];
        
        CGImageRelease(imgRef);
        CFRelease(imageSource);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *callbacks = [self.callbacks copy];
        for (NSValue *callback in callbacks) {
            void(^completion)(UIImage *image, NSError *error) = [callback sf_block];
            completion(image, error);
        }
        
        self.whenFinished();
    });
}

- (void)addCallback:(void(^)(UIImage *image, NSError *error))completion
{
    [self.callbacks addObject:[NSValue sf_valueWithBlock:completion]];
}

- (void)removeCallback:(void(^)(UIImage *image, NSError *error))completion
{
    id targetBlock = (id)completion;
    NSArray *callbacks = [self.callbacks copy];
    for (NSValue *callback in callbacks) {
        if ([callback sf_block] == targetBlock) {
            [self.callbacks removeObject:callback];
            break;
        }
    }
}

@end

static NSString *SFDownloadImageFolderPath()
{
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"SFDownloadImage"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return folderPath;
}

static NSOperationQueue *SFSharedDownloadImageQueue()
{
    static NSOperationQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 5;
    });
    
    return queue;
}

static NSMutableDictionary *SFKeyURLValueOperation()
{
    static NSMutableDictionary *keyURLValueOperation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyURLValueOperation = [NSMutableDictionary dictionary];
    });
    
    return keyURLValueOperation;
}

static void SFDownloadImage(NSURL *url, CGSize maxSize, void(^completion)(UIImage *image, NSError *error), void(^previousCompletion)(UIImage *image, NSError *error))
{
    NSMutableDictionary *keyURLValueOperation = SFKeyURLValueOperation();
    @synchronized (keyURLValueOperation) {
        SFDownloadImageOperation *operation = [keyURLValueOperation objectForKey:url];
        if (operation == nil) {
            operation = [[SFDownloadImageOperation alloc] initWithURL:url];
            operation.maxSize = maxSize;
            
            [keyURLValueOperation setObject:operation forKey:url];
            
            [SFSharedDownloadImageQueue() addOperation:operation];
            [operation setWhenFinished:^{
                @synchronized (keyURLValueOperation) {
                    [keyURLValueOperation removeObjectForKey:url];
                }
            }];
        } else {
            [operation removeCallback:previousCompletion];
        }
        [operation addCallback:completion];
    }
}

@implementation UIView (SFDownloadImage)

- (void)sf_downloadImageWithURL:(NSURL *)url completion:(void(^)(UIImage *image, NSError *error))completion
{
    [self sf_downloadImageWithURL:url maxSize:CGSizeZero completion:completion];
}

- (void)sf_downloadImageWithURL:(NSURL *)url maxSize:(CGSize)maxSize completion:(void(^)(UIImage *image, NSError *error))completion
{
    maxSize.width *= [UIScreen mainScreen].scale;
    maxSize.height *= [UIScreen mainScreen].scale;
    
    void(^previousCompletion)(UIImage *image, NSError *error) = [[self sf_associatedObjectWithKey:@"_SFPreviousCompletion"] sf_block];
    
    SFDownloadImage(url, maxSize, completion, previousCompletion);
    
    [self sf_setAssociatedObject:[NSValue sf_valueWithBlock:completion] key:@"_SFPreviousCompletion"];
}

@end
