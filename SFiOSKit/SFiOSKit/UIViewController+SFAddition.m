//
//  UIViewController+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 11/7/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "UIViewController+SFAddition.h"

@implementation UIViewController (SFAddition)

- (NSMutableArray *)sf_viewControllersPopToMe {
    NSMutableArray *existsViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (UIViewController *viewController in existsViewControllers) {
        [viewControllers addObject:viewController];
        if (viewController == self) {
            break;
        }
    }
    
    return viewControllers;
}

- (UIViewController *)_topModalViewController {
    UIViewController *srcController = self;
    while (srcController.presentedViewController != nil) {
        srcController = srcController.presentedViewController;
    }
    
    return srcController;
}

- (void)sf_recursivePresentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completion {
    [[self _topModalViewController] presentViewController:viewController animated:animated completion:completion];
}

- (void)sf_recursiveDismissViewControllerAnimated:(BOOL)animated completion:(void(^)())completion {
    [[self _topModalViewController] dismissViewControllerAnimated:animated completion:completion];
}

@end
