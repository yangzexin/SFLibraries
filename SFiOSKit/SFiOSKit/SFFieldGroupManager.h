//
//  MMFieldGroupManager.h
//  MMiOSKit
//
//  Created by yangzexin on 11/6/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFFieldGroupManager : NSObject

@property (nonatomic, readonly) NSArray *fields;
@property (nonatomic, assign) BOOL setReturnKeyAutomatically;
@property (nonatomic, assign) id<UITextFieldDelegate> textFieldDelegate;

@property (nonatomic, assign) UIReturnKeyType doneReturnKeyType;

@property (nonatomic, copy) void(^whenFieldBecameFirstResponder)(id field);
@property (nonatomic, copy) void(^whenReturnDone)();

- (void)resignFirstResponder;
- (void)becomeFirstResponder;
- (BOOL)isFirstResponder;

- (void)addTextField:(UITextField *)textField setDelegate:(BOOL)setDelegate;
- (void)addTextView:(UITextView *)textView;
- (void)removeField:(id)field;

- (void)fieldWillBeginEditing:(id)field;
- (void)fieldDidEndEditing:(id)field;
- (void)fieldWillReturn:(id)field;

@end
