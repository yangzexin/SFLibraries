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

@interface UITransparentViewControllerAnimationContext : NSObject

@property (nonatomic, assign, readonly) BOOL animated;
@property (nonatomic, weak, readonly) UIViewController *parentViewController;
@property (nonatomic, weak, readonly) UIViewController *presentingViewController;

@end

typedef void(^UITransparentViewControllerAnimationCompletionCallback)();

@interface UITransparentViewControllerAnimation : NSObject

@property (nonatomic, copy) void(^animationWillBegin)(UITransparentViewControllerAnimationContext *context);
@property (nonatomic, copy) void(^animation)(UITransparentViewControllerAnimationContext *context, UITransparentViewControllerAnimationCompletionCallback completionCallback);

@end

@interface UIViewController (TransparentViewController)

@property (nonatomic, strong) UITransparentViewControllerAnimation *transparentViewControllerPresentingAnimation;
@property (nonatomic, strong) UITransparentViewControllerAnimation *transparentViewControllerDismissingAnimation;

- (UIViewController *)sf_presentingTransparentViewController;
- (void)sf_presentTransparentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completion;
- (void)sf_presentTransparentViewController:(UIViewController *)viewController transparent:(BOOL)transparent animated:(BOOL)animated completion:(void(^)())completion;
- (void)sf_dismissTransparentViewControllerAnimated:(BOOL)animated completion:(void(^)())completion;

@end

@protocol UIViewControllerTransparentViewControllerDelegate <NSObject>

@optional
- (void)transparentViewControllerWillPresent:(UIViewController *)viewController;
- (void)transparentViewControllerWillDismiss:(UIViewController *)viewController;

- (void)transparentViewControllerDidPresent:(UIViewController *)viewController;
- (void)transparentViewControllerDidDismiss:(UIViewController *)viewController;

@end