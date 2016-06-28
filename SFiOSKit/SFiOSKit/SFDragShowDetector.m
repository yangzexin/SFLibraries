//
//  SFDragShowDetector.m
//  SFiOSKit
//
//  Created by yangzexin on 11/21/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SFDragShowDetector.h"

#import "SFiOSKitConstants.h"

@interface SFDragShowDetector ()

@property (nonatomic, assign) CGFloat beginDragY;
@property (nonatomic, assign) CGFloat lastDargY;

@property (nonatomic, assign) BOOL showing;

@end

@implementation SFDragShowDetector

+ (instancetype)detectorWithTriggerHandler:(void(^)(BOOL show))triggerHandler {
    SFDragShowDetector *detector = [SFDragShowDetector new];
    detector.whenTrigger = triggerHandler;
    return detector;
}

- (id)init {
    self = [super init];
    
    self.showing = YES;
    
    return self;
}

- (void)_notifyTriggerWithShow:(BOOL)show {
    self.showing = show;
    if (self.whenTrigger) {
        self.whenTrigger(show);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginDragY = scrollView.contentOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (velocity.y < -0.72f) {
        [self _notifyTriggerWithShow:YES];
    } else if (velocity.y > 0.0f) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height < scrollView.contentSize.height) {
            [self _notifyTriggerWithShow:NO];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat topEdge = SFDeviceSystemVersion < 7.0f ? 0.0f : -SFStatusBarHeight;
    if (self.triggerOnTop && scrollView.contentOffset.y <= topEdge) {
        [self _notifyTriggerWithShow:YES];
    } else if (self.triggerOnBottom && scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {
        [self _notifyTriggerWithShow:YES];
    } else if (scrollView.dragging && scrollView.contentOffset.y > self.lastDargY + 10 && scrollView.contentOffset.y > 0) {
        [self _notifyTriggerWithShow:NO];
    } else if (scrollView.dragging && scrollView.contentOffset.y < self.lastDargY && scrollView.contentOffset.y + scrollView.frame.size.height < scrollView.contentSize.height) {
        [self _notifyTriggerWithShow:YES];
    }
    if (scrollView.dragging) {
        self.lastDargY = scrollView.contentOffset.y;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

@end
