//
//  SFVerticalLayout.h
//  SFiOSKit
//
//  Created by yangzexin on 8/20/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFIBCompatibleView.h"

@interface SFVerticalLayout : SFIBCompatibleView

@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) BOOL separatorHidden;

- (void)addView:(UIView *)view animated:(BOOL)animated;
- (void)insertView:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeView:(UIView *)view animated:(BOOL)animated;

- (void)reloadView:(UIView *)view animated:(BOOL)animated;

- (BOOL)isViewExists:(UIView *)view;

@end
