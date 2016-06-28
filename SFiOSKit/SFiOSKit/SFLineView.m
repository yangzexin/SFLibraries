//
//  SFLineView.m
//  SFiOSKit
//
//  Created by yangzexin on 11/18/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFLineView.h"

#import "UIImage+SFAddition.h"

typedef struct {
    BOOL vertical;
    BOOL normalBorder;
    CGSize viewSize;
} SFLineViewImageSetting;

@interface SFLineView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) SFLineViewImageSetting imageSetting;

@end

@implementation SFLineView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self _init];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.color = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
    [self _init];
}

- (void)_init {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.alignment == SFLineViewAlignmentTop) {
        self.imageView.contentMode = UIViewContentModeTop;
    } else if (self.alignment == SFLineViewAlignmentCenter) {
        self.imageView.contentMode = UIViewContentModeCenter;
    } else if (self.alignment == SFLineViewAlignmentBottom) {
        self.imageView.contentMode = _vertical ? UIViewContentModeRight : UIViewContentModeBottom;
    }
    
    SFLineViewImageSetting setting;
    setting.vertical = _vertical;
    setting.normalBorder = _normalBorder;
    setting.viewSize = self.frame.size;
    
    if (setting.vertical != _imageSetting.vertical
        || setting.normalBorder != _imageSetting.normalBorder
        || setting.viewSize.width != _imageSetting.viewSize.width
        || setting.viewSize.height != _imageSetting.viewSize.height) {
        _imageSetting = setting;
        
        CGFloat lineWidth = _normalBorder ? 1.0f : ([UIScreen mainScreen].scale > 1.0f ? 0.50f : 1.0f);
        if (self.vertical) {
            self.imageView.image = [UIImage sf_imageWithColor:self.color size:CGSizeMake(lineWidth, self.frame.size.height)];
        } else {
            self.imageView.image = [UIImage sf_imageWithColor:self.color size:CGSizeMake(self.frame.size.width, lineWidth)];
        }
    }
}

- (void)setAlignment:(SFLineViewAlignment)alignment {
    _alignment = alignment;
    [self setNeedsLayout];
}

@end
