//
//  SFCardLayout.h
//  SFiOSKit
//
//  Created by yangzexin on 11/18/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFCardLayoutWidthCalculatable <NSObject>

- (CGFloat)widthForCardLayout;
- (CGFloat)heightForCardLayout; // when vertical is ture

@end

@interface UIView (SFCardLayout_MaxSize)

- (void)setCLMaxWidth:(CGFloat)maxWidth;
- (CGFloat)CLMaxWidth;

- (void)setCLMaxWidthPercent:(float)percent;
- (CGFloat)CLMaxWidthPercent;

- (void)setCLMaxHeight:(CGFloat)maxHeight;
- (CGFloat)CLMaxHeight;

- (void)setCLMaxHeightPercent:(float)percent;
- (CGFloat)CLMaxHeightPercent;

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
@property (nonatomic, assign) BOOL vertical;

@end