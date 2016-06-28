//
//  SFWaitingIndicator.m
//  SFiOSKit
//
//  Created by yangzexin on 11/3/12.
//  Copyright (c) 2012 yangzexin. All rights reserved.
//

#import "SFWaitingIndicator.h"
#import <QuartzCore/QuartzCore.h>
#import <SFFoundation/SFFoundation.h>

typedef enum {
    SFWaitingIndicatorPositionTop,
    SFWaitingIndicatorPositionLeft,
    SFWaitingIndicatorPositionRight,
    SFWaitingIndicatorPositionBottom
} SFWaitingIndicatorPosition;

@interface WaitingView : UIView

@property (nonatomic, strong) UIView *blockView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *backgroundRoundView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) SFWaitingIndicatorPosition indicatorPosition;

@property (nonatomic, assign) BOOL animatingShowing;
@property (nonatomic, assign) BOOL animatingHiddenning;

@end

@implementation WaitingView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.blockView = [[UIView alloc] init];
    [self addSubview:_blockView];
    
    self.containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:_containerView];
    
    self.backgroundRoundView = [[UIView alloc] init];
    _backgroundRoundView.backgroundColor = [UIColor blackColor];
    _backgroundRoundView.layer.cornerRadius = 12.0f;
    _backgroundRoundView.alpha = 0.72f;
    [_containerView addSubview:_backgroundRoundView];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_containerView addSubview:_indicatorView];
    
    self.textLabel = [[UILabel alloc] init];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.font = [UIFont systemFontOfSize:14.0f];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.hidden = YES;
    [_containerView addSubview:_textLabel];
    self.indicatorPosition = SFWaitingIndicatorPositionBottom;
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat containerViewWidth = 72.0f;
    CGFloat containerViewHeight = 72.0f;
    CGFloat textLabelHeight = 50.0f;
    
    _containerView.frame = CGRectMake((self.frame.size.width - containerViewWidth) / 2,
                                      (self.frame.size.height - containerViewHeight) / 2 - containerViewHeight / 2,
                                      containerViewWidth,
                                      containerViewHeight);
    _backgroundRoundView.frame = _containerView.bounds;
    _indicatorView.frame = CGRectMake(0, 0, containerViewWidth, containerViewHeight - 20);
    
    CGFloat size = 40.0f;
    if(self.indicatorPosition == SFWaitingIndicatorPositionLeft || self.indicatorPosition == SFWaitingIndicatorPositionRight){
        size = 20.0f;
    }
    _indicatorView.frame = CGRectMake((containerViewWidth - size) / 2, (containerViewHeight - size) / 2, size, size);
    _textLabel.frame = CGRectMake(0, containerViewHeight - textLabelHeight, containerViewWidth, textLabelHeight);
}

@end

@implementation SFWaitingIndicator

+ (NSMutableDictionary *)viewDictionary {
    static NSMutableDictionary *dict = nil;
    @synchronized(self.class){
        if(dict == nil){
            dict = [NSMutableDictionary dictionary];
        }
    }
    
    return dict;
}

+ (void)showWaiting:(BOOL)waiting inView:(UIView *)view {
    [self showWaiting:waiting inView:view identifier:@""];
}

+ (void)showWaiting:(BOOL)waiting inView:(UIView *)view identifier:(NSString *)identifier {
    if(!view) {
        return;
    }
    
    WaitingView *waitingView = [view sf_associatedObjectWithKey:@"waitingView"];
    if (waitingView == nil) {
        waitingView = [[WaitingView alloc] initWithFrame:view.bounds];
        waitingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [waitingView.indicatorView startAnimating];
        
        [view addSubview:waitingView];
        [view sf_setAssociatedObject:waitingView key:@"waitingView"];
    }
    
    NSMutableArray *waitingIdentifiers = [view sf_associatedObjectWithKey:@"waitingIdentifiers"];
    if (waitingIdentifiers == nil) {
        waitingIdentifiers = [NSMutableArray array];
        [view sf_setAssociatedObject:waitingIdentifiers key:@"waitingIdentifiers"];
    }
    
    if (identifier == nil) {
        identifier = @"";
    }
    if (waiting) {
        [waitingIdentifiers addObject:identifier];
    } else {
        [waitingIdentifiers removeObject:identifier];
    }
    
    BOOL hidesWaitingView = waitingIdentifiers.count == 0;
    if (!hidesWaitingView) {
        waitingView.hidden = hidesWaitingView;
        [view bringSubviewToFront:waitingView];
        waitingView.animatingShowing = YES;
        [UIView animateWithDuration:.25f animations:^{
            waitingView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            waitingView.animatingShowing = NO;
        }];
    } else {
        waitingView.animatingHiddenning = YES;
        [UIView animateWithDuration:.25f animations:^{
            waitingView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (!waitingView.animatingShowing) {
                waitingView.hidden = hidesWaitingView;
            }
            waitingView.alpha = 1.0f;
            waitingView.animatingHiddenning = NO;
        }];
    }
}

+ (void)showLoading:(BOOL)loading inView:(UIView *)view {
    [self showLoading:loading inView:view transparentBackground:NO];
}

+ (void)showLoading:(BOOL)loading inView:(UIView *)view transparentBackground:(BOOL)transparentBackground {
    [self showLoading:loading inView:view transparentBackground:transparentBackground identifier:@""];
}

+ (void)showLoading:(BOOL)loading inView:(UIView *)view transparentBackground:(BOOL)transparentBackground identifier:(NSString *)identifier {
    if(!view) {
        return;
    }
    
    WaitingView *waitingView = [view sf_associatedObjectWithKey:@"loadingView"];
    if (waitingView == nil) {
        waitingView = [[WaitingView alloc] initWithFrame:view.bounds];
        waitingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        waitingView.backgroundRoundView.hidden = YES;
        waitingView.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        if ([waitingView.indicatorView respondsToSelector:@selector(color)]) {
            waitingView.indicatorView.color = [UIColor blackColor];
        }
        waitingView.backgroundColor = transparentBackground ? [UIColor clearColor] : [UIColor whiteColor];
        [waitingView.indicatorView startAnimating];
        
        [view addSubview:waitingView];
        [view sf_setAssociatedObject:waitingView key:@"loadingView"];
    }
    
    NSMutableArray *loadingIdentifiers = [view sf_associatedObjectWithKey:@"loadingIdentifiers"];
    if (loadingIdentifiers == nil) {
        loadingIdentifiers = [NSMutableArray array];
        [view sf_setAssociatedObject:loadingIdentifiers key:@"loadingIdentifiers"];
    }
    
    if (identifier == nil) {
        identifier = @"";
    }
    if (loading) {
        [loadingIdentifiers addObject:identifier];
    } else {
        [loadingIdentifiers removeObject:identifier];
    }
    
    BOOL hidesWaitingView = loadingIdentifiers.count == 0;
    waitingView.hidden = hidesWaitingView;
    if (!hidesWaitingView) {
        [view bringSubviewToFront:waitingView];
    }
}

@end
