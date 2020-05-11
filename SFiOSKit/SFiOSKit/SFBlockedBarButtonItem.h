//
//  SFBlockedBarButtonItem.h
//  SFiOSKit
//
//  Created by yangzexin on 13-7-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFBlockedBarButtonItem : UIBarButtonItem

+ (instancetype)blockedBarButtonItemWithTitle:(NSString *)title tap:(void(^)(void))tap;
+ (instancetype)blockedBarButtonItemWithImage:(UIImage *)image tap:(void (^)(void))tap;
+ (instancetype)blockedBarButtonItemWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem tap:(void (^)(void))tap;
+ (instancetype)blockedBarButtonItemWithCustomView:(UIView *)customView;
+ (instancetype)blockedBarButtonItemWithCustomView:(UIView *)customView tap:(void (^)(void))tap;

@end
