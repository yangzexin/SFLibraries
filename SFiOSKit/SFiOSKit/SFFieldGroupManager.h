//
//  SFFieldGroupManager.h
//  SFiOSKit
//
//  Created by yangzexin on 11/6/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFFieldGroupManager : NSObject

@property (nonatomic, readonly) NSArray *fields;
@property (nonatomic, assign) BOOL setReturnKeyAutomatically;
@property (nonatomic, assign) id<UITextFieldDelegate> textFieldDelegate;

@property (nonatomic, copy) void(^fieldPositor)(id field);
@property (nonatomic, copy) void(^doneHandler)();

- (void)resignFirstResponder;
- (void)becomeFirstResponder;
- (BOOL)isFirstResponder;

- (void)addTextField:(UITextField *)textField;
- (void)addTextField:(UITextField *)textField setDelegate:(BOOL)setDelegate;
- (void)addTextView:(UITextView *)textView;
- (void)removeItem:(id)item;

- (void)fieldWillBeginEditing:(id)field;
- (void)fieldDidEndEditing:(id)field;
- (void)fieldWillReturn:(id)field;

@end
