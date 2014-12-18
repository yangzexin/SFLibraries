//
//  SFCardLayout.m
//  SFiOSKit
//
//  Created by yangzexin on 11/18/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFCardLayout.h"
#import "NSString+SFiOSAddition.h"
#import "NSObject+SFObjectAssociation.h"

@implementation UILabel (SFCardLayoutWidthCalculatable_ext)

- (CGFloat)widthForCardLayout
{
    return [self.text sf_sizeWithFont:self.font].width;
}

@end

@implementation UIView (SFCardLayout_MaxSize)

- (void)setCLMaxWidth:(CGFloat)maxWidth
{
    [self sf_setAssociatedObject:[NSNumber numberWithFloat:maxWidth] key:@"_cardLayout_maxWidth"];
}

- (CGFloat)CLMaxWidth
{
    return [[self sf_associatedObjectWithKey:@"_cardLayout_maxWidth"] floatValue];
}

- (void)setCLMaxWidthPercent:(float)percent
{
    [self sf_setAssociatedObject:[NSNumber numberWithFloat:percent] key:@"_cardLayout_maxWidthPercent"];
}

- (CGFloat)CLMaxWidthPercent
{
    return [[self sf_associatedObjectWithKey:@"_cardLayout_maxWidthPercent"] floatValue];
}

- (void)setCLMaxHeight:(CGFloat)maxHeight
{
    [self sf_setAssociatedObject:[NSNumber numberWithFloat:maxHeight] key:@"_cardLayout_maxHeight"];
}

- (CGFloat)CLMaxHeight
{
    return [[self sf_associatedObjectWithKey:@"_cardLayout_maxHeight"] floatValue];
}

- (void)setCLMaxHeightPercent:(float)percent
{
    [self sf_setAssociatedObject:[NSNumber numberWithFloat:percent] key:@"_cardLayout_maxHeightPercent"];
}

- (CGFloat)CLMaxHeightPercent
{
    return [[self sf_associatedObjectWithKey:@"_cardLayout_maxHeightPercent"] floatValue];
}

@end

@implementation SFCardLayout

- (void)addSubview:(UIView *)view
{
    [super addSubview:view];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.vertical == NO) {
        CGFloat startX = 0.0f;
        if (self.alignment == SFCardLayoutAlignmentCenter) {
            __block CGFloat totalSubviewsWidth = 0.0f;
            __block NSInteger numberOfHiddenSubviews = 0;
            [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
                if (subview.hidden) {
                    ++numberOfHiddenSubviews;
                } else {
                    CGFloat subviewWidth = 0;
                    if ([subview respondsToSelector:@selector(widthForCardLayout)]) {
                        subviewWidth = [(id)subview widthForCardLayout];
                    } else {
                        subviewWidth = subview.frame.size.width;
                    }
                    CGFloat maxWidth = [subview CLMaxWidth];
                    if (maxWidth != 0 && subviewWidth > maxWidth) {
                        subviewWidth = maxWidth;
                    }
                    float maxWidthPercent = [subview CLMaxWidthPercent];
                    if (maxWidthPercent != 0 && maxWidthPercent <= 1.0f) {
                        CGFloat tmpMaxWidth = maxWidthPercent * self.frame.size.width;
                        if (subviewWidth > tmpMaxWidth) {
                            subviewWidth = tmpMaxWidth;
                        }
                    }
                    
                    totalSubviewsWidth += subviewWidth;
                }
            }];
            totalSubviewsWidth += (self.subviews.count - numberOfHiddenSubviews - 1) * self.spacing;
            startX = (NSInteger)((self.frame.size.width - totalSubviewsWidth) / 2);
        }
        
        __block CGFloat tmpX = self.alignment == SFCardLayoutAlignmentRight ? self.frame.size.width : startX;
        [self.subviews enumerateObjectsWithOptions:self.alignment == SFCardLayoutAlignmentRight ? NSEnumerationReverse : 0 usingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
            if (subview.hidden == NO) {
                CGFloat subviewWidth = 0;
                if ([subview respondsToSelector:@selector(widthForCardLayout)]) {
                    subviewWidth = [(id)subview widthForCardLayout];
                } else {
                    subviewWidth = subview.frame.size.width;
                }
                CGFloat maxWidth = [subview CLMaxWidth];
                if (maxWidth != 0 && subviewWidth > maxWidth) {
                    subviewWidth = maxWidth;
                }
                float maxWidthPercent = [subview CLMaxWidthPercent];
                if (maxWidthPercent != 0 && maxWidthPercent <= 1.0f) {
                    CGFloat tmpMaxWidth = maxWidthPercent * self.frame.size.width;
                    if (subviewWidth > tmpMaxWidth) {
                        subviewWidth = tmpMaxWidth;
                    }
                }
                
                CGRect tmpRect = subview.frame;
                tmpRect.origin.x = ceilf(self.alignment == SFCardLayoutAlignmentRight ? (tmpX - subviewWidth) : tmpX);
                tmpRect.size.width = ceilf(subviewWidth);
                subview.frame = tmpRect;
                
                tmpX += self.alignment == SFCardLayoutAlignmentRight ? -(subviewWidth + self.spacing) : (subviewWidth + self.spacing);
            }
        }];
    } else {
        CGFloat startY = 0.0f;
        if (self.alignment == SFCardLayoutAlignmentCenter) {
            __block CGFloat totalSubviewsHeight = 0.0f;
            __block NSInteger numberOfHiddenSubviews = 0;
            [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
                if (subview.hidden) {
                    ++numberOfHiddenSubviews;
                } else {
                    CGFloat subviewHeight = 0.0f;
                    if ([subview respondsToSelector:@selector(heightForCardLayout)]) {
                        subviewHeight = [(id)subview heightForCardLayout];
                    } else {
                        subviewHeight = subview.frame.size.height;
                    }
                    CGFloat maxHeight = [subview CLMaxHeight];
                    if (maxHeight != 0 && subviewHeight > maxHeight) {
                        subviewHeight = maxHeight;
                    }
                    float maxHeightPercent = [subview CLMaxHeightPercent];
                    if (maxHeightPercent != 0 && maxHeightPercent <= 1.0f) {
                        CGFloat tmpMaxHeight = maxHeightPercent * self.frame.size.height;
                        if (subviewHeight > tmpMaxHeight) {
                            subviewHeight = tmpMaxHeight;
                        }
                    }
                    
                    totalSubviewsHeight += subviewHeight;
                }
            }];
            totalSubviewsHeight += (self.subviews.count - numberOfHiddenSubviews - 1) * self.spacing;
            startY = (NSInteger)((self.frame.size.height - totalSubviewsHeight) / 2);
        }
        
        __block CGFloat tmpY = self.alignment == SFCardLayoutAlignmentBottom ? self.frame.size.height : startY;
        [self.subviews enumerateObjectsWithOptions:self.alignment == SFCardLayoutAlignmentBottom ? NSEnumerationReverse : 0 usingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
            if (subview.hidden == NO) {
                CGFloat subviewHeight = 0.0f;
                if ([subview respondsToSelector:@selector(heightForCardLayout)]) {
                    subviewHeight = [(id)subview heightForCardLayout];
                } else {
                    subviewHeight = subview.frame.size.height;
                }
                CGFloat maxHeight = [subview CLMaxHeight];
                if (maxHeight != 0 && subviewHeight > maxHeight) {
                    subviewHeight = maxHeight;
                }
                float maxHeightPercent = [subview CLMaxHeightPercent];
                if (maxHeightPercent != 0 && maxHeightPercent <= 1.0f) {
                    CGFloat tmpMaxHeight = maxHeightPercent * self.frame.size.height;
                    if (subviewHeight > tmpMaxHeight) {
                        subviewHeight = tmpMaxHeight;
                    }
                }
                
                CGRect tmpRect = subview.frame;
                tmpRect.origin.y = ceilf(self.alignment == SFCardLayoutAlignmentBottom ? (tmpY - subviewHeight) : tmpY);
                tmpRect.size.height = ceilf(subviewHeight);
                subview.frame = tmpRect;
                
                tmpY += self.alignment == SFCardLayoutAlignmentBottom ? -(subviewHeight + self.spacing) : (subviewHeight + self.spacing);
            }
        }];
    }
}

- (void)setSpacing:(CGFloat)spacing
{
    _spacing = spacing;
    [self setNeedsLayout];
}

@end
