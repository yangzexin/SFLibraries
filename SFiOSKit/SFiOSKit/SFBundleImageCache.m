//
//  SFBundleImageCache.m
//  SFiOSKit
//
//  Created by yangzexin on 2/13/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "SFBundleImageCache.h"

@interface SFBundleImageCache ()

@property (nonatomic, strong) NSMutableDictionary *keyImageNameValueImage;

@end

@implementation SFBundleImageCache

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    
    self.keyImageNameValueImage = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_memoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    return self;
}

- (void)_memoryWarningNotification:(id)noti {
    [self.keyImageNameValueImage removeAllObjects];
}

- (void)setImage:(UIImage *)image forName:(NSString *)name {
    [_keyImageNameValueImage setObject:image forKey:name];
}

- (UIImage *)imageWithName:(NSString *)name {
    return [_keyImageNameValueImage objectForKey:name];
}

@end
