//
//  SFCardLayout.h
//  SFiOSKit
//
//  Created by yangzexin on 11/18/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 CardLayoutItem calculatable
 */
@protocol SFCLICalculatable <NSObject>

- (CGFloat)widthForCLI;
- (CGFloat)heightForCLI; // when vertical is ture

@end

@interface UIView (SFCardLayoutItem_MaxSize)

- (void)setCLIMaxWidth:(CGFloat)maxWidth;
- (CGFloat)CLIMaxWidth;

- (void)setCLIMaxWidthPercent:(float)percent;
- (CGFloat)CLIMaxWidthPercent;

- (void)setCLIMaxHeight:(CGFloat)maxHeight;
- (CGFloat)CLIMaxHeight;

- (void)setCLIMaxHeightPercent:(float)percent;
- (CGFloat)CLIMaxHeightPercent;

@end

typedef NS_ENUM(NSUInteger, SFCardLayoutAlignment) {
    SFCardLayoutAlignmentLeft = 0,
    SFCardLayoutAlignmentCenter = 1,
    SFCardLayoutAlignmentRight = 2,
    SFCardLayoutAlignmentTop = 3,
    SFCardLayoutAlignmentBottom = 4,
};

@interface SFCardLayout : UIView

@property (nonatomic, assign) CGFloat spacing;

@property (nonatomic, assign) SFCardLayoutAlignment alignment;

/**
 default is NO
 */
@property (nonatomic, assign) BOOL vertical;

@end