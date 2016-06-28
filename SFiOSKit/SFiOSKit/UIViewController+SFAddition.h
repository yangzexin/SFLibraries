//
//  UIViewController+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 11/7/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (SFAddition)

- (NSMutableArray *)sf_viewControllersPopToMe;

- (void)sf_recursivePresentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completion;
- (void)sf_recursiveDismissViewControllerAnimated:(BOOL)animated completion:(void(^)())completion;

@end