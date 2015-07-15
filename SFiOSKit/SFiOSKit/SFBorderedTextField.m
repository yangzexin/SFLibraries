//
//  SFBorderedTextField.m
//  SFiOSKit
//
//  Created by yangzexin on 5/24/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "SFBorderedTextField.h"

#import "UIImage+SFAddition.h"

@implementation SFBorderedTextField

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}

- (void)awakeFromNib {
    [self initialize];
}

- (void)initialize {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.image = [[UIImage sf_roundImageWithOptions:({
        SFRoundImageOptions *options = [SFRoundImageOptions options];
        [options setCornerRadius:5];
        [options setBorderColor:[UIColor lightGrayColor]];
        [options setSize:CGSizeMake(10, 10)];
        [options setLightBorder:YES];
        [options setBackgroundColor:[UIColor whiteColor]];
        options;
    })] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    imageView.userInteractionEnabled = NO;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:imageView];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(5, 0, bounds.size.width - (self.clearButtonMode == UITextFieldViewModeAlways || self.clearButtonMode == UITextFieldViewModeWhileEditing ? [self clearButtonRectForBounds:bounds].size.width : 0) - 5.0f, bounds.size.height);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(5, 0, bounds.size.width - (self.clearButtonMode == UITextFieldViewModeAlways || self.clearButtonMode == UITextFieldViewModeUnlessEditing ? [self clearButtonRectForBounds:bounds].size.width : 0) - 10.0f, bounds.size.height);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
