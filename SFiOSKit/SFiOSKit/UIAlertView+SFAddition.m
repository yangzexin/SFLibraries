//
//  UIAlertView+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 13-7-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+SFAddition.h"

#import <SFFoundation/SFFoundation.h>

NSString *SFClosePresentingAlertViewOptionsAnimationStateKey = @"SFClosePresentingNotificationConfigAnimatedKey";
NSString *SFClosePresentingAlertViewNotification = @"SFClosePresentingAlertNotification";

@interface SFAlertViewWrapper : NSObject <UIAlertViewDelegate>

@property (nonatomic, copy) SFAlertViewCompletion completion;
@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation SFAlertViewWrapper

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showWithTitle:(NSString *)title message:(NSString *)message completion:(SFAlertViewCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles {
    CFRetain((__bridge CFTypeRef)self);
    self.completion = completion;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:nil];
    for (NSString *title in otherButtonTitles) {
        [alertView addButtonWithTitle:title];
    }
    [alertView show];
    
    self.alertView = alertView;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closePresentingAlertNotification:)
                                                 name:SFClosePresentingAlertViewNotification
                                               object:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.completion) {
        self.completion(buttonIndex, [alertView buttonTitleAtIndex:buttonIndex]);
    }
    self.alertView = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        CFRelease((__bridge CFTypeRef)(self));
    });
}

- (void)closePresentingAlertNotification:(NSNotification *)n {
    NSNumber *animated = [n.userInfo objectForKey:SFClosePresentingAlertViewOptionsAnimationStateKey];
    [self.alertView dismissWithClickedButtonIndex:0 animated:[animated boolValue]];
    [self alertView:self.alertView clickedButtonAtIndex:0];
}

@end

#define kInputFieldPortraitY    75
#define kInputFieldLandscapeY   57

@interface SFAlertViewInputWrapper : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UITextField *addedTextField;
@property (nonatomic, assign) BOOL useCustomTextField;
@property (nonatomic, copy) void(^completion)(NSString *, BOOL);

@end

@implementation SFAlertViewInputWrapper

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showWithTitle:(NSString *)title message:(NSString *)message secureTextEntry:(BOOL)secureTextEntry clearButtonMode:(UITextFieldViewMode)clearButtonMode cancelButtonTitle:(NSString *)cancelButtonTitle approveButtonTitle:(NSString *)approveButtonTitle completion:(void(^)(NSString *input, BOOL cancelled))completion {
    CFRetain((__bridge CFTypeRef)self);
    self.completion = completion;
    self.alertView = [[UIAlertView alloc] initWithTitle:title
                                                message:message
                                               delegate:self
                                      cancelButtonTitle:cancelButtonTitle
                                      otherButtonTitles:approveButtonTitle, nil];
    UITextField *textField = nil;
    self.useCustomTextField = ![self.alertView respondsToSelector:@selector(alertViewStyle)];
    if (self.useCustomTextField) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarOrientationDidChangeNotification:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        textField = [[UITextField alloc] initWithFrame:CGRectMake(10, [self yPositionForCustomTextField], 264, 35)];
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.borderStyle = UITextBorderStyleBezel;
        textField.tag = 1001;
        textField.backgroundColor = [UIColor whiteColor];
        textField.clearButtonMode = clearButtonMode;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.secureTextEntry = secureTextEntry;
        self.addedTextField = textField;
        [self.alertView addSubview:textField];
        self.alertView.message = [NSString stringWithFormat:@"%@\n\n\n", self.alertView.message ? self.alertView.message : @""];
    } else {
        self.alertView.alertViewStyle = secureTextEntry ? UIAlertViewStyleSecureTextInput : UIAlertViewStylePlainTextInput;
        [[self.alertView textFieldAtIndex:0] setClearButtonMode:clearButtonMode];
        [self.alertView textFieldAtIndex:0].contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    [self.alertView show];
    [textField becomeFirstResponder];
}

- (UITextField *)inputTextField {
    return self.useCustomTextField ? self.addedTextField : [self.alertView textFieldAtIndex:0];
}

#pragma mark - events
- (void)statusBarOrientationDidChangeNotification:(NSNotification *)noti {
    CGRect tmpRect = self.addedTextField.frame;
    tmpRect.origin.y = [self yPositionForCustomTextField];
    [UIView animateWithDuration:0.25f animations:^{
        self.addedTextField.frame = tmpRect;
    }];
}

- (CGFloat)yPositionForCustomTextField {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? kInputFieldLandscapeY : kInputFieldPortraitY;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *text = nil;
    if (self.useCustomTextField) {
        UITextField *textField = (id)[alertView viewWithTag:1001];
        text = textField.text;
    } else {
        text = [[self.alertView textFieldAtIndex:0] text];
    }
    if (self.completion) {
        self.completion(text, buttonIndex == 0);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        CFRelease((__bridge CFTypeRef)(self));
    });
}

@end

@implementation UIAlertView (SFAddition_quickAlert)

+ (void)sf_dismissPresentingDialogAnimated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:SFClosePresentingAlertViewNotification
                                                        object:nil
                                                      userInfo:@{SFClosePresentingAlertViewOptionsAnimationStateKey : [NSNumber numberWithBool:animated]}];
}

+ (UIAlertView *)sf_alertWithTitle:(NSString *)title message:(NSString *)message completion:(SFAlertViewCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    NSMutableArray *titleList = [NSMutableArray array];
    va_list params;
    va_start(params, otherButtonTitles);
    for(id item = otherButtonTitles; item != nil; item = va_arg(params, id)){
        [titleList addObject:item];
    }
    va_end(params);
    
    return [self sf_alertWithTitle:title message:message completion:completion cancelButtonTitle:cancelButtonTitle otherButtonTitleList:titleList];
}

+ (UIAlertView *)sf_alertWithTitle:(NSString *)title message:(NSString *)message completion:(SFAlertViewCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitleList:(NSArray *)otherButtonTitleList {
    SFAlertViewWrapper *alertDialog = [[SFAlertViewWrapper alloc] init];
    [alertDialog showWithTitle:title message:message completion:completion cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleList];
    
    return alertDialog.alertView;
}

+ (id)sf_alertWithTitle:(NSString *)title message:(NSString *)message completion:(void(^)())completion {
    return [self sf_alertWithTitle:title message:message completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
        if (completion) {
            completion();
        }
    } cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
}

+ (id)sf_alertWithMessage:(NSString *)message completion:(void (^)())completion {
    return [self sf_alertWithTitle:@"" message:message completion:completion];
}

@end

@implementation UIAlertView (SFAddition_confirmDialog)

+ (void)sf_confirmWithTitle:(NSString *)title message:(NSString *)message approve:(void(^)())approve {
    [self sf_confirmWithTitle:title message:message approve:approve cancel:nil];
}

+ (void)sf_confirmWithTitle:(NSString *)title message:(NSString *)message approve:(void(^)())approve cancel:(void(^)())cancel {
    [self sf_alertWithTitle:title message:message completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
        if (buttonIndex == 0) {
            if (approve) {
                approve();
            }
        } else if (buttonIndex == 1) {
            if (buttonIndex == 1) {
                if (cancel) {
                    cancel();
                }
            }
        }
    } cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
}

@end

@implementation UIAlertView (SFAddition_inputDialog)

+ (UITextField *)sf_inputWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle approveButtonTitle:(NSString *)approveButtonTitle completion:(void(^)(NSString *input, BOOL cancelled))completion {
    return [self sf_inputWithTitle:title
                        message:message
                secureTextEntry:NO
              cancelButtonTitle:cancelButtonTitle
             approveButtonTitle:approveButtonTitle
                     completion:completion];
}

+ (UITextField *)sf_inputWithTitle:(NSString *)title message:(NSString *)message secureTextEntry:(BOOL)secureTextEntry cancelButtonTitle:(NSString *)cancelButtonTitle approveButtonTitle:(NSString *)approveButtonTitle completion:(void(^)(NSString *input, BOOL cancelled))completion {
    SFAlertViewInputWrapper *inputDialog = [SFAlertViewInputWrapper new];
    [inputDialog showWithTitle:title
                       message:message
               secureTextEntry:secureTextEntry
               clearButtonMode:UITextFieldViewModeWhileEditing
             cancelButtonTitle:cancelButtonTitle
            approveButtonTitle:approveButtonTitle
                    completion:completion];
    
    return [inputDialog inputTextField];
}

@end

@implementation UIAlertView (SFAddition)

- (UILabel *)sf_messageLabel {
    UILabel *messageLabel = nil;
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            if (label.text == self.message) {
                messageLabel = label;
                break;
            }
        }
    }
    
    return messageLabel;
}

- (UILabel *)sf_titleLabel {
    UILabel *titleLabel = nil;
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            if (label.text == self.title) {
                titleLabel = label;
                break;
            }
        }
    }
    
    return titleLabel;
}

@end
