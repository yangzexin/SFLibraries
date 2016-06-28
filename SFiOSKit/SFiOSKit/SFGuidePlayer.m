//
//  SFGuidePlayer.m
//  SFiOSKit
//
//  Created by yangzexin on 1/8/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFGuidePlayer.h"
#import "SFiOSKitConstants.h"

@interface SFGuidePlayer () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL stoping;
@property (nonatomic, strong) NSArray *imageViews;
@property (nonatomic, strong) UIView *lastGuideView;

@end

@implementation SFGuidePlayer

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.backgroundColor = [UIColor blackColor];
    [self addSubview:_backgroundView];
    
    return self;
}

- (void)playInViewController:(UIViewController *)viewController {
    UIView *targetView = nil;
    if (viewController.navigationController) {
        targetView = viewController.navigationController.view;
    } else {
        targetView = viewController.view;
    }
    
    NSArray *guideImages = [self _guideImages];
    
    if ([_pageIndicator respondsToSelector:@selector(setNumberOfPages:)]) {
        [_pageIndicator setNumberOfPages:guideImages.count];
    }
    
    self.frame = targetView.bounds;
    [self removeFromSuperview];
    [targetView addSubview:self];
    for (UIView *subview in [self subviews]) {
        if (subview != _backgroundView) {
            [subview removeFromSuperview];
        }
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(targetView.frame.size.width * guideImages.count, scrollView.frame.size.height);
    scrollView.delegate = self;
    self.scrollView = scrollView;
    [self addSubview:scrollView];
    
    if (_pageIndicator && [_pageIndicator superview] != nil) {
        [_pageIndicator removeFromSuperview];
    }
    [self addSubview:_pageIndicator];
    CGRect tmpRect = _pageIndicator.frame;
    tmpRect.size.width = self.frame.size.width;
    tmpRect.origin.x = 0;
    tmpRect.origin.y = self.frame.size.height - tmpRect.size.height;
    _pageIndicator.frame = tmpRect;
    
    NSMutableArray *imageViews = [NSMutableArray array];
    [guideImages enumerateObjectsUsingBlock:^(UIImage *guideImage, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(targetView.frame.size.width * idx, (SFIs3Dot5InchScreen ? _paddingTopFor35 : 0) + (SFDeviceSystemVersion < 7.0f ? (SFIs3Dot5InchScreen ? -5 : 10.0f) : 0.0f), targetView.frame.size.width, targetView.frame.size.height)];
        imageView.image = guideImage;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [scrollView addSubview:imageView];
        if (idx == guideImages.count - 1) {
            self.lastGuideView = imageView;
        }
        [imageViews addObject:imageView];
    }];
    self.imageViews = imageViews;
    
    if (_showAnimated) {
        self.alpha = 0;
        [UIView animateWithDuration:0.30f animations:^{
            self.alpha = 1.0;
        }];
    }
}

- (NSArray *)_guideImages {
    return SFIs3Dot5InchScreen ? self.picturesFor35 : self.picturesFor40;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSArray *guideImages = [self _guideImages];
    _scrollView.contentSize = CGSizeMake(guideImages.count * _scrollView.frame.size.width, _scrollView.frame.size.height);
    [_imageViews enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL *stop) {
        CGRect tmpRect = obj.frame;
        tmpRect.origin.x = self.frame.size.width * idx;
        obj.frame = tmpRect;
    }];
}

- (void)finishPlayWithAnimated:(BOOL)animated {
    [self _stopPlayWithAnimated:animated fadeAnimation:YES];
}

- (void)_stopPlayWithAnimated:(BOOL)animated fadeAnimation:(BOOL)fadeAnimation {
    void(^animationCompletion)() = ^{
        [self removeFromSuperview];
        if (_guideDidPlayFinish) {
            _guideDidPlayFinish();
            self.guideDidPlayFinish = nil;
        }
    };
    void(^animation)() = nil;
    if (fadeAnimation) {
        animation = ^{
            self.alpha = 0.0f;
        };
    } else {
        animation = ^{
            CGRect tmpRect = _scrollView.frame;
            tmpRect.origin.x = -tmpRect.size.width;
            _scrollView.frame = tmpRect;
            
            if (_pageIndicator) {
                tmpRect = _pageIndicator.frame;
                tmpRect.origin.x = -tmpRect.size.width;
                _pageIndicator.frame = tmpRect;
            }
            
            _backgroundView.alpha = 0.0f;
            _scrollView.alpha = 0.0f;
        };
    }
    
    [UIView animateWithDuration:fadeAnimation ? 0.50f : 0.30f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:animation completion:^(BOOL finished) {
        if (animationCompletion) {
            animationCompletion();
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_stoping) {
        return;
    }
    BOOL removeTrigger = NO;
    CGFloat draggedWidth = (scrollView.contentOffset.x + scrollView.frame.size.width) - scrollView.contentSize.width;
    removeTrigger = draggedWidth > 70;
    draggedWidth /= 2;
    _backgroundView.alpha = 1 - (draggedWidth / 100.0f);
    if (removeTrigger) {
        self.stoping = YES;
        [self _stopPlayWithAnimated:YES fadeAnimation:NO];
    }
    NSInteger currentPageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    if ([_pageIndicator respondsToSelector:@selector(setCurrentPageIndex:)]) {
        [_pageIndicator setCurrentPageIndex:currentPageIndex];
    }
    if (currentPageIndex == _picturesFor40.count - 1 && _viewForTapToFinish != nil && [[self lastGuideView] viewWithTag:10001] == nil) {
        UIView *view = _viewForTapToFinish();
        if (view) {
            view.tag = 10001;
            [[self lastGuideView] addSubview:view];
            [[self lastGuideView] setUserInteractionEnabled:YES];
        }
    }
}

@end
