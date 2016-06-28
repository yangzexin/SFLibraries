//
//  SFTrangleView.m
//  SFiOSKit
//
//  Created by yzx on 12-6-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFTrangleView.h"

#import "SFiOSKitConstants.h"

@implementation SFTrangleView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self initialize];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)initialize {
    self.color = [UIColor blackColor];
    self.borderColor = [UIColor blackColor];
    self.lightBorder = YES;
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGFloat borderWidth = _lightBorder ? (SFIsRetinaScreen ? _borderWidth / 2 : _borderWidth) : _borderWidth;
    
    width -= 2 * borderWidth;
    height -= 2 * borderWidth;
    
    CGPoint point1, point2, point3;
    switch (_direction) {
        case SFTrangleViewDirectionDown:
            point1 = CGPointMake(0, 0);
            point2 = CGPointMake(width, 0);
            point3 = CGPointMake(width / 2, height);
            break;
        case SFTrangleViewDirectionUp:
            point1 = CGPointMake(width / 2, 0);
            point2 = CGPointMake(0, height);
            point3 = CGPointMake(width, height);
            break;
        case SFTrangleViewDirectionLeft:
            point1 = CGPointMake(0, height / 2);
            point2 = CGPointMake(width, height);
            point3 = CGPointMake(width, 0);
            break;
        case SFTrangleViewDirectionRight:
            point1 = CGPointMake(0, 0);
            point2 = CGPointMake(width, height / 2);
            point3 = CGPointMake(0, height);
            break;
            
        default:
            break;
    }
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, borderWidth + point1.x, borderWidth + point1.y);
    CGContextAddLineToPoint(context, borderWidth + point2.x, borderWidth + point2.y);
    CGContextAddLineToPoint(context, borderWidth + point3.x, borderWidth + point3.y);
    
    CGContextClosePath(context);
    
    CGContextSetLineWidth(context, borderWidth);
    CGContextSetFillColorWithColor(context, _color.CGColor);
    CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);

    CGContextDrawPath(context, borderWidth == 0 ? kCGPathFill : kCGPathFillStroke);
}

- (void)setDirection:(SFTrangleViewDirection)direction {
    _direction = direction;
    [self setNeedsDisplay];
}

@end
