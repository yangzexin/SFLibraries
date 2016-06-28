//
//  SFBundleImageCache.h
//  SfiOSKit
//
//  Created by yangzexin on 2/13/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFBundleImageCache : NSObject

+ (instancetype)sharedInstance;

- (void)setImage:(UIImage *)image forName:(NSString *)name;
- (UIImage *)imageWithName:(NSString *)name;

@end
