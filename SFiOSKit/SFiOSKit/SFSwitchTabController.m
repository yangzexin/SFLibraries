//
//  SFSwitchTabController.m
//  SFiOSKit
//
//  Created by yangzexin on 5/20/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFSwitchTabController.h"

#import <SFFoundation/SFFoundation.h>

@interface SFSwitchTabController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat scrollViewLastContentOffsetX;
@property (nonatomic, assign) BOOL scrollViewDragging;
@property (nonatomic, assign) BOOL scrollViewAnimating;
@property (nonatomic, strong) UIViewController *lastDisplayViewController;
@property (nonatomic, strong) UIViewController *nextDisplayViewController;

@property (nonatomic, assign) BOOL firstAppeared;

@property (nonatomic, copy) void(^scrollAnimationCompletion)();

@end

@implementation SFSwitchTabController

- (id)init {
    self = [super init];
    
    self.selectedIndex = -1;
    
    return self;
}

- (void)loadView {
    [super loadView];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.pagingEnabled = YES;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    __weak typeof(self) weakSelf = self;
    [SFTrackProperty(self.view, frame) change:^(id value) {
        __strong typeof(weakSelf) self = weakSelf;
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.viewControllers.count, self.view.frame.size.height);
    }];
    
    [SFTrackProperty(self, scrollable) change:^(id value) {
        __strong typeof(weakSelf) self = weakSelf;
        self.scrollView.scrollEnabled = self.scrollable;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.firstAppeared) {
        self.firstAppeared = YES;
        if (self.selectedIndex == -1) {
            [self _addChildViewControllerIfNeededWithIndex:0 outAdded:NULL];
            self.selectedIndex = 0;
        } else {
            [self _addChildViewControllerIfNeededWithIndex:self.selectedIndex outAdded:NULL];
        }
    }
}

- (UIViewController *)selectedViewController {
    if (_selectedIndex == -1) {
        return nil;
    }
    
    return [_viewControllers objectAtIndex:_selectedIndex];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if ([_viewControllers count] != 0) {
        [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
            [obj willMoveToParentViewController:nil];
            if ([obj isViewLoaded] && obj.view.superview == self.scrollView) {
                [obj.view removeFromSuperview];
            }
            [obj removeFromParentViewController];
        }];
    }
    _viewControllers = viewControllers;
    
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width * _viewControllers.count, self.view.frame.size.height);
    
    [self scrollViewDidScroll:_scrollView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.selectedViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [self.selectedViewController prefersStatusBarHidden];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    [self setSelectedIndex:selectedIndex animated:animated completion:nil];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated completion:(void(^)())completion {
    if (selectedIndex != _selectedIndex) {
        if (!animated) {
            _selectedIndex = selectedIndex;
        }
        self.scrollViewAnimating = animated;
        [self.scrollView scrollRectToVisible:CGRectMake(selectedIndex * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:animated];
        self.scrollAnimationCompletion = completion;
        self.scrollViewLastContentOffsetX = selectedIndex * _scrollView.frame.size.width;
    }
}

- (UIViewController *)_addChildViewControllerIfNeededWithIndex:(NSInteger)index outAdded:(BOOL *)outAdded {
    UIViewController *nextViewController = nil;
    if (index < _viewControllers.count) {
        UIViewController *viewController = [_viewControllers objectAtIndex:index];
        if (viewController.parentViewController != self) {
            [self addChildViewController:viewController];
            [self.scrollView addSubview:viewController.view];
            viewController.view.frame = CGRectMake(index * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
            [viewController didMoveToParentViewController:self];
            if (outAdded != NULL) {
                *outAdded = YES;
            }
        } else {
            viewController.view.frame = CGRectMake(index * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        }
        nextViewController = viewController;
    }
    
    return nextViewController;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.scrollAnimationCompletion = nil;
    
    self.scrollViewDragging = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    self.scrollViewDragging = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _scrollViewDidStatic];
}

- (void)_scrollViewDidStatic {
    NSInteger scrollViewControllerIndex = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    if (scrollViewControllerIndex != _selectedIndex) {
        if (_nextDisplayViewController) {
            if (self.selectedViewController != self.nextDisplayViewController) {
                [self.selectedViewController willMoveToParentViewController:nil];
                [self.selectedViewController.view removeFromSuperview];
                [self.selectedViewController removeFromParentViewController];
            }
            for (NSInteger i = 0; i < self.viewControllers.count; ++i) {
                if (i != self.selectedIndex && i != scrollViewControllerIndex) {
                    UIViewController *viewController = [self.viewControllers objectAtIndex:i];
                    [viewController willMoveToParentViewController:nil];
                    [viewController.view removeFromSuperview];
                    [viewController removeFromParentViewController];
                }
            }
            [self.selectedViewController endAppearanceTransition];
        }
        [self willChangeValueForKey:@"selectedIndex"];
        _selectedIndex = scrollViewControllerIndex;
        [self didChangeValueForKey:@"selectedIndex"];
        if ([_delegate respondsToSelector:@selector(switchTabController:didSwitchToIndex:)]) {
            [_delegate switchTabController:self didSwitchToIndex:_selectedIndex];
        }
    } else {
        if (_nextDisplayViewController && self.nextDisplayViewController != self.selectedViewController) {
            [self.selectedViewController beginAppearanceTransition:YES animated:NO];
            [self.nextDisplayViewController beginAppearanceTransition:NO animated:NO];
            
            [self.nextDisplayViewController willMoveToParentViewController:nil];
            [self.nextDisplayViewController.view removeFromSuperview];
            [self.nextDisplayViewController removeFromParentViewController];
            
            [self.nextDisplayViewController endAppearanceTransition];
            [self.selectedViewController endAppearanceTransition];
        }
    }
    self.nextDisplayViewController = nil;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self _scrollViewDidStatic];
    if (self.scrollAnimationCompletion) {
        self.scrollAnimationCompletion();
        self.scrollAnimationCompletion = nil;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    BOOL toRight = x - _scrollViewLastContentOffsetX > 0;
    self.scrollViewLastContentOffsetX = x;
    NSInteger scrollViewControllerIndex = 0;
    if (toRight) {
        scrollViewControllerIndex = (x + scrollView.frame.size.width + (_scrollViewDragging ? 0.50f : -.50f)) / scrollView.frame.size.width;
    } else {
        scrollViewControllerIndex = (x - (_scrollViewDragging ? 0.50f : 0)) / scrollView.frame.size.width;
    }
    BOOL outAdded = NO;
    UIViewController *nextViewController = [self _addChildViewControllerIfNeededWithIndex:scrollViewControllerIndex outAdded:&outAdded];
    if (nextViewController != nil && nextViewController != [self selectedViewController] && nextViewController != _nextDisplayViewController) {
        self.nextDisplayViewController = nextViewController;
        
        if (!outAdded) {
            [self.nextDisplayViewController beginAppearanceTransition:YES animated:self.scrollViewAnimating];
        }
        
        [self.selectedViewController beginAppearanceTransition:NO animated:self.scrollViewAnimating];
        
        if ([_delegate respondsToSelector:@selector(switchTabController:willSwitchToIndex:)]) {
            [_delegate switchTabController:self willSwitchToIndex:scrollViewControllerIndex];
        }
    }
}

@end
