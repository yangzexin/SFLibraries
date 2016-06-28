//
//  UILabel+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 13-7-29.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "UILabel+SFAddition.h"

#import "NSString+SFiOSAddition.h"

@implementation UILabel (SFAddition)

- (CGFloat)sf_fitHeightByTextUsingCurrentFontWithMaxNumOfLines:(NSInteger)maxNumOfLines {
    return [self sf_fitHeightByTextUsingCurrentFontWithMaxHeight:self.font.lineHeight * maxNumOfLines];
}

- (CGFloat)sf_fitHeightByTextUsingCurrentFontWithMaxHeight:(CGFloat)maxHeight {
    CGRect tmpRect = self.frame;
    tmpRect.size.height = [self.text sf_sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, maxHeight <= 0 ? MAXFLOAT : maxHeight)].height;
    self.frame = tmpRect;
    self.numberOfLines = tmpRect.size.height / self.font.lineHeight;
    
    return self.frame.size.height;
}

@end
