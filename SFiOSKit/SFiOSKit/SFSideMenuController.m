//
//  SFSideMenuController.m
//  SFiOSKit
//
//  Created by yangzexin on 11/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SFSideMenuController.h"

#import "UIView+SFAddition.h"
#import "SFGestureBackDetector.h"
#import "SFAnimationDelegateProxy.h"

static CGFloat kValidPanDistance = 37;

@interface SFSideMenuController () <SFGestureBackDetectorDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIViewController *menuViewController;
@property (nonatomic, strong) UIViewController *contentViewController;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITapGestureRecognizer *contentViewTapGestureRecognizer;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, assign) BOOL menuShown;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftShowContentViewControllerGestureRecognizer;

@property (nonatomic, strong) SFGestureBackDetector *gestureBackDetector;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, assign) CGFloat statusBarX;

@end

@implementation SFSideMenuController

- (id)initWithMenuViewController:(UIViewController *)menuViewController contentViewController:(UIViewController *)contentViewController {
    self = [super init];
    
    self.menuViewController = menuViewController;
    self.contentViewController = contentViewController;
    self.widthPercentForMenuViewController = 0.50f;
    self.scaleTransformForContentViewController = 0.70f;
    
    return self;
}

- (void)loadView {
    [super loadView];
    self.backgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = _backgroundImage;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:imageView];
        imageView;
    });
    
    self.contentView = ({
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor clearColor];
        self.contentViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapped:)];
        [view addGestureRecognizer:_contentViewTapGestureRecognizer];
        [self.view addSubview:view];
        
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowRadius = 5.0f;
        view.layer.shadowOpacity = 0.70f;
        view.layer.shadowOffset = CGSizeMake(0, 1);
        CGPathRef path = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
        [view.layer setShadowPath:path];
        
        view;
    });
    
    [self _restoreMenuControllerPosition];
    
    [self addChildViewController:_contentViewController];
    [_contentView addSubview:_contentViewController.view];
    [_contentViewController didMoveToParentViewController:self];
    
    [self _restoreContentViewControllerPosition];
    
    [self.view addGestureRecognizer:({
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureRecognizer:)];
        panGestureRecognizer.delegate = self;
        self.panGestureRecognizer = panGestureRecognizer;
        panGestureRecognizer;
    })];
    
    self.gestureBackDetector = ({
        SFGestureBackDetector *gestureBackDetector = [SFGestureBackDetector detectorWithValidDistance:[self _validPanDistance]];
        gestureBackDetector.delegate = self;
        gestureBackDetector;
    });
    
    [self _updateViewState];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self _shouldTriggerMoveStatusBar]) {
        [self _moveStatusBar];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self _shouldTriggerMoveStatusBar]) {
        [SFSideMenuController _moveStatusBarWithX:0];
    }
}

+ (void)_moveStatusBarWithX:(CGFloat)x {
    @try {
        UIView *statusBar = [[UIApplication sharedApplication] valueForKey:[@[@"status", @"Bar"] componentsJoinedByString:@""]];
        statusBar.transform = CGAffineTransformMakeTranslation(x, 0.0f);
    }
    @catch (NSException *exception) {
        
    }
}

- (void)_moveStatusBar {
    [SFSideMenuController _moveStatusBarWithX:self.statusBarX];
}

- (BOOL)_shouldTriggerMoveStatusBar {
    return fabs(self.scaleTransformForContentViewController) == 1.0f;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (_menuShown) {
        return [self.menuViewController preferredStatusBarStyle];
    }
    
    return [self.contentViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    if (_menuShown) {
        return [self.menuViewController prefersStatusBarHidden];
    }
    
    return [self.contentViewController prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    if (_menuShown) {
        return [self.menuViewController preferredStatusBarUpdateAnimation];
    }
    
    return [self.contentViewController preferredStatusBarUpdateAnimation];
}

- (void)_addMenuControllerIfNeeded {
    if (_menuViewController.parentViewController != self) {
        [self addChildViewController:_menuViewController];
        [self.view insertSubview:_menuViewController.view belowSubview:self.contentView];
        [_menuViewController didMoveToParentViewController:self];
    }
}

- (void)_removeMenuController {
    [_menuViewController willMoveToParentViewController:nil];
    [_menuViewController.view removeFromSuperview];
    [_menuViewController removeFromParentViewController];
}

- (void)_menuViewControllerDidShown {
    _gestureBackDetector.validDistance = self.view.frame.size.width;
    _gestureBackDetector.validLeftEdge = [self _widthForMenuController] - 30;
    if ([self.delegate respondsToSelector:@selector(sideMenuControllerMenuViewControllerDidShown:)]) {
        [self.delegate sideMenuControllerMenuViewControllerDidShown:self];
    }
}

- (CGFloat)_validPanDistance {
    return _leftPanDistance == 0 ? kValidPanDistance : _leftPanDistance;
}

- (void)_contentViewControllerDidShown {
    _gestureBackDetector.validDistance = [self _validPanDistance];
    _gestureBackDetector.validLeftEdge = 0;
    if ([self.delegate respondsToSelector:@selector(sideMenuControllerContentViewControllerDidShown:)]) {
        [self.delegate sideMenuControllerContentViewControllerDidShown:self];
    }
    [self _removeMenuController];
}

- (void)_swipeRightGestureRecognizer:(UISwipeGestureRecognizer *)gr {
    if (_menuShown) {
        [self showContentViewControllerAnimated:YES completion:nil];
    }
}

- (void)_swipeLeftGestureRecognizer:(UISwipeGestureRecognizer *)gr {
    if (_disableGestureShowMenu) {
        return;
    }
    CGPoint point = [gr locationInView:self.view];
    if (point.x > 72.0f) {
        return;
    }
    if (!_menuShown) {
        UIViewController *viewController = _contentViewController;
        BOOL showable = YES;
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (id)viewController;
            showable = navigationController.viewControllers.count == 1;
        }
        if (showable) {
            [self showMenuViewControllerAnimated:YES completion:nil];
        }
    }
}

- (BOOL)_shouldTriggerPanGesture {
    UIViewController *contentViewController = self.contentViewController;
    if ([contentViewController isKindOfClass:[UINavigationController class]]) {
        contentViewController = [(id)contentViewController topViewController];
    }
    BOOL shouldTrigger = YES;
    if ([contentViewController respondsToSelector:@selector(shouldSideMenuControllerTriggerGesture:)]) {
        shouldTrigger = [(id)contentViewController shouldSideMenuControllerTriggerGesture:self];
    }
    return shouldTrigger;
}

- (void)_panGestureRecognizer:(UIPanGestureRecognizer *)gr {
    if (_disableGestureShowMenu) {
        return;
    }
    if ([self _shouldTriggerPanGesture]) {
        [_gestureBackDetector panGestureRecognizerDidTrigger:gr offsetX:_contentView.frame.origin.x];
    }
}

- (CGFloat)_widthForMenuController {
    return (NSInteger)(self.view.frame.size.width * _widthPercentForMenuViewController);
}

- (void)_restoreMenuControllerPosition {
    CGRect tmpRect = self.view.bounds;
    tmpRect.size.width = [self _widthForMenuController];
    tmpRect.origin.x = - tmpRect.size.width;
    _menuViewController.view.frame = tmpRect;
}

- (void)_restoreContentViewControllerPosition {
    _contentViewController.view.frame = _contentView.bounds;
}

+ (void)_animateWithBlock:(void(^)())block completion:(void(^)())completion {
    [self _animateWithDuration:.30 block:block completion:completion];
}

+ (void)_animateWithDuration:(double)duration block:(void(^)())block completion:(void(^)())completion {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:block completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)showMenuViewControllerAnimated:(BOOL)animated completion:(void (^)())completion {
    [self _showMenuViewControllerAnimated:animated restoreViewState:YES animatesMenu:_animatesShowMenu animationDuration:.30f completion:completion];
}

- (void)_showMenuViewControllerAnimated:(BOOL)animated restoreViewState:(BOOL)restoreViewState animatesMenu:(BOOL)animatesMenu animationDuration:(NSTimeInterval)animationDuration completion:(void(^)())completion {
    if (_menuShown == NO) {
        self.menuShown = YES;
        [self _addMenuControllerIfNeeded];
        [self _updateViewState];
        _menuViewController.view.backgroundColor = [UIColor clearColor];
        
        [_contentViewController beginAppearanceTransition:NO animated:animated];
        
        _menuViewController.view.alpha = animatesMenu ? 0.0f : 1.0f;
        if (restoreViewState) {
            [self _restoreMenuControllerPosition];
        }
        
        BOOL parallex = self.parallexAnimation;
        
        void(^animationForMenu)() = ^{
            CGRect tmpRect = _menuViewController.view.frame;
            tmpRect.origin.x = 0;
            _menuViewController.view.frame = tmpRect;
            _menuViewController.view.alpha = animatesMenu ? 0.80f : 1.0f;
        };
        
        void(^animationForContent)() = ^{
            
            if ([self _shouldTriggerMoveStatusBar]) {
                self.statusBarX = [self _widthForMenuController];
                [self _moveStatusBar];
            }
            
            CGRect tmpRect = _menuViewController.view.frame;
            
            _contentView.transform = CGAffineTransformMakeScale(_scaleTransformForContentViewController, _scaleTransformForContentViewController);
            tmpRect = _contentView.frame;
            tmpRect.origin.x = [self _widthForMenuController];
            _contentView.frame = tmpRect;
        };
        
        void(^animationBlock)() = ^{
            if (!parallex || !animated) {
                animationForMenu();
            }
            animationForContent();
        };
        void(^animationCompletion)() = ^{
            [_contentViewController endAppearanceTransition];
            if (completion) {
                completion();
            }
            [self _menuViewControllerDidShown];
        };
        if (animated) {
            [[self class] _animateWithDuration:animationDuration block:animationBlock completion:^{
                if (animatesMenu && !parallex) {
                    [UIView animateWithDuration:0.07f animations:^{
                        _menuViewController.view.alpha = 1.0f;
                    }];
                }
                
                if (!parallex) {
                    if (animationCompletion) {
                        animationCompletion();
                    }
                }
            }];
            if (parallex) {
                [SFSideMenuController _animateWithDuration:.10f block:animationForMenu completion:^{
                    if (animatesMenu) {
                        [UIView animateWithDuration:0.07f animations:^{
                            _menuViewController.view.alpha = 1.0f;
                        }];
                    }
                    
                    if (animationCompletion) {
                        animationCompletion();
                    }
                }];
            }
        } else {
            animationBlock();
            animationCompletion();
        }
    }
}

- (void)contentViewTapped:(id)gr {
    [self showContentViewControllerAnimated:YES completion:nil];
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void(^)())completion {
    [self setContentViewController:contentViewController showImmediately:NO animated:animated completion:completion];
}

- (void)setContentViewController:(UIViewController *)contentViewController showImmediately:(BOOL)showImmediately animated:(BOOL)animated completion:(void(^)())completion {
    if (contentViewController == _contentViewController) {
        if (completion) {
            completion();
        }
    } else {
        if (_contentViewController) {
            [_contentViewController willMoveToParentViewController:nil];
            [_contentViewController.view removeFromSuperview];
            [_contentViewController removeFromParentViewController];
        }
        self.contentViewController = contentViewController;
        
        [self addChildViewController:_contentViewController];
        [_contentView addSubview:_contentViewController.view];
        [_contentViewController didMoveToParentViewController:self];
        
        [self _restoreContentViewControllerPosition];
        
        [self _updateViewState];
        if (showImmediately) {
            [self showContentViewControllerAnimated:animated completion:completion];
        } else {
            if (completion) {
                completion();
            }
        }
    }
}

- (void)showContentViewControllerAnimated:(BOOL)animated completion:(void (^)())completion {
    [self _showContentViewControllerAnimated:animated notifyTransition:YES animationDuration:.30f completion:completion];
}

- (void)tantantanWithMenuVisibleWidth:(CGFloat)menuVisibleWidth completion:(void(^)())completion {
    self.view.userInteractionEnabled = NO;
    CAKeyframeAnimation *contentViewAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    contentViewAnimation.values = @[@27.0f, @127.0f, @0.0f, @37.0f, @0.0f, @17.0f, @0.0f, @7.0f, @0.0f, @2.0f, @0.0f];
    contentViewAnimation.duration = 1.20f;
    contentViewAnimation.delegate = ({
        SFAnimationDelegateProxy *delegateProxy = [SFAnimationDelegateProxy proxyWithDidStart:nil didFinish:^(BOOL completed) {
            if (completion) {
                completion();
            }
            self.view.userInteractionEnabled = YES;
            self.menuViewController.view.hidden = YES;
            [self _removeMenuController];
        }];
        delegateProxy;
    });
    [self.contentView.layer addAnimation:contentViewAnimation forKey:@"tantantan"];
    
    [self _addMenuControllerIfNeeded];
    CGRect rect = _menuViewController.view.frame;
    rect.origin.x = -rect.size.width + menuVisibleWidth;
    _menuViewController.view.frame = rect;
    _menuViewController.view.hidden = NO;
    _menuViewController.view.backgroundColor = [UIColor clearColor];
}

- (void)_showContentViewControllerAnimated:(BOOL)animated notifyTransition:(BOOL)notifyTransition animationDuration:(NSTimeInterval)animationDuration completion:(void(^)())completion {
    if (_menuShown) {
        self.menuShown = NO;
        
        if (notifyTransition) {
            [_contentViewController beginAppearanceTransition:YES animated:animated];
        }
        
        void(^animationBlock)() = ^{
            [self _restoreMenuControllerPosition];
            _contentView.transform = CGAffineTransformIdentity;
            _contentView.frame = self.view.bounds;
            
            if ([self _shouldTriggerMoveStatusBar]) {
                self.statusBarX = 0;
                [self _moveStatusBar];
            }
        };
        
        void(^animationCompletion)() = ^{
            [self _updateViewState];
            if (completion) {
                completion();
            }
            if (notifyTransition) {
                [_contentViewController endAppearanceTransition];
            }
            [self _contentViewControllerDidShown];
        };
        if (animated) {
            [[self class] _animateWithDuration:animationDuration block:animationBlock completion:animationCompletion];
        } else {
            animationBlock();
            animationCompletion();
        }
    }
}

- (void)setScaleTransformForContentViewController:(float)heightRatioForCenterController {
    if (heightRatioForCenterController < 0.1) {
        heightRatioForCenterController = 0.1;
    }
    if (heightRatioForCenterController > 1.0f) {
        heightRatioForCenterController = 1.0f;
    }
    _scaleTransformForContentViewController = heightRatioForCenterController;
}

- (void)setWidthPercentForMenuViewController:(float)widthPercentForMenuController {
    if (widthPercentForMenuController < 0.1) {
        widthPercentForMenuController = 0.1;
    }
    if (widthPercentForMenuController > 1.0f) {
        widthPercentForMenuController = 1.0f;
    }
    _widthPercentForMenuViewController = widthPercentForMenuController;
}

- (void)_updateViewState {
    _menuViewController.view.hidden = !_menuShown;
    _contentViewController.view.userInteractionEnabled = !_menuShown;
    _contentViewTapGestureRecognizer.enabled = _menuShown;
    _swipeLeftShowContentViewControllerGestureRecognizer.enabled = _menuShown;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    _backgroundImageView.image = _backgroundImage;
}

#pragma mark - SFGestureBackDetector
- (void)_gestureBackDetectorGestureDidEnd {
    float percent = _contentView.frame.origin.x / [self _widthForMenuController];
    
    SFGestureBackDetectorDirection direction = _gestureBackDetector.direction;
    if (_gestureBackDetector.quickSlide == NO) {
        if (direction == SFGestureBackDetectorDirectionRight) {
            direction = percent < 0.20f ? SFGestureBackDetectorDirectionLeft : SFGestureBackDetectorDirectionRight;
        } else {
            direction = percent > 0.70f ? SFGestureBackDetectorDirectionRight : SFGestureBackDetectorDirectionLeft;
        }
    }
    NSTimeInterval animationDuration = .25f;
    if (direction == SFGestureBackDetectorDirectionRight) {
        self.menuShown = NO;
        self.panGestureRecognizer.enabled = NO;
        __weak typeof(self) weakSelf = self;
        [self _showMenuViewControllerAnimated:YES restoreViewState:NO animatesMenu:NO animationDuration:animationDuration completion:^{
            weakSelf.panGestureRecognizer.enabled = YES;
        }];
    } else {
        BOOL menuShownLast = self.menuShown;
        self.menuShown = YES;
        self.panGestureRecognizer.enabled = NO;
        __weak typeof(self) weakSelf = self;
        [self _showContentViewControllerAnimated:YES notifyTransition:menuShownLast animationDuration:animationDuration completion:^{
            weakSelf.panGestureRecognizer.enabled = YES;
        }];
    }
}

- (void)gestureBackDetectorGestureDidRelease:(SFGestureBackDetector *)gestureBackDetector gestureBackable:(BOOL)gestureBackable {
    [self _gestureBackDetectorGestureDidEnd];
}

- (void)gestureBackDetectorGestureDidCancel:(SFGestureBackDetector *)gestureBackDetector {
    [self _gestureBackDetectorGestureDidEnd];
}

- (void)gestureBackDetectorGestureWillStart:(SFGestureBackDetector *)gestureBackDetector {
    if (_endEditingWhenGestureWillTrigger) {
        [self.view endEditing:YES];
    }
    [self _addMenuControllerIfNeeded];
    _menuViewController.view.backgroundColor = [UIColor clearColor];
    _backgroundImageView.image = _backgroundImage;
    _menuViewController.view.hidden = NO;
}

- (void)gestureBackDetectorGesture:(SFGestureBackDetector *)gestureBackDetector moveingWithDistanceDelta:(CGFloat)distanceDelta {
    CGRect tmpRect = _contentView.frame;
    tmpRect.origin.x += distanceDelta;
    if (tmpRect.origin.x < [self _widthForMenuController] && tmpRect.origin.x >= 0) {
        _contentView.frame = tmpRect;
        
        float percent = tmpRect.origin.x / [self _widthForMenuController];
        
        float scale = 1.0f - percent * (1.0f - _scaleTransformForContentViewController);
        _contentView.transform = CGAffineTransformMakeScale(scale, scale);
        
        tmpRect = _menuViewController.view.frame;
        CGFloat menuAvaliableWidth = _menuViewController.view.frame.size.width;
        tmpRect.origin.x = -(menuAvaliableWidth * (1.0f - percent));
        _menuViewController.view.frame = tmpRect;
        if (self.animatesShowMenu) {
            _menuViewController.view.alpha = percent + .20f;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    BOOL should = YES;
    if ([self _shouldTriggerPanGesture]) {
        should = ![_gestureBackDetector isPrepared];
    }
    
    return should;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.view];
    if (touchPoint.x < _gestureBackDetector.validDistance && gestureRecognizer == _panGestureRecognizer && !_disableGestureShowMenu && [self _shouldTriggerPanGesture]) {
        return YES;
    }
    
    return NO;
}

@end
