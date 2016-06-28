//
//  SFCollapsableLabel.m
//  SFiOSKit
//
//  Created by yangzexin on 2/27/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFCollapsableLabel.h"
#import "NSString+SFiOSAddition.h"
#import "UIView+SFAddition.h"

@interface SFCollapsableLabel ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation SFCollapsableLabel

- (void)initialize {
    [super initialize];
    self.label = ({
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15.0f];
        [self addSubview:label];
        label;
    });
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizer:)]];
}

- (void)_tapGestureRecognizer:(UIGestureRecognizer *)gr {
    self.collapsed = !_collapsed;
    [self _notifyStateChange];
}

- (void)_notifyStateChange {
    if (_collapseStateDidChange) {
        _collapseStateDidChange();
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL stateChange = NO;
    
    NSInteger numberOfLines = 0;
    CGFloat labelHeight = 0;
    CGSize labelTextSize = [_label.text sf_sizeWithFont:_label.font constrainedToSize:CGSizeMake(self.frame.size.width, MAXFLOAT)];
    NSInteger actualNumberOfLines = labelTextSize.height / _label.font.lineHeight;
    if (_collapsed) {
        if (actualNumberOfLines <= _numberOfVisibleLines) {
            _collapsed = NO;
            stateChange = YES;
            numberOfLines = actualNumberOfLines;
            labelHeight = labelTextSize.height;
        } else {
            numberOfLines = _numberOfVisibleLines;
            labelHeight = numberOfLines * _label.font.lineHeight;
        }
    } else {
        numberOfLines = actualNumberOfLines;
        labelHeight = labelTextSize.height;
    }
    _label.numberOfLines = numberOfLines;
    CGRect tmpRect = _label.frame;
    tmpRect.origin = CGPointMake(0, 0);
    tmpRect.size.width = self.frame.size.width;
    tmpRect.size.height = labelHeight;
    _label.frame = tmpRect;
    
    _expandIndicatorView.hidden = !_collapsed;
    if (!_expandIndicatorView.hidden) {
        tmpRect = _expandIndicatorView.frame;
        tmpRect.origin.y = [_label sf_bottom];
        _expandIndicatorView.frame = tmpRect;
    }
    
    if (stateChange) {
        [self _notifyStateChange];
    }
}

- (void)setText:(NSString *)text {
    _label.text = text;
    [self setNeedsLayout];
}

- (NSString *)text {
    return _label.text;
}

- (void)setNumberOfVisibleLines:(NSInteger)numberOfVisibleLines {
    _numberOfVisibleLines = numberOfVisibleLines;
    [self setNeedsLayout];
}

- (void)setCollapsed:(BOOL)collapsed {
    _collapsed = collapsed;
    [self setNeedsLayout];
}

- (void)setExpandIndicatorView:(UIView *)expandIndicatorView {
    if (_expandIndicatorView) {
        [_expandIndicatorView removeFromSuperview];
    }
    _expandIndicatorView = expandIndicatorView;
    [self addSubview:_expandIndicatorView];
    [self setNeedsLayout];
}

- (void)fitToSuitableHeight {
    [self layoutSubviews];
    CGRect tmpRect = self.frame;
    tmpRect.size.height = (NSInteger)_label.frame.size.height + (_collapsed ? _expandIndicatorView.frame.size.height : 0);
    self.frame = tmpRect;
}

@end
