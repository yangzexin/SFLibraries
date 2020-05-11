//
//  UIAlertView+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 13-7-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SFAlertViewCompletion)(NSInteger buttonIndex, NSString *buttonTitle);

@interface UIAlertView (SFAddition_quickAlert)

+ (void)sf_dismissPresentingDialogAnimated:(BOOL)animated __attribute__((deprecated));

+ (UIAlertView *)sf_alertWithTitle:(NSString *)title message:(NSString *)message completion:(SFAlertViewCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... __attribute__((deprecated));

+ (UIAlertView *)sf_alertWithTitle:(NSString *)title message:(NSString *)message completion:(SFAlertViewCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitleList:(NSArray *)otherButtonTitleList __attribute__((deprecated));

+ (UIAlertView *)sf_alertWithTitle:(NSString *)title message:(NSString *)message completion:(void(^)(void))completion __attribute__((deprecated));

+ (UIAlertView *)sf_alertWithMessage:(NSString *)message completion:(void (^)(void))completion __attribute__((deprecated));

@end

@interface UIAlertView (SFAddition_confirmDialog)

+ (void)sf_confirmWithTitle:(NSString *)title message:(NSString *)message approve:(void(^)(void))approve __attribute__((deprecated));
+ (void)sf_confirmWithTitle:(NSString *)title message:(NSString *)message approve:(void(^)(void))approve cancel:(void(^)(void))cancel __attribute__((deprecated));

@end

@interface UIAlertView (SFAddition_inputDialog)

+ (UITextField *)sf_inputWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle approveButtonTitle:(NSString *)approveButtonTitle completion:(void(^)(NSString *input, BOOL cancelled))completion __attribute__((deprecated));

+ (UITextField *)sf_inputWithTitle:(NSString *)title message:(NSString *)message secureTextEntry:(BOOL)secureTextEntry cancelButtonTitle:(NSString *)cancelButtonTitle approveButtonTitle:(NSString *)approveButtonTitle completion:(void(^)(NSString *input, BOOL cancelled))completion __attribute__((deprecated));

@end

@interface UIAlertView (SFAddition)

- (UILabel *)sf_messageLabel __attribute__((deprecated));
- (UILabel *)sf_titleLabel __attribute__((deprecated));

@end
