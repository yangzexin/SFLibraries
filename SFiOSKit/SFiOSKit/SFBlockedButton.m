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

+ (id)blockedButtonWithTapHandler:(void(^)())tapHandler
{
    SFBlockedButton *button = [SFBlockedButton new];
    button.tapHandler = tapHandler;
    
    return button;
}

@end
