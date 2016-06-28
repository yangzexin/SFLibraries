//
//  SFPageIndicator.h
//  SFiOSKit
//
//  Created by yangzexin on 1/9/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFIBCompatibleView.h"

@interface SFPageIndicator : SFIBCompatibleView

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic, strong) UIImage *currentIndicatorImage;
@property (nonatomic, strong) UIImage *indicatorImage;

@property (nonatomic, assign) CGFloat spacing;

@end
