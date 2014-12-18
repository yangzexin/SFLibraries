//
//  UIDatePicker+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 5/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDatePicker (SFAddition)

+ (void)sf_pickDateWithViewController:(UIViewController *)viewController
                                title:(NSString *)title
                                 date:(NSDate *)date
                          minimumDate:(NSDate *)miniumDate
                          maximumDate:(NSDate *)maximumDate
                                 mode:(UIDatePickerMode)mode
                           completion:(void(^)(NSDate *selecteDate, BOOL cancelled))completion;

@end
