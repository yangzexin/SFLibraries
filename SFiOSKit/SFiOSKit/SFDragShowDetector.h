//
//  SFDragShowDetector.h
//  SFiOSKit
//
//  Created by yangzexin on 11/21/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDragShowDetector : NSObject

@property (nonatomic, assign) BOOL triggerOnTop;
@property (nonatomic, assign) BOOL triggerOnBottom;

@property (nonatomic, assign, readonly) BOOL showing;

@property (nonatomic, copy) void(^whenTrigger)(BOOL show);

+ (instancetype)detectorWithTriggerHandler:(void(^)(BOOL show))triggerHandler;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end
