//
//  UIViewController+Loading.h
//  SFiOSKit
//
//  Created by yangzexin on 11/3/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFViewControllerLoadingSupport : NSObject

+ (instancetype)sharedSupport;

+ (instancetype)support;

@property (nonatomic, copy) void(^loadingUpdate)(UIView *superView, BOOL show, BOOL loadingOrWaiting);

@end

@interface UIViewController (SFLoading)

- (void)sf_setLoadingSupport:(SFViewControllerLoadingSupport *)support;
- (SFViewControllerLoadingSupport *)sf_loadingSupport;

- (void)sf_setLoadingOrWaitingShowable:(BOOL)showable;
- (BOOL)sf_loadingOrWaitingShowable;

- (void)sf_setLoading:(BOOL)loading;
- (void)sf_setWaiting:(BOOL)waiting;
- (void)sf_setLoading:(BOOL)loading identifier:(NSString *)identifier;
- (void)sf_setWaiting:(BOOL)waiting identifier:(NSString *)identifier;

- (void)sf_dismissLoadingOrWaiting;
- (BOOL)sf_shouldShowLoadingOrWaiting;

- (void)sf_willStartLoadingOrWaiting;
- (void)sf_willFinishLoadingOrWaiting;

@end

@interface UIViewController (SFCenterTips)

- (void)sf_setCenterTipsTransparent:(BOOL)transparent;
- (BOOL)sf_centerTipsTransparent;

- (void)sf_setCenterTipsTopMargin:(CGFloat)topMargin;
- (CGFloat)sf_centerTipsTopMargin;

- (void)sf_setCenterTips:(NSString *)tips;
- (void)sf_setCenterTips:(NSString *)tips toView:(UIView *)containView;
- (void)sf_hideCenterTips;

@end

@interface UIViewController (SFToast)

- (void)toast:(NSString *)text;
- (void)toast:(NSString *)text identifier:(NSString *)identifier;
- (void)toast:(NSString *)text completion:(void(^)())completion;
- (void)toast:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds;
- (void)toast:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier;
- (void)toast:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier completion:(void(^)())completion;

@end
