//
//  SFSideMenuController.h
//  SFiOSKit
//
//  Created by yangzexin on 11/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFSideMenuController;

@protocol SFSideMenuControllerChildControllerDelegate <NSObject>

- (BOOL)shouldSideMenuControllerTriggerGesture:(SFSideMenuController *)sideMenuController;

@end

@protocol SFSideMenuControllerDelegate <NSObject>

@optional
- (void)sideMenuControllerMenuViewControllerDidShown:(SFSideMenuController *)sideMenuController;
- (void)sideMenuControllerContentViewControllerDidShown:(SFSideMenuController *)sideMenuController;

@end

@interface SFSideMenuController : UIViewController

@property (nonatomic, assign) id<SFSideMenuControllerDelegate> delegate;

@property (nonatomic, assign) CGFloat leftPanDistance;

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign) float widthPercentForMenuViewController;
@property (nonatomic, assign) float scaleTransformForContentViewController;

@property (nonatomic, assign, readonly) BOOL menuShown;
@property (nonatomic, strong, readonly) UIViewController *menuViewController;
@property (nonatomic, strong, readonly) UIViewController *contentViewController;

@property (nonatomic, assign) BOOL disableGestureShowMenu;
@property (nonatomic, assign) BOOL animatesShowMenu;
@property (nonatomic, assign) BOOL parallexAnimation;

@property (nonatomic, assign) BOOL endEditingWhenGestureWillTrigger;

- (id)initWithMenuViewController:(UIViewController *)menuViewController contentViewController:(UIViewController *)contentViewController;

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void(^)())completion;
- (void)setContentViewController:(UIViewController *)contentViewController showImmediately:(BOOL)showImmediately animated:(BOOL)animated completion:(void(^)())completion;

- (void)showMenuViewControllerAnimated:(BOOL)animated completion:(void(^)())completion;
- (void)showContentViewControllerAnimated:(BOOL)animated completion:(void(^)())completion;

- (void)tantantanWithMenuVisibleWidth:(CGFloat)menuVisibleWidth completion:(void(^)())completion;

@end
