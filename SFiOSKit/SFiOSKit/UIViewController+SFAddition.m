//
//  UIViewController+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 11/7/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "UIViewController+SFAddition.h"
#import "SFiOSKitConstants.h"
#import "NSValue+SFWeakObject.h"
#import "NSObject+SFObjectAssociation.h"

@implementation UIViewController (SFAddition)

- (NSMutableArray *)sf_viewControllersPopToMe
{
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

- (UIViewController *)_topModalViewController
{
    UIViewController *srcController = self;
    while (srcController.presentedViewController != nil) {
        srcController = srcController.presentedViewController;
    }
    return srcController;
}

- (void)sf_recursivePresentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completion
{
    [[self _topModalViewController] presentViewController:viewController animated:animated completion:completion];
}

- (void)sf_recursiveDismissViewControllerAnimated:(BOOL)animated completion:(void(^)())completion
{
    [[self _topModalViewController] dismissViewControllerAnimated:animated completion:completion];
}

@end

static NSString *kTransparentViewControllerKey = @"kTransparentViewControllerKey";
static NSString *kTransparentParentViewControllerKey = @"kTransparentParentViewControllerKey";
static NSString *kTransparentViewControllerPresentingAnimationKey = @"kTransparentViewControllerPresentingAnimationKey";
static NSString *kTransparentViewControllerDismissingAnimationKey = @"kTransparentViewControllerDismissingAnimationKey";

@interface UITransparentViewControllerAnimationContext ()

@property (nonatomic, assign) BOOL animated;
@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic, weak) UIViewController *presentingViewController;

@end

@implementation UITransparentViewControllerAnimationContext

@end

@interface UITransparentViewControllerAnimation ()

@end

@implementation UITransparentViewControllerAnimation

@end

@implementation UIViewController (TransparentViewController)

+ (UITransparentViewControllerAnimation *)_defaultPresentingAnimation
{
    UITransparentViewControllerAnimation *animation = [UITransparentViewControllerAnimation new];
    
    [animation setAnimationWillBegin:^(UITransparentViewControllerAnimationContext *context) {
        CGRect tmpRect = context.presentingViewController.view.frame;
        tmpRect.origin.y = context.parentViewController.view.frame.size.height;
        context.presentingViewController.view.frame = tmpRect;
    }];
    [animation setAnimation:^(UITransparentViewControllerAnimationContext *context, UITransparentViewControllerAnimationCompletionCallback completionCallback) {
        [UIView animateWithDuration:context.animated ? (SFDeviceSystemVersion < 7.0f ? 0.35f : 0.40f) : 0.0f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            context.presentingViewController.view.frame = context.parentViewController.view.bounds;
        } completion:^(BOOL finished) {
            completionCallback();
        }];
    }];
    
    return animation;
}

+ (UITransparentViewControllerAnimation *)_defaultDismissingAnimation
{
    UITransparentViewControllerAnimation *animation = [UITransparentViewControllerAnimation new];
    
    [animation setAnimationWillBegin:^(UITransparentViewControllerAnimationContext *context) {
    }];
    [animation setAnimation:^(UITransparentViewControllerAnimationContext *context, UITransparentViewControllerAnimationCompletionCallback completionCallback) {
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

- (void)setTransparentViewControllerPresentingAnimation:(UITransparentViewControllerAnimation *)presentingAnimation
{
    [self sf_setAssociatedObject:presentingAnimation key:kTransparentViewControllerPresentingAnimationKey];
}

- (UITransparentViewControllerAnimation *)transparentViewControllerPresentingAnimation
{
    return [self sf_associatedObjectWithKey:kTransparentViewControllerPresentingAnimationKey];
}

- (void)setTransparentViewControllerDismissingAnimation:(UITransparentViewControllerAnimation *)dismissingAnimation
{
    [self sf_setAssociatedObject:dismissingAnimation key:kTransparentViewControllerDismissingAnimationKey];
}

- (UITransparentViewControllerAnimation *)transparentViewControllerDismissingAnimation
{
    return [self sf_associatedObjectWithKey:kTransparentViewControllerDismissingAnimationKey];
}

- (UIViewController *)sf_presentingTransparentViewController
{
    NSValue *weakObjectWrapper = [self sf_associatedObjectWithKey:kTransparentViewControllerKey];
    UIViewController *existsViewController = [weakObjectWrapper sf_weakObject];
    return existsViewController;
}

- (void)sf_presentTransparentViewController:(UIViewController *)presentingTransparentViewController transparent:(BOOL)transparent animated:(BOOL)animated completion:(void(^)())completion
{
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
    
    if ([self respondsToSelector:@selector(transparentViewControllerWillPresent:)]) {
        [(id)self transparentViewControllerWillPresent:presentingTransparentViewController];
    }
    
    UITransparentViewControllerAnimation *animation = [self transparentViewControllerPresentingAnimation];
    if (animation == nil) {
        animation = [UIViewController _defaultPresentingAnimation];
    }
    UITransparentViewControllerAnimationContext *animationContext = [UITransparentViewControllerAnimationContext new];
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
        if ([self respondsToSelector:@selector(transparentViewControllerDidPresent:)]) {
            [(id)self transparentViewControllerDidPresent:presentingTransparentViewController];
        }
    });
}

- (void)sf_presentTransparentViewController:(UIViewController *)presentingTransparentViewController animated:(BOOL)animated completion:(void(^)())completion
{
    [self sf_presentTransparentViewController:presentingTransparentViewController transparent:YES animated:animated completion:completion];
}

- (void)sf_dismissTransparentViewControllerAnimated:(BOOL)animated completion:(void(^)())completion
{
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
        if ([self respondsToSelector:@selector(transparentViewControllerWillDismiss:)]) {
            [(id)self transparentViewControllerWillDismiss:presentingTransparentViewController];
        }
        
        UITransparentViewControllerAnimation *animation = [self transparentViewControllerDismissingAnimation];
        if (animation == nil) {
            animation = [UIViewController _defaultDismissingAnimation];
        }
        UITransparentViewControllerAnimationContext *animationContext = [UITransparentViewControllerAnimationContext new];
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
            
            if ([self respondsToSelector:@selector(transparentViewControllerDidDismiss:)]) {
                [(id)self transparentViewControllerDidDismiss:presentingTransparentViewController];
            }
            
            [parentTransparentViewController sf_removeAssociatedObjectWithKey:kTransparentViewControllerKey];
            
            if (completion) {
                completion();
            }
        });
    }
}

@end
