//
//  SFPageIndicator.m
//  SFiOSKit
//
//  Created by yangzexin on 1/9/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFPageIndicator.h"

@interface SFPageIndicator ()

@property (nonatomic, strong) NSArray *imageViews;

@end

@implementation SFPageIndicator

- (void)initialize {
    [super initialize];
    self.spacing = 5.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat indicatorsWidth = [self _widthForAllIndicators];
    CGFloat x = (self.frame.size.width - indicatorsWidth) / 2;
    for (NSInteger pageIndex = 0; pageIndex < self.numberOfPages; ++pageIndex) {
        BOOL currentPage = pageIndex == self.currentPageIndex;
        UIImageView *imageView = [self.imageViews objectAtIndex:pageIndex];
        CGRect tmpRect = imageView.frame;
        tmpRect.origin.x = x;
        imageView.frame = tmpRect;
        x += tmpRect.size.width + _spacing;
        imageView.image = currentPage ? _currentIndicatorImage : _indicatorImage;
    }
}

- (CGFloat)_widthForAllIndicators {
    CGFloat width = 0;
    width += (_numberOfPages - 1) * _indicatorImage.size.width;
    width += _currentIndicatorImage.size.width;
    width += (_numberOfPages - 1) * _spacing;
    
    return width;
}

- (UIImageView *)imageViewForIndicatorWithIndex:(NSInteger)index {
    UIImage *image = index == _currentPageIndex ? _currentIndicatorImage : _indicatorImage;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    return imageView;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    for (UIView *view in self.imageViews) {
        [view removeFromSuperview];
    }
    NSMutableArray *newImageViews = [NSMutableArray array];
    for (NSInteger pageIndex = 0; pageIndex < numberOfPages; ++pageIndex) {
        UIView *view = [self imageViewForIndicatorWithIndex:pageIndex];
        [newImageViews addObject:view];
        [self addSubview:view];
    }
    self.imageViews = newImageViews;
    [self setNeedsLayout];
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    _currentPageIndex = currentPageIndex;
    [self setNeedsLayout];
}

@end
