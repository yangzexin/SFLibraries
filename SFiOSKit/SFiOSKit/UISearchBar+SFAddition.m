//
//  UISearchBar+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 11/7/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "UISearchBar+SFAddition.h"

@implementation UISearchBar (SFAddition)

- (UITextField *)sf_searchTextField {
    UITextField *searchField = nil;
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0f) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UITextField class]]) {
                searchField = (UITextField *)subview;
                break;
            }
        }
    } else {
        for (UIView *view in [self subviews]) {
            for (UIView *subview in [view subviews]) {
                if ([subview isKindOfClass:[UITextField class]]) {
                    searchField = (id)subview;
                    break;
                }
            }
        }
    }
    
    return searchField;
}

@end
