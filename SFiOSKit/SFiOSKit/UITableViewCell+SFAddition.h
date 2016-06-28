//
//  UITableViewCell+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 12/21/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITableViewCell (SFAddition)

- (void)sf_makeFrameCompatibleWithTableView:(UITableView *)tableView;
- (void)sf_makeFrameCompatibleWithWidth:(CGFloat)width;
- (void)sf_makeTransparent;

@end
