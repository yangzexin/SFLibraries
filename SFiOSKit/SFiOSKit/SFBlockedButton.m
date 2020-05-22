//
//  SFBlockedButton.m
//  SFiOSKit
//
//  Created by yangzexin on 13-5-17.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "SFBlockedButton.h"

#import "UIImage+SFAddition.h"

@interface SFBlockedButton ()

@end

@implementation SFBlockedButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self initialize];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame round:(BOOL)round roundSize:(CGFloat)roundSize backgroundColor:(UIColor *)backgroundColor {
    self = [super initWithFrame:frame];
    
    _round = round;
    _roundSize = roundSize;
    self.backgroundColor = backgroundColor;
    
    [self initialize];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initialize];
}

- (void)initialize {
    [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *backgroundImage = nil;
    UIColor *backgroundImageColor = self.backgroundColor == nil ? [UIColor clearColor] : self.backgroundColor;
    
    if (_round) {
        if (_roundSize == 0) {
            self.roundSize = 3;
        }
        UIColor *borderColor = backgroundImageColor;
        if (self.border && self.borderColor) {
            borderColor = self.borderColor;
        }
        backgroundImage = [UIImage sf_roundImageWithOptions:({
            SFRoundImageOptions *options = [SFRoundImageOptions options];
            options.backgroundColor = backgroundImageColor;
            options.borderColor = borderColor;
            options.size = CGSizeMake(20, 20);
            options.cornerRadius = _roundSize;
            options;
        })];
        backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    } else {
        backgroundImage = [UIImage sf_imageWithColor:backgroundImageColor size:CGSizeMake(1, 1)];
    }
    self.backgroundColor = [UIColor clearColor];
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    if (self.highlightBackgroundColor) {
        UIImage *highlightBackgroundImage = nil;
        if (_round) {
            highlightBackgroundImage = [UIImage sf_roundImageWithOptions:({
                SFRoundImageOptions *options = [SFRoundImageOptions options];
                options.backgroundColor = self.highlightBackgroundColor;
                options.borderColor = self.highlightBackgroundColor;
                options.size = CGSizeMake(20, 20);
                options.cornerRadius = _roundSize;
                options;
            })];
            highlightBackgroundImage = [highlightBackgroundImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        } else {
            highlightBackgroundImage = [UIImage sf_imageWithColor:self.highlightBackgroundColor size:CGSizeMake(1, 1)];
        }
        [self setBackgroundImage:highlightBackgroundImage forState:UIControlStateHighlighted];
    }
}

- (void)tapped {
    if (_tap) {
        _tap();
    }
}

+ (instancetype)blockedButtonWithTap:(void(^)(void))tap {
    return [self blockedButtonWithTap:tap frame:CGRectNull addToSuperview:nil];
}

+ (instancetype)blockedButtonWithTap:(void(^)(void))tap frame:(CGRect)frame {
    return [self blockedButtonWithTap:tap frame:frame addToSuperview:nil];
}

+ (instancetype)blockedButtonWithTap:(void(^)(void))tap frame:(CGRect)frame addToSuperview:(UIView *)superview {
    SFBlockedButton *button = [[SFBlockedButton alloc] initWithFrame:frame round:YES roundSize:10 backgroundColor:[UIColor darkGrayColor]];
    button.tap = tap;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    
    if (!CGRectIsNull(frame)) {
        button.frame = frame;
    }
    
    if (superview) {
        [superview addSubview:button];
    }
    
    return button;
}

@end
