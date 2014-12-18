//
//  UIMenuController+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 11/12/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIMenuController (SFAddition)

- (void)sf_addMenuItemIfNotExistsWithTitle:(NSString *)title action:(SEL)action;

@end
