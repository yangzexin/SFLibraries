//
//  SFDynamicImageCache.h
//  SFiOSKit
//
//  Created by yangzexin on 2/13/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDynamicImageCache : NSObject

+ (instancetype)sharedInstance;

- (void)setImageCreator:(UIImage *(^)())imageCreator name:(NSString *)name;
- (UIImage *)imageNamed:(NSString *)name;

@end
