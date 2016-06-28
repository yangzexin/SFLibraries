//
//  SFDotLineView.m
//  SFiOSKit
//
//  Created by yangzexin on 11/20/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFDotLineView.h"

@implementation SFDotLineView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self _setDefaults];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    [self _setDefaults];
}

- (void)_setDefaults {
    if (self.lineHeight == 0.0f) {
        self.lineHeight = 1.0f;
    }
    if (self.lineColor == nil) {
        self.lineColor = [UIColor lightGrayColor];
    }
    if (self.spacing == 0.0f) {
        self.spacing = 2.0f;
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGFloat dashes[] = {self.spacing, self.spacing};
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineDash(context, 0.0, dashes, 2);
    CGContextSetLineWidth(context, self.lineHeight);
    
    if(self.vertical){
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    }else{
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    }
    
    CGContextStrokePath(context);
}

@end
