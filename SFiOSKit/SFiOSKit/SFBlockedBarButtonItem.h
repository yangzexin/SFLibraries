//
//  SFBlockedBarButtonItem.h
//  SFiOSKit
//
//  Created by yangzexin on 13-7-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFBlockedBarButtonItem : UIBarButtonItem

+ (id)blockedBarButtonItemWithTitle:(NSString *)title eventHandler:(void(^)())eventHandler;
+ (id)blockedBarButtonItemWithImage:(UIImage *)image eventHandler:(void (^)())eventHandler;
+ (id)blockedBarButtonItemWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem eventHandler:(void (^)())eventHandler;
+ (id)blockedBarButtonItemWithCustomView:(UIView *)customView;
+ (id)blockedBarButtonItemWithCustomView:(UIView *)customView eventHandler:(void (^)())eventHandler;

@end
