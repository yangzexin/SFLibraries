//
//  SFCircleProgressView.h
//  SFiOSKit
//
//  Created by yangzexin on 12/15/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFIBCompatibleView.h"

@interface SFCircleProgressView : SFIBCompatibleView

@property (nonatomic, assign) float percent;

@property (nonatomic, strong) UIColor *circleBackgroundColor;
@property (nonatomic, strong) UIColor *circleForegroundColor;
@property (nonatomic, strong) UIColor *circleFillColor;
@property (nonatomic, assign) CGFloat strokeLineWidth;
@property (nonatomic, assign) NSTimeInterval animationDuration;

- (void)setPercent:(float)percent animated:(BOOL)animated;

@end
