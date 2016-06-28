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

+ (void)sf_dismissPresentingDialogAnimated:(BOOL)animated;

+ (UIAlertView *)sf_alertWithTitle:(NSString *)title message:(NSString *)message completion:(SFAlertViewCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

+ (UIAlertView *)sf_alertWithTitle:(NSString *)title message:(NSString *)message completion:(SFAlertViewCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitleList:(NSArray *)otherButtonTitleList;

+ (UIAlertView *)sf_alertWithTitle:(NSString *)title message:(NSString *)message completion:(void(^)())completion;

+ (UIAlertView *)sf_alertWithMessage:(NSString *)message completion:(void (^)())completion;

@end

@interface UIAlertView (SFAddition_confirmDialog)

+ (void)sf_confirmWithTitle:(NSString *)title message:(NSString *)message approve:(void(^)())approve;
+ (void)sf_confirmWithTitle:(NSString *)title message:(NSString *)message approve:(void(^)())approve cancel:(void(^)())cancel;

@end

@interface UIAlertView (SFAddition_inputDialog)

+ (UITextField *)sf_inputWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle approveButtonTitle:(NSString *)approveButtonTitle completion:(void(^)(NSString *input, BOOL cancelled))completion;

+ (UITextField *)sf_inputWithTitle:(NSString *)title message:(NSString *)message secureTextEntry:(BOOL)secureTextEntry cancelButtonTitle:(NSString *)cancelButtonTitle approveButtonTitle:(NSString *)approveButtonTitle completion:(void(^)(NSString *input, BOOL cancelled))completion;

@end

@interface UIAlertView (SFAddition)

- (UILabel *)sf_messageLabel;
- (UILabel *)sf_titleLabel;

@end