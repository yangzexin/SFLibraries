//
//  SFCircleProgressView.m
//  SFiOSKit
//
//  Created by yangzexin on 12/15/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFCircleProgressView.h"

@interface SFCircleProgressView ()

@property (nonatomic, strong) CAShapeLayer *foregroundLayer;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;

@property (nonatomic, assign) BOOL animating;

@end

@implementation SFCircleProgressView

- (void)initialize {
    [super initialize];
    self.backgroundColor = [UIColor clearColor];
    
    self.strokeLineWidth = 2.0f;
    self.animationDuration = 0.50f;
}

- (CAShapeLayer *)_circleLayerWithAninmated:(BOOL)animated fromAngle:(CGFloat)fromAngle endAngle:(CGFloat)endAngle strokeColor:(UIColor *)strokeColor strokeLineWidth:(CGFloat)strokeLineWidth {
    int radius = (self.frame.size.width - strokeLineWidth) / 2;
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
                                                 radius:radius
                                             startAngle:fromAngle
                                               endAngle:endAngle
                                              clockwise:NO].CGPath;
    circle.position = CGPointMake(0, 0);
    UIColor *fillColor = self.circleFillColor == nil ? [UIColor clearColor] : self.circleFillColor;
    circle.fillColor = fillColor.CGColor;
    circle.strokeColor = strokeColor.CGColor;
    circle.lineWidth = strokeLineWidth;
    
    if (animated) {
        CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        drawAnimation.duration = _animationDuration;
        drawAnimation.repeatCount = 1.0;
        drawAnimation.removedOnCompletion = NO;
        drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
        drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    }
    
    return circle;
}

- (CAShapeLayer *)_createForgroundLayerWithAnimated:(BOOL)animated {
    return [self _circleLayerWithAninmated:animated
                                 fromAngle:1.5 * M_PI
                                  endAngle:[self _endAngleForPercent:_percent]
                               strokeColor:_circleForegroundColor
                           strokeLineWidth:_strokeLineWidth];
}

- (CAShapeLayer *)_createBackgroundLayer {
    return [self _circleLayerWithAninmated:NO
                                 fromAngle:1.5 * M_PI
                                  endAngle:[self _endAngleForPercent:1.0]
                               strokeColor:_circleBackgroundColor
                           strokeLineWidth:_strokeLineWidth];
}

- (CGFloat)_endAngleForPercent:(CGFloat)percent {
    CGFloat endAngle = percent == 1.0f ? (-M_PI * 0.5) : (1.50f * M_PI - ((int)(percent * 100) % 100 / 25.0f) * (0.50 * M_PI));
    
    return endAngle;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_backgroundLayer removeFromSuperlayer];
    self.backgroundLayer = [self _createBackgroundLayer];
    [self.layer addSublayer:_backgroundLayer];
    
    [_foregroundLayer removeFromSuperlayer];
    self.foregroundLayer = [self _createForgroundLayerWithAnimated:_animating];
    [self.layer addSublayer:_foregroundLayer];
    self.animating = NO;
}

- (void)setPercent:(float)percent {
    [self setPercent:percent animated:NO];
}

- (void)setPercent:(float)percent animated:(BOOL)animated {
    if (percent < 0) {
        percent = 0;
    }
    if (percent > 1.0f) {
        percent = 1.0f;
    }
    _percent = percent;
    self.animating = animated;
    [self setNeedsLayout];
}

- (void)setCircleBackgroundColor:(UIColor *)circleBackgroundColor {
    _circleBackgroundColor = circleBackgroundColor;
    [self setNeedsLayout];
}

- (void)setCircleForegroundColor:(UIColor *)circleForegroundColor {
    _circleForegroundColor = circleForegroundColor;
    [self setNeedsLayout];
}

- (void)setCircleFillColor:(UIColor *)circleFillColor {
    _circleFillColor = circleFillColor;
    [self setNeedsLayout];
}

- (void)setStrokeLineWidth:(CGFloat)strokeLineWidth {
    _strokeLineWidth = strokeLineWidth;
    [self setNeedsLayout];
}

@end
