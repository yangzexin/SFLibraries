//
//  SFFieldGroupManager.h
//  SFiOSKit
//
//  Created by yangzexin on 11/6/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITextField (GapBetweenKeyboard)

- (UITextField *)sf_setGapBetweenKeyboard:(CGFloat)gap;
- (CGFloat)sf_gapBetweenKeyboard;

@end

@interface UITextView (GapBetweenKeyboard)

- (UITextView *)sf_setGapBetweenKeyboard:(CGFloat)gap;
- (CGFloat)sf_gapBetweenKeyboard;

@end

@interface SFFieldGroupManager : NSObject

/**
 default is YES
 */
@property (nonatomic, assign) BOOL setReturnKeyAutomatically;

/**
 default is YES
 */
@property (nonatomic, assign) BOOL setPositionAutomatically;

/**
 default is NO
 */
@property (nonatomic, assign) BOOL alwaysAutoSetPosition;

@property (nonatomic, assign) id<UITextFieldDelegate> textFieldDelegate;

@property (nonatomic, assign) UIReturnKeyType doneReturnKeyType;

@property (nonatomic, copy) void(^whenFieldBecameFirstResponder)(id field);
@property (nonatomic, copy) void(^whenReturnDone)();

@property (nonatomic, readonly) NSArray *fields;

+ (instancetype)manager;

/**
 The y position of rootScrollView must be 0.0f
 */
+ (instancetype)managerForRootScrollView:(UIScrollView *)rootScrollView;

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
