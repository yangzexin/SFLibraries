//
//  SFCollapsableLabel.h
//  SFiOSKit
//
//  Created by yangzexin on 2/27/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFIBCompatibleView.h"

@interface SFCollapsableLabel : SFIBCompatibleView

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, assign) NSInteger numberOfVisibleLines;
@property (nonatomic, assign) BOOL collapsed;
@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UIView *expandIndicatorView;

@property (nonatomic, copy) void(^collapseStateDidChange)();

- (void)fitToSuitableHeight;

@end
