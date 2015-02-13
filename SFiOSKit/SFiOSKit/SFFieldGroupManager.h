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

/**
 default is YES
 */
@property (nonatomic, assign) BOOL setReturnKeyAutomatically;

@property (nonatomic, assign) id<UITextFieldDelegate> textFieldDelegate;

@property (nonatomic, assign) UIReturnKeyType doneReturnKeyType;

/**
 fieldPositor:if field == nil, fields did end editing.
 */
+ (instancetype)fieldGroupManagerWithFieldPositor:(void(^)(id field))fieldPositor;
+ (instancetype)fieldGroupManagerWithFieldPositor:(void(^)(id field))fieldPositor doneHandler:(void(^)())doneHandler;

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
