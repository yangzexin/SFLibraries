//
//  UIViewController+SFTransparentViewController.m
//  SFiOSKit
//
//  Created by yangzexin on 2/13/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "UIViewController+SFTransparentViewController.h"

#import <SFFoundation/SFFoundation.h>

#import "SFiOSKitConstants.h"

static NSString *kTransparentViewControllerKey = @"kTransparentViewControllerKey";
static NSString *kTransparentParentViewControllerKey = @"kTransparentParentViewControllerKey";
static NSString *kTransparentViewControllerPresentingAnimationKey = @"kTransparentViewControllerPresentingAnimationKey";
static NSString *kTransparentViewControllerDismissingAnimationKey = @"kTransparentViewControllerDismissingAnimationKey";

@interface SFTransparentViewControllerAnimationContext ()

@property (nonatomic, assign) BOOL animated;
@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic, weak) UIViewController *presentingViewController;

@end

@implementation SFTransparentViewControllerAnimationContext

@end

@interface SFTransparentViewControllerAnimation ()

@end

@implementation SFTransparentViewControllerAnimation

@end

@implementation UIViewController (SFTransparentViewController)

+ (SFTransparentViewControllerAnimation *)_defaultPresentingAnimation {
    SFTransparentViewControllerAnimation *animation = [SFTransparentViewControllerAnimation new];
    
    [animation setAnimationWillBegin:^(SFTransparentViewControllerAnimationContext *context) {
        CGRect tmpRect = context.presentingViewController.view.frame;
        tmpRect.origin.y = context.parentViewController.view.frame.size.height;
        context.presentingViewController.view.frame = tmpRect;
    }];
    [animation setAnimation:^(SFTransparentViewControllerAnimationContext *context, SFTransparentViewControllerAnimationCompletionCallback completionCallback) {
        [UIView animateWithDuration:context.animated ? (SFDeviceSystemVersion < 7.0f ? 0.35f : 0.40f) : 0.0f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            context.presentingViewController.view.frame = context.parentViewController.view.bounds;
        } completion:^(BOOL finished) {
            completionCallback();
        }];
    }];
    
    return animation;
}

+ (SFTransparentViewControllerAnimation *)_defaultDismissingAnimation {
    SFTransparentViewControllerAnimation *animation = [SFTransparentViewControllerAnimation new];
    
    [animation setAnimationWillBegin:^(SFTransparentViewControllerAnimationContext *context) {
    }];
    [animation setAnimation:^(SFTransparentViewControllerAnimationContext *context, SFTransparentViewControllerAnimationCompletionCallback completionCallback) {
        [UIView animateWithDuration:context.animated ? (SFDeviceSystemVersion < 7.0f ? 0.35f : 0.40f) : 0.0f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect tmpRect = context.presentingViewController.view.frame;
            tmpRect.origin.y = context.parentViewController.view.frame.size.height;
            context.presentingViewController.view.frame = tmpRect;
        } completion:^(BOOL finished) {
            completionCallback();
        }];
    }];
    
    return animation;
}

- (void)sf_setTransparentViewControllerDelegate:(id<SFTransparentViewControllerDelegate>)delegate {
    [self sf_setAssociatedObject:[NSValue sf_valueWithWeakObject:delegate] key:@"transparentViewControllerDelegate"];
}

- (id<SFTransparentViewControllerDelegate>)sf_transparentViewControllerDelegate {
    NSValue *value = [self sf_associatedObjectWithKey:@"transparentViewControllerDelegate"];
    
    return [value sf_weakObject];
}

- (void)sf_setTransparentViewControllerPresentingAnimation:(SFTransparentViewControllerAnimation *)presentingAnimation {
    [self sf_setAssociatedObject:presentingAnimation key:kTransparentViewControllerPresentingAnimationKey];
}

- (SFTransparentViewControllerAnimation *)sf_transparentViewControllerPresentingAnimation {
    return [self sf_associatedObjectWithKey:kTransparentViewControllerPresentingAnimationKey];
}

- (void)sf_setTransparentViewControllerDismissingAnimation:(SFTransparentViewControllerAnimation *)dismissingAnimation {
    [self sf_setAssociatedObject:dismissingAnimation key:kTransparentViewControllerDismissingAnimationKey];
}

- (SFTransparentViewControllerAnimation *)sf_transparentViewControllerDismissingAnimation {
    return [self sf_associatedObjectWithKey:kTransparentViewControllerDismissingAnimationKey];
}

- (UIViewController *)sf_presentingTransparentViewController {
    NSValue *weakObjectWrapper = [self sf_associatedObjectWithKey:kTransparentViewControllerKey];
    UIViewController *existsViewController = [weakObjectWrapper sf_weakObject];
    return existsViewController;
}

- (void)sf_presentTransparentViewController:(UIViewController *)presentingTransparentViewController transparent:(BOOL)transparent animated:(BOOL)animated completion:(void(^)())completion {
    if (presentingTransparentViewController == nil) {
        NSLog(@"Warning:%@", @"viewController can't be nil");
        return;
    }
    if ([self sf_presentingTransparentViewController] != nil) {
        NSLog(@"Warning:%@", @"Transparent ViewController exists");
        return;
    }
    
    if (transparent) {
        if ([presentingTransparentViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (id)presentingTransparentViewController;
            [navigationController topViewController].view.backgroundColor = [UIColor clearColor];
            navigationController.view.backgroundColor = [UIColor clearColor];
        } else {
            presentingTransparentViewController.view.backgroundColor = [UIColor clearColor];
        }
    }
    
    [self sf_setAssociatedObject:[NSValue sf_valueWithWeakObject:presentingTransparentViewController] key:kTransparentViewControllerKey];
    [presentingTransparentViewController sf_setAssociatedObject:[NSValue sf_valueWithWeakObject:self] key:kTransparentParentViewControllerKey];
    
    UIViewController *parentViewController = self.navigationController == nil ? self : self.navigationController;
    presentingTransparentViewController.view.frame = parentViewController.view.bounds;
    
    [parentViewController addChildViewController:presentingTransparentViewController];
    [parentViewController.view addSubview:presentingTransparentViewController.view];
    [presentingTransparentViewController didMoveToParentViewController:parentViewController];
    
    [presentingTransparentViewController viewWillAppear:animated];
    [self viewWillDisappear:animated];
    
    if ([self.sf_transparentViewControllerDelegate respondsToSelector:@selector(transparentViewControllerWillPresent:)]) {
        [self.sf_transparentViewControllerDelegate transparentViewControllerWillPresent:presentingTransparentViewController];
    }
    
    SFTransparentViewControllerAnimation *animation = [self sf_transparentViewControllerPresentingAnimation];
    if (animation == nil) {
        animation = [UIViewController _defaultPresentingAnimation];
    }
    SFTransparentViewControllerAnimationContext *animationContext = [SFTransparentViewControllerAnimationContext new];
    animationContext.presentingViewController = presentingTransparentViewController;
    animationContext.parentViewController = parentViewController;
    animationContext.animated = animated;
    
    animation.animationWillBegin(animationContext);
    
    __weak typeof(presentingTransparentViewController) weakPresentingTransparentViewController = presentingTransparentViewController;
    __weak typeof(self) weakSelf = self;
    animation.animation(animationContext, ^{
        if (completion) {
            completion();
        }
        __strong typeof(weakPresentingTransparentViewController) presentingTransparentViewController = weakPresentingTransparentViewController;
        __strong typeof(weakSelf) self = weakSelf;
        [presentingTransparentViewController viewDidAppear:animated];
        [self viewDidDisappear:animated];
        if ([self.sf_transparentViewControllerDelegate respondsToSelector:@selector(transparentViewControllerDidPresent:)]) {
            [self.sf_transparentViewControllerDelegate transparentViewControllerDidPresent:presentingTransparentViewController];
        }
    });
}

- (void)sf_presentTransparentViewController:(UIViewController *)presentingTransparentViewController animated:(BOOL)animated completion:(void(^)())completion {
    [self sf_presentTransparentViewController:presentingTransparentViewController transparent:YES animated:animated completion:completion];
}

- (void)sf_dismissTransparentViewControllerAnimated:(BOOL)animated completion:(void(^)())completion {
    UIViewController *presentingTransparentViewController = [self sf_presentingTransparentViewController];
    UIViewController *parentTransparentViewController = self;
    if (presentingTransparentViewController == nil) {
        NSValue *weakObjectWrapper = [self sf_associatedObjectWithKey:kTransparentParentViewControllerKey];
        UIViewController *parentViewController = [weakObjectWrapper sf_weakObject];
        if (parentViewController) {
            presentingTransparentViewController = [parentViewController sf_presentingTransparentViewController];
            parentTransparentViewController = parentViewController;
        }
    }
    if (presentingTransparentViewController == nil) {
        NSValue *weakObjectWrapper = [self.navigationController sf_associatedObjectWithKey:kTransparentParentViewControllerKey];
        UIViewController *parentViewController = [weakObjectWrapper sf_weakObject];
        if (parentViewController) {
            presentingTransparentViewController = [parentViewController sf_presentingTransparentViewController];
            parentTransparentViewController = parentViewController;
        }
    }
    if (presentingTransparentViewController) {
        UIViewController *parentViewController = parentTransparentViewController.navigationController == nil ? parentTransparentViewController : parentTransparentViewController.navigationController;
        
        [parentTransparentViewController viewWillAppear:animated];
        [presentingTransparentViewController viewWillDisappear:animated];
        [presentingTransparentViewController.view endEditing:YES];
        if ([self.sf_transparentViewControllerDelegate respondsToSelector:@selector(transparentViewControllerWillDismiss:)]) {
            [self.sf_transparentViewControllerDelegate transparentViewControllerWillDismiss:presentingTransparentViewController];
        }
        
        SFTransparentViewControllerAnimation *animation = [self sf_transparentViewControllerDismissingAnimation];
        if (animation == nil) {
            animation = [UIViewController _defaultDismissingAnimation];
        }
        SFTransparentViewControllerAnimationContext *animationContext = [SFTransparentViewControllerAnimationContext new];
        animationContext.presentingViewController = presentingTransparentViewController;
        animationContext.parentViewController = parentViewController;
        animationContext.animated = animated;
        
        animation.animationWillBegin(animationContext);
        
        __weak typeof(presentingTransparentViewController) weakPresentingTransparentViewController = presentingTransparentViewController;
        __weak typeof(parentTransparentViewController) weakParentTransparentViewController = parentTransparentViewController;
        animation.animation(animationContext, ^{
            __strong typeof(weakParentTransparentViewController) parentTransparentViewController = weakParentTransparentViewController;
            __strong typeof(weakPresentingTransparentViewController) presentingTransparentViewController = weakPresentingTransparentViewController;
            
            [parentTransparentViewController viewDidAppear:animated];
            [presentingTransparentViewController viewDidDisappear:animated];
            
            [presentingTransparentViewController willMoveToParentViewController:nil];
            [presentingTransparentViewController.view removeFromSuperview];
            [presentingTransparentViewController removeFromParentViewController];
            
            if ([self.sf_transparentViewControllerDelegate respondsToSelector:@selector(transparentViewControllerDidDismiss:)]) {
                [self.sf_transparentViewControllerDelegate transparentViewControllerDidDismiss:presentingTransparentViewController];
            }
            
            [parentTransparentViewController sf_removeAssociatedObjectWithKey:kTransparentViewControllerKey];
            
            if (completion) {
                completion();
            }
        });
    }
}

@end
