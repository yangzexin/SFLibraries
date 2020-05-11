//
//  UIActionSheet+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 10/31/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SFActionSheetDialogCompletion)(NSInteger buttonIndex, NSString *buttonTitle);

@interface UIActionSheet (SFAddition)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (UIActionSheet *)sf_actionSheetWithTitle:(NSString *)title completion:(SFActionSheetDialogCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... __attribute__((deprecated));

+ (UIActionSheet *)sf_actionSheetWithTitle:(NSString *)title completion:(SFActionSheetDialogCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitleList:(NSArray *)otherButtonTitleList __attribute__((deprecated));

- (void)sf_setButtonTitleColor:(UIColor *)titleColor;

- (void)sf_enumerateButtonsUsingBlock:(void(^)(UIButton *button))block;
#pragma clang diagnostic pop

@end
