//
//  SVBlockedGestureView.m
//  SimpleFramework
//
//  Created by yangzexin on 13-5-17.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "SFBlockedButton.h"

@interface SFBlockedButton ()

@end

@implementation SFBlockedButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self initialize];
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

- (void)initialize
{
    [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tapped
{
    if (_tapHandler) {
        _tapHandler();
    }
}

+ (instancetype)blockedButtonWithTapHandler:(void(^)())tapHandler
{
    return [self blockedButtonWithTapHandler:tapHandler frame:CGRectNull addToSuperview:nil];
}

+ (instancetype)blockedButtonWithTapHandler:(void(^)())tapHandler frame:(CGRect)frame
{
    return [self blockedButtonWithTapHandler:tapHandler frame:frame];
}

+ (instancetype)blockedButtonWithTapHandler:(void(^)())tapHandler frame:(CGRect)frame addToSuperview:(UIView *)superview
{
    SFBlockedButton *button = [SFBlockedButton new];
    button.tapHandler = tapHandler;
    
    if (!CGRectIsNull(frame)) {
        button.frame = frame;
    }
    
    if (superview) {
        [superview addSubview:button];
    }
    
    return button;
}

@end
