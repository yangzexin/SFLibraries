//
//  UIViewController+SFTransparentViewController.h
//  SFiOSKit
//
//  Created by yangzexin on 2/13/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFTransparentViewControllerAnimationContext : NSObject

@property (nonatomic, assign, readonly) BOOL animated;
@property (nonatomic, weak, readonly) UIViewController *parentViewController;
@property (nonatomic, weak, readonly) UIViewController *presentingViewController;

@end

typedef void(^SFTransparentViewControllerAnimationCompletionCallback)();

@interface SFTransparentViewControllerAnimation : NSObject

@property (nonatomic, copy) void(^animationWillBegin)(SFTransparentViewControllerAnimationContext *context);
@property (nonatomic, copy) void(^animation)(SFTransparentViewControllerAnimationContext *context, SFTransparentViewControllerAnimationCompletionCallback completionCallback);

@end

@protocol SFTransparentViewControllerDelegate <NSObject>

@optional
- (void)transparentViewControllerWillPresent:(UIViewController *)viewController;
- (void)transparentViewControllerWillDismiss:(UIViewController *)viewController;

- (void)transparentViewControllerDidPresent:(UIViewController *)viewController;
- (void)transparentViewControllerDidDismiss:(UIViewController *)viewController;

@end

@interface UIViewController (SFTransparentViewController)

- (void)sf_setTransparentViewControllerDelegate:(id<SFTransparentViewControllerDelegate>)delegate;
- (id<SFTransparentViewControllerDelegate>)sf_transparentViewControllerDelegate;

- (void)sf_setTransparentViewControllerPresentingAnimation:(SFTransparentViewControllerAnimation *)animation;
- (SFTransparentViewControllerAnimation *)sf_transparentViewControllerPresentingAnimation;

- (void)sf_setTransparentViewControllerDismissingAnimation:(SFTransparentViewControllerAnimation *)animation;
- (SFTransparentViewControllerAnimation *)sf_transparentViewControllerDismissingAnimation;

- (UIViewController *)sf_presentingTransparentViewController;

- (void)sf_presentTransparentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completion;
- (void)sf_presentTransparentViewController:(UIViewController *)viewController transparent:(BOOL)transparent animated:(BOOL)animated completion:(void(^)())completion;

- (void)sf_dismissTransparentViewControllerAnimated:(BOOL)animated completion:(void(^)())completion;

@end
