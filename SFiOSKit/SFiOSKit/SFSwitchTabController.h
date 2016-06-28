//
//  SFSwitchTabController.h
//  SFiOSKit
//
//  Created by yangzexin on 5/20/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFSwitchTabController;

@protocol SFSwitchTabControllerDelegate <NSObject>

@optional
- (void)switchTabController:(SFSwitchTabController *)switchTabController willSwitchToIndex:(NSInteger)index;
- (void)switchTabController:(SFSwitchTabController *)switchTabController didSwitchToIndex:(NSInteger)index;

@end

@interface SFSwitchTabController : UIViewController

@property (nonatomic, assign) id<SFSwitchTabControllerDelegate> delegate;

@property (nonatomic, weak, readonly) UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) BOOL scrollable;

- (UIViewController *)selectedViewController;

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated completion:(void(^)())completion;

@end
