//
//  UITextField+SFNotEmpty.m
//  SFiOSKit
//
//  Created by yangzexin on 5/25/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "UITextField+SFNotEmpty.h"

#import "UIAlertView+SFAddition.h"

@implementation UITextField (SFNotEmpty)

- (BOOL)sf_isNotEmptyWithTips:(NSString *)tips {
    if (self.text.length == 0) {
        [UIAlertView sf_alertWithTitle:NSLocalizedString(@"Prompt", nil) message:tips completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
            [self becomeFirstResponder];
        } cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitleList:nil];
    }
    
    return self.text.length != 0;
}

@end
