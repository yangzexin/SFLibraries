//
//  UIMenuController+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 11/12/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "UIMenuController+SFAddition.h"

@implementation UIMenuController (SFAddition)

- (void)sf_addMenuItemIfNotExistsWithTitle:(NSString *)title action:(SEL)action {
    NSArray *menuItems = [[UIMenuController sharedMenuController] menuItems];
    BOOL menuItemExists = NO;
    for (UIMenuItem *menuItem in menuItems) {
        if ([menuItem.title isEqualToString:title]) {
            menuItemExists = YES;
            break;
        }
    }
    if (menuItemExists == NO) {
        UIMenuItem *newMenuItem = [UIMenuItem new];
        newMenuItem.title = title;
        newMenuItem.action = action;
        NSMutableArray *newMenuItems = [NSMutableArray arrayWithArray:menuItems];
        [newMenuItems addObject:newMenuItem];
        [[UIMenuController sharedMenuController] setMenuItems:newMenuItems];
    }
}

@end
