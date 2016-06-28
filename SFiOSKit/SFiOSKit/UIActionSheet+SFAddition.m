//
//  UIActionSheet+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 10/31/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "UIActionSheet+SFAddition.h"

@interface SFActionSheetWrapper : NSObject <UIActionSheetDelegate>

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, copy) SFActionSheetDialogCompletion completion;

@end

@implementation SFActionSheetWrapper

- (UIActionSheet *)actionSheetWithTitle:(NSString *)title completion:(SFActionSheetDialogCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles {
    CFRetain((__bridge CFTypeRef)(self));
    self.completion = completion;
    self.actionSheet = [UIActionSheet new];
    self.actionSheet.title = title;
    self.actionSheet.delegate = self;
    for (NSString *title in otherButtonTitles) {
        [self.actionSheet addButtonWithTitle:title];
    }
    NSInteger count = otherButtonTitles.count;
    if (destructiveButtonTitle.length != 0) {
        [self.actionSheet addButtonWithTitle:destructiveButtonTitle];
        self.actionSheet.destructiveButtonIndex = count++;
    }
    if (cancelButtonTitle.length != 0) {
        [self.actionSheet addButtonWithTitle:cancelButtonTitle];
        self.actionSheet.cancelButtonIndex = count;
    }
    
    [self.actionSheet showInView:[[UIApplication sharedApplication].windows objectAtIndex:0]];
    
    return _actionSheet;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.completion) {
        self.completion(buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        CFRelease((__bridge CFTypeRef)(self));
    });
}

@end

@implementation UIActionSheet (SFAddition)

+ (UIActionSheet *)sf_actionSheetWithTitle:(NSString *)title completion:(SFActionSheetDialogCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    NSMutableArray *titleList = [NSMutableArray array];
    va_list params;
    va_start(params, otherButtonTitles);
    for (id item = otherButtonTitles; item != nil; item = va_arg(params, id)) {
        [titleList addObject:item];
    }
    va_end(params);
    return [self sf_actionSheetWithTitle:title
                           completion:completion
                    cancelButtonTitle:cancelButtonTitle
               destructiveButtonTitle:destructiveButtonTitle
                 otherButtonTitleList:titleList];
}

+ (UIActionSheet *)sf_actionSheetWithTitle:(NSString *)title completion:(SFActionSheetDialogCompletion)completion cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitleList:(NSArray *)otherButtonTitleList {
    return [[SFActionSheetWrapper new] actionSheetWithTitle:title
                                                 completion:completion
                                          cancelButtonTitle:cancelButtonTitle
                                     destructiveButtonTitle:destructiveButtonTitle
                                          otherButtonTitles:otherButtonTitleList];
}

- (void)sf_setButtonTitleColor:(UIColor *)titleColor {
    [self sf_enumerateButtonsUsingBlock:^(UIButton *button) {
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    }];
}

- (void)sf_enumerateButtonsUsingBlock:(void(^)(UIButton *button))block {
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (id)subview;
            block(button);
        }
    }
}

@end
