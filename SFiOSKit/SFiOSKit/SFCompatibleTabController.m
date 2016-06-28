//
//  SFCompatibleTabController.m
//  SFiOSKit
//
//  Created by yangzexin on 10/7/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFCompatibleTabController.h"

@implementation SFCompatibleTabController

- (void)resetViewControllers {
    if(self.viewControllers.count != 0){
        [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIViewController *viewController = obj;
            if ([viewController isViewLoaded] && viewController.view.superview == self.view) {
                [obj willMoveToParentViewController:nil];
                [viewController.view removeFromSuperview];
                [obj removeFromParentViewController];
            }
        }];
        UIViewController *targetViewController = [self.viewControllers objectAtIndex:self.selectedIndex];
        targetViewController.view.frame = self.view.bounds;
        
        [self addChildViewController:targetViewController];
        [self.view addSubview:targetViewController.view];
        [targetViewController didMoveToParentViewController:self];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    BOOL wantToReset = selectedIndex != _selectedIndex;
    _selectedIndex = selectedIndex;
    if (wantToReset == YES) {
        [self resetViewControllers];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    [self setSelectedIndex:selectedIndex];
}

- (UIViewController *)selectedViewController {
    return [_viewControllers objectAtIndex:_selectedIndex];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if ([_viewControllers count] != 0) {
        [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
            [obj willMoveToParentViewController:nil];
            if ([obj isViewLoaded] && obj.view.superview == self.view) {
                [obj.view removeFromSuperview];
            }
            [obj removeFromParentViewController];
        }];
    }
    
    if (_selectedIndex > viewControllers.count) {
        _selectedIndex = 0;
    }
    if(_viewControllers != viewControllers){
        _viewControllers = viewControllers;
        [_viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIViewController *viewController = obj;
            if (idx == _selectedIndex) {
                [self addChildViewController:viewController];
                [self.view addSubview:viewController.view];
                [viewController didMoveToParentViewController:self];
            }
        }];
    }
    [self resetViewControllers];
}

@end
