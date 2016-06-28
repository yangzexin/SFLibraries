//
//  SFLineView.h
//  SFiOSKit
//
//  Created by yangzexin on 11/18/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SFLineViewAlignment) {
    SFLineViewAlignmentTop = 0,
    SFLineViewAlignmentCenter = 1,
    SFLineViewAlignmentBottom = 2,
};

@interface SFLineView : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) BOOL vertical;
@property (nonatomic, assign) SFLineViewAlignment alignment;
@property (nonatomic, assign, getter=isNormalBorder) BOOL normalBorder;

@end
