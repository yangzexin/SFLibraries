//
//  SFCardLayout.m
//  SFiOSKit
//
//  Created by yangzexin on 11/18/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFCardLayout.h"

#import <SFFoundation/SFFoundation.h>

#import "NSString+SFiOSAddition.h"

@interface UILabel (SFCLICalculatableExt) <SFCLICalculatable>

@end

@implementation UILabel (SFCLICalculatableExt)

- (CGFloat)widthForCLI {
    return [self.text sf_sizeWithFont:self.font].width;
}

- (CGFloat)heightForCLI {
    return [self.text sf_sizeWithFont:self.font].height;
}

@end

@implementation UIView (SFCardLayoutItem_MaxSize)

- (void)setCLIMaxWidth:(CGFloat)maxWidth{
    [self sf_setAssociatedObject:[NSNumber numberWithFloat:maxWidth] key:@"CLI_maxWidth"];
}

- (CGFloat)CLIMaxWidth {
    return [[self sf_associatedObjectWithKey:@"CLI_maxWidth"] floatValue];
}

- (void)setCLIMaxWidthPercent:(float)percent {
    [self sf_setAssociatedObject:[NSNumber numberWithFloat:percent] key:@"CLI_maxWidthPercent"];
}

- (CGFloat)CLIMaxWidthPercent {
    return [[self sf_associatedObjectWithKey:@"CLI_maxWidthPercent"] floatValue];
}

- (void)setCLIMaxHeight:(CGFloat)maxHeight {
    [self sf_setAssociatedObject:[NSNumber numberWithFloat:maxHeight] key:@"CLI_maxHeight"];
}

- (CGFloat)CLIMaxHeight {
    return [[self sf_associatedObjectWithKey:@"CLI_maxHeight"] floatValue];
}

- (void)setCLIMaxHeightPercent:(float)percent {
    [self sf_setAssociatedObject:[NSNumber numberWithFloat:percent] key:@"CLI_maxHeightPercent"];
}

- (CGFloat)CLIMaxHeightPercent {
    return [[self sf_associatedObjectWithKey:@"CLI_maxHeightPercent"] floatValue];
}

@end

@implementation SFCardLayout

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
}

- (void)layoutSubviews {
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
                    if ([subview respondsToSelector:@selector(widthForCLI)]) {
                        subviewWidth = [(id)subview widthForCLI];
                    } else {
                        subviewWidth = subview.frame.size.width;
                    }
                    CGFloat maxWidth = [subview CLIMaxWidth];
                    if (maxWidth != 0 && subviewWidth > maxWidth) {
                        subviewWidth = maxWidth;
                    }
                    float maxWidthPercent = [subview CLIMaxWidthPercent];
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
                if ([subview respondsToSelector:@selector(widthForCLI)]) {
                    subviewWidth = [(id)subview widthForCLI];
                } else {
                    subviewWidth = subview.frame.size.width;
                }
                CGFloat maxWidth = [subview CLIMaxWidth];
                if (maxWidth != 0 && subviewWidth > maxWidth) {
                    subviewWidth = maxWidth;
                }
                float maxWidthPercent = [subview CLIMaxWidthPercent];
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
                    if ([subview respondsToSelector:@selector(heightForCLI)]) {
                        subviewHeight = [(id)subview heightForCLI];
                    } else {
                        subviewHeight = subview.frame.size.height;
                    }
                    CGFloat maxHeight = [subview CLIMaxHeight];
                    if (maxHeight != 0 && subviewHeight > maxHeight) {
                        subviewHeight = maxHeight;
                    }
                    float maxHeightPercent = [subview CLIMaxHeightPercent];
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
                if ([subview respondsToSelector:@selector(heightForCLI)]) {
                    subviewHeight = [(id)subview heightForCLI];
                } else {
                    subviewHeight = subview.frame.size.height;
                }
                CGFloat maxHeight = [subview CLIMaxHeight];
                if (maxHeight != 0 && subviewHeight > maxHeight) {
                    subviewHeight = maxHeight;
                }
                float maxHeightPercent = [subview CLIMaxHeightPercent];
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

- (void)setSpacing:(CGFloat)spacing {
    _spacing = spacing;
    [self setNeedsLayout];
}

@end
