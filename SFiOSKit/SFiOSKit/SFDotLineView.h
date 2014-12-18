//
//  SFDotLineView.h
//  SFiOSKit
//
//  Created by yangzexin on 11/20/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDotLineView : UIView

@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) BOOL vertical;

@end
