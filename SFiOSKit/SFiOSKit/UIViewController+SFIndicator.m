//
//  UIViewController+Loading.m
//  SFiOSKit
//
//  Created by yangzexin on 11/3/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "UIViewController+SFIndicator.h"

#import <SFFoundation/SFFoundation.h>

#import "UIColor+SFAddition.h"
#import "SFToast.h"
#import "SFWaitingIndicator.h"

@interface SFViewControllerLoadingSupport ()

@end

@implementation SFViewControllerLoadingSupport

+ (instancetype)sharedSupport {
    static SFViewControllerLoadingSupport *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self support];
    });
    
    return instance;
}

+ (instancetype)support {
    SFViewControllerLoadingSupport *support = [self new];
    
    return support;
}

@end

@implementation UIViewController (SFLoading)

- (NSMutableArray *)loadingIdentifiersWithHidesMainView:(BOOL)hidesMainView {
    NSString *key = [NSString stringWithFormat:@"sf_loadingIdentifiers-%@", hidesMainView ? @"YES" : @"NO"];
    NSMutableArray *loadingIdentifiers = [self sf_associatedObjectWithKey:key];
    if (loadingIdentifiers == nil) {
        loadingIdentifiers = [NSMutableArray array];
        [self sf_setAssociatedObject:loadingIdentifiers key:key];
    }
    
    return loadingIdentifiers;
}

- (void)sf_setLoadingOrWaitingShowable:(BOOL)showable {
    [self sf_setAssociatedObject:@(showable) key:@"sf_loadingOrWaitingShowable"];
}

- (BOOL)sf_loadingOrWaitingShowable {
    NSNumber *loadingShowable = [self sf_associatedObjectWithKey:@"sf_loadingOrWaitingShowable"];
    BOOL showable = YES;
    if (loadingShowable) {
        showable = [loadingShowable boolValue];
    }
    
    return showable;
}

- (void)sf_setLoadingSupport:(SFViewControllerLoadingSupport *)support {
    [self sf_setAssociatedObject:support key:@"sf_loadingSupport"];
}

- (SFViewControllerLoadingSupport *)sf_loadingSupport {
    SFViewControllerLoadingSupport *support = [self sf_associatedObjectWithKey:@"sf_loadingSupport"];
    if (support == nil) {
        support = [SFViewControllerLoadingSupport sharedSupport];
        if (support.loadingUpdate == nil) {
            [[SFViewControllerLoadingSupport sharedSupport] setLoadingUpdate:^(UIView *superView, BOOL loading, BOOL loadingOrWaiting) {
                if (loadingOrWaiting) {
                    [SFWaitingIndicator showLoading:loading inView:superView];
                } else {
                    [SFWaitingIndicator showWaiting:loading inView:superView];
                }
            }];
        }
    }
    
    return support;
}

- (void)_showLoadingToView:(UIView *)view hidesMainView:(BOOL)hidesMainView {
    NSAssert(self.sf_loadingSupport.loadingUpdate != nil, @"loadingUpdate did not implemented, adding support by this method:[[SFViewControllerLoadingSupport sharedSupport] setLoadingUpdate:^(UIView *superView, BOOL loading){"
             "}]");
    self.sf_loadingSupport.loadingUpdate(view, YES, hidesMainView);
}

- (void)_hideLoadingFromView:(UIView *)view hidesMainView:(BOOL)hidesMainView {
    NSAssert(self.sf_loadingSupport.loadingUpdate != nil, @"loadingUpdate did not implemented, adding support by this method:[[SFViewControllerLoadingSupport sharedSupport] setLoadingUpdate:^(UIView *superView, BOOL loading){"
             "}]");
    self.sf_loadingSupport.loadingUpdate(view, NO, hidesMainView);
}

- (void)setLoading:(BOOL)loading hidesMainView:(BOOL)hidesMainView identifier:(NSString *)identifier {
    if (identifier.length == 0) {
        identifier = @"Default";
    }
    
    if ([self sf_loadingOrWaitingShowable]) {
        self.view.userInteractionEnabled = !loading;
        if (loading && [self sf_shouldShowLoadingOrWaiting]) {
            [[self loadingIdentifiersWithHidesMainView:hidesMainView] addObject:identifier];
            
            if (hidesMainView) {
                UIView *maskView = [self sf_associatedObjectWithKey:@"_loadingMaskView"];
                if (maskView == nil) {
                    maskView = [[UIView alloc] initWithFrame:self.view.bounds];
                    maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [self.view addSubview:maskView];
                    [self sf_setAssociatedObject:maskView key:@"_loadingMaskView"];
                }
                maskView.hidden = NO;
                if (loading) {
                    maskView.backgroundColor = self.view.backgroundColor;
                }
            }
            [self _showLoadingToView:self.view hidesMainView:hidesMainView];
            [self sf_willStartLoadingOrWaiting];
        } else {
            [[self loadingIdentifiersWithHidesMainView:hidesMainView] removeObject:identifier];
            if ([[self loadingIdentifiersWithHidesMainView:hidesMainView] count] == 0) {
                UIView *maskView = [self sf_associatedObjectWithKey:@"_loadingMaskView"];
                maskView.hidden = YES;
                [self _hideLoadingFromView:self.view hidesMainView:hidesMainView];
            }
            [self sf_willFinishLoadingOrWaiting];
        }
    }
}

- (void)sf_setWaiting:(BOOL)waiting identifier:(NSString *)identifier {
    [self setLoading:waiting hidesMainView:NO identifier:identifier];
}

- (void)sf_setLoading:(BOOL)loading identifier:(NSString *)identifier {
    [self setLoading:loading hidesMainView:YES identifier:identifier];
}

- (void)sf_setLoading:(BOOL)loading {
    [self sf_setLoading:loading identifier:nil];
}

- (void)sf_setWaiting:(BOOL)waiting {
    [self sf_setWaiting:waiting identifier:nil];
}

- (void)sf_dismissLoadingOrWaiting {
    self.view.userInteractionEnabled = YES;
    [self _hideLoadingFromView:self.view hidesMainView:NO];
}

- (BOOL)sf_shouldShowLoadingOrWaiting {
    return YES;
}

- (void)sf_willStartLoadingOrWaiting {
}

- (void)sf_willFinishLoadingOrWaiting {
}

@end

@implementation UIViewController (SFCenterTips)

- (void)sf_setCenterTips:(NSString *)tips {
    [self sf_setCenterTips:tips toView:self.view];
}

- (void)sf_setCenterTips:(NSString *)tips toView:(UIView *)containView {
    UIView *tipsLabelContainerView = [self sf_associatedObjectWithKey:@"TipsLabelContainerView"];
    UILabel *tipsLabel = [self sf_associatedObjectWithKey:@"TipsLabel"];
    if (tipsLabel == nil && containView != nil) {
        tipsLabelContainerView = [[UIView alloc] initWithFrame:containView.bounds];
        tipsLabelContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self sf_setAssociatedObject:tipsLabelContainerView key:@"TipsLabelContainerView"];
        
        tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, containView.frame.size.width - 20, containView.frame.size.height - containView.frame.size.height * 0.25f)];
        tipsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tipsLabel.backgroundColor = [UIColor clearColor];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.font = [UIFont systemFontOfSize:17.0f];
        tipsLabel.textColor = [UIColor sf_colorWithRed:135 green:135 blue:135];
        tipsLabel.userInteractionEnabled = NO;
        tipsLabel.adjustsFontSizeToFitWidth = YES;
        tipsLabel.numberOfLines = 0;
        
        [self sf_setAssociatedObject:tipsLabel key:@"TipsLabel"];
    }
    
    [containView addSubview:tipsLabelContainerView];
    [tipsLabelContainerView addSubview:tipsLabel];
    
    if (tipsLabelContainerView.frame.origin.y != self.sf_centerTipsTopMargin) {
        CGRect tmpFrame = tipsLabelContainerView.frame;
        tmpFrame.origin.y = self.sf_centerTipsTopMargin;
        tmpFrame.size.height = containView.frame.size.height - tmpFrame.origin.y;
        tipsLabelContainerView.frame = tmpFrame;
    }
    
    tipsLabelContainerView.backgroundColor = self.sf_centerTipsTransparent ? [UIColor clearColor] : containView.backgroundColor;
    tipsLabelContainerView.userInteractionEnabled = !self.sf_centerTipsTransparent;
    tipsLabelContainerView.hidden = NO;
    
    tipsLabel.text = tips;
    
    [containView bringSubviewToFront:tipsLabelContainerView];
}

- (void)sf_hideCenterTips {
    UIView *tipsLabelContainerView = [self sf_associatedObjectWithKey:@"TipsLabelContainerView"];
    tipsLabelContainerView.hidden = YES;
}

- (void)sf_setCenterTipsTransparent:(BOOL)centerTipsTransparent {
    [self sf_setAssociatedObject:[NSNumber numberWithBool:centerTipsTransparent] key:@"centerTipsTransparent"];
}

- (BOOL)sf_centerTipsTransparent {
    NSNumber *transparent = [self sf_associatedObjectWithKey:@"centerTipsTransparent"];
    return transparent == nil ? NO : [transparent boolValue];
}

- (CGFloat)sf_centerTipsTopMargin {
    return [[self sf_associatedObjectWithKey:@"centerTipsTopMargin"] floatValue];
}

- (void)sf_setCenterTipsTopMargin:(CGFloat)centerTipsTopMargin {
    [self sf_setAssociatedObject:@(centerTipsTopMargin) key:@"centerTipsTopMargin"];
}

@end

@implementation UIViewController (SFToast)

- (void)toast:(NSString *)text {
    [self toast:text completion:nil];
}

- (void)toast:(NSString *)text identifier:(NSString *)identifier {
    [self toast:text hideAfterSeconds:1.70f identifier:identifier];
}

- (void)toast:(NSString *)text completion:(void(^)())completion {
    [self toast:text hideAfterSeconds:1.70f identifier:nil completion:completion];
}

- (void)toast:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds {
    [self toast:text hideAfterSeconds:hideAfterSeconds identifier:nil];
}

- (void)toast:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier {
    [self toast:text hideAfterSeconds:hideAfterSeconds identifier:identifier completion:nil];
}

- (void)toast:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier completion:(void(^)())completion {
    [SFToast toastInView:self.view text:text hideAfterSeconds:hideAfterSeconds identifier:identifier completion:completion];
}

@end
