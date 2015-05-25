//
//  UITextField+NotEmpty.h
//  SFiOSKit
//
//  Created by yangzexin on 5/25/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITextField (NotEmpty)

- (BOOL)isNotEmptyWithTips:(NSString *)tips;

@end
