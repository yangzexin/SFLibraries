//
//  UITextView+SFPlaceholder.m
//  SFiOSKit
//
//  Created by yangzexin on 6/2/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "UITextView+SFPlaceholder.h"

#import <SFFoundation/SFFoundation.h>

#import "UILabel+SFAddition.h"
#import "SFiOSKitConstants.h"

@implementation UITextView (SFPlaceholder)

- (void)sf_setPlaceholder:(NSString *)placeholder {
    UILabel *placeholderLabel = [self sf_associatedObjectWithKey:@"_placeholderLabel"];
    if (placeholderLabel == nil) {
        CGFloat placeholderLabelX = SFDeviceSystemVersion < 7.0f ? 10.0f : 5;
        placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(placeholderLabelX, 7, self.frame.size.width - placeholderLabelX, 0)];
        placeholderLabel.text = placeholder;
        placeholderLabel.font = self.font;
        placeholderLabel.textColor = [UIColor lightGrayColor];
        placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [placeholderLabel sf_fitHeightByTextUsingCurrentFontWithMaxHeight:0];
        [self addSubview:placeholderLabel];
        
        placeholderLabel.hidden = self.text.length != 0;
        
        [self sf_setAssociatedObject:placeholderLabel key:@"_placeholderLabel"];
        
        __weak typeof(self) wself = self;
        __weak typeof(placeholderLabel) wplaceholderLabel = placeholderLabel;
        [self sf_depositNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            __strong typeof(wself) self = wself;
            if (self) {
                if (note.object == self) {
                    wplaceholderLabel.hidden = self.text.length != 0;
                }
            }
        }]];
    }
}

- (NSString *)sf_placeholder {
    UILabel *placeholderLabel = [self sf_associatedObjectWithKey:@"_placeholderLabel"];
    
    return placeholderLabel.text;
}

@end
