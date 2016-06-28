//
//  UITableViewCell+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 12/21/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "UITableViewCell+SFAddition.h"

@implementation UITableViewCell (SFAddition)

- (void)sf_makeFrameCompatibleWithTableView:(UITableView *)tableView {
    [self sf_makeFrameCompatibleWithWidth:tableView.frame.size.width];
}

- (void)sf_makeFrameCompatibleWithWidth:(CGFloat)width {
    CGRect tmpRect = self.frame;
    tmpRect.size.width = width;
    self.frame = tmpRect;
    
    tmpRect = self.contentView.frame;
    tmpRect.size.width = width;
    self.contentView.frame = tmpRect;
}

- (void)sf_makeTransparent {
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [UIView new];
}

@end
