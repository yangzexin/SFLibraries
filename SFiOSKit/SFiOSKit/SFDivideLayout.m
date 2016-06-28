//
//  SFDivideLayoutView.m
//  SFiOSKit
//
//  Created by yangzexin on 12/30/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFDivideLayout.h"
#import "SFiOSKitConstants.h"

@implementation SFDivideLayout

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger numberOfSubviews = 0;
    NSMutableArray *visibleViews = [NSMutableArray array];
    for (UIView *subview in [self subviews]) {
        if (subview.hidden == NO) {
            ++numberOfSubviews;
            [visibleViews addObject:subview];
        }
    }
    CGFloat subviewSize = ((_vertical ? self.frame.size.height : self.frame.size.width) - (numberOfSubviews - 1) * _spacing) / numberOfSubviews;
    for (NSInteger i = 0; i < numberOfSubviews; ++i) {
        UIView *subview = [visibleViews objectAtIndex:i];
        CGRect tmpRect = subview.frame;
        if (_vertical) {
            tmpRect.origin.y = ceilf(i * (subviewSize + _spacing));
            tmpRect.size.height = ceilf(subviewSize);
        } else {
            tmpRect.origin.x = ceilf(i * (subviewSize + _spacing));
            tmpRect.size.width = ceilf(subviewSize);
        }
        subview.frame = tmpRect;
    }
}

- (void)setVertical:(BOOL)vertical {
    _vertical = vertical;
    [self setNeedsLayout];
}

- (void)setLightBorderSpacing:(BOOL)lightBorderSpacing {
    _lightBorderSpacing = lightBorderSpacing;
    _spacing = SFLightLineWidth;
}

@end
