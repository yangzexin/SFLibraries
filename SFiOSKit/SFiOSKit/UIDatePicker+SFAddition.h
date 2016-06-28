//
//  UIDatePicker+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 5/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDatePickerDialogOptions : NSObject

+ (instancetype)dialogOptionsWithTitle:(NSString *)title;

- (instancetype)setTitle:(NSString *)title;
- (instancetype)setDate:(NSDate *)date;
- (instancetype)setMiniumDate:(NSDate *)miniumDate;
- (instancetype)setMaximumDate:(NSDate *)maximumDate;
- (instancetype)setMode:(UIDatePickerMode)mode;

@end

@interface UIDatePicker (SFAddition)

+ (void)sf_pickInViewController:(UIViewController *)viewController options:(SFDatePickerDialogOptions *)options completion:(void(^)(NSDate *selecteDate, BOOL cancelled))completion;

@end
