//
//  SFDynamicImageCache.m
//  SFiOSKit
//
//  Created by yangzexin on 2/13/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "SFDynamicImageCache.h"

#import <SFFoundation/SFFoundation.h>

#import "SFBundleImageCache.h"

@interface SFDynamicImageCache ()

@property (nonatomic, strong) NSMutableDictionary *keyNameValueImageCreator;

@end

@implementation SFDynamicImageCache

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    
    self.keyNameValueImageCreator = [NSMutableDictionary dictionary];
    
    return self;
}

- (NSString *)_wrapName:(NSString *)name {
    return [NSString stringWithFormat:@"DynamicImage-%@", name];
}

- (void)setImageCreator:(UIImage *(^)())imageCreator name:(NSString *)name {
    [self.keyNameValueImageCreator setObject:[NSValue sf_valueWithBlock:imageCreator] forKey:[self _wrapName:name]];
}

- (UIImage *)imageNamed:(NSString *)name {
    name = [self _wrapName:name];
    
    UIImage *image = [[SFBundleImageCache sharedInstance] imageWithName:name];
    if (image == nil) {
        NSValue *blockValue = [self.keyNameValueImageCreator objectForKey:name];
        if (blockValue) {
            UIImage *(^imageCreator)() = (UIImage *(^)())[blockValue sf_block];
            image = imageCreator();
            
            if (image) {
                [[SFBundleImageCache sharedInstance] setImage:image forName:name];
            }
        }
    }
    
    return image;
}

@end
