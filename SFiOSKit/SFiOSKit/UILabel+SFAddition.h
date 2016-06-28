//
//  UILabel+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 13-7-29.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UILabel (SFAddition)

- (CGFloat)sf_fitHeightByTextUsingCurrentFontWithMaxNumOfLines:(NSInteger)maxNumOfLines;
- (CGFloat)sf_fitHeightByTextUsingCurrentFontWithMaxHeight:(CGFloat)maxHeight;

@end
