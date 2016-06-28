//
//  SFCompatibleTabController.h
//  SFiOSKit
//
//  Created by yangzexin on 10/7/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFCompatibleTabController : UIViewController

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, assign) NSInteger selectedIndex;

- (UIViewController *)selectedViewController;

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end
