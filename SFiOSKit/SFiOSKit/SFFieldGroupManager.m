//
//  SFFieldGroupManager.m
//  SFiOSKit
//
//  Created by yangzexin on 11/6/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFFieldGroupManager.h"

#import <SFFoundation/SFFoundation.h>

#import "UIView+SFAddition.h"

@implementation UITextField (GapBetweenKeyboard)

- (UITextField *)sf_setGapBetweenKeyboard:(CGFloat)gap {
    [self sf_setAssociatedObject:@(gap) key:@"_gapBetweenKeyboard"];
    
    return self;
}

- (CGFloat)sf_gapBetweenKeyboard {
    NSNumber *gap = [self sf_associatedObjectWithKey:@"_gapBetweenKeyboard"];
    
    return gap == nil ? .0f : gap.floatValue;
}

@end

@implementation UITextView (GapBetweenKeyboard)

- (UITextView *)sf_setGapBetweenKeyboard:(CGFloat)gap {
    [self sf_setAssociatedObject:@(gap) key:@"_gapBetweenKeyboard"];
    
    return self;
}

- (CGFloat)sf_gapBetweenKeyboard {
    NSNumber *gap = [self sf_associatedObjectWithKey:@"_gapBetweenKeyboard"];
    
    return gap == nil ? .0f : gap.floatValue;
}

@end

@interface SFFieldGroupManager () <UITextFieldDelegate>

@property (nonatomic, weak) UIScrollView *rootScrollView;

@property (nonatomic, strong) NSMutableArray *addedFields;
@property (nonatomic, strong) SFMarkWaiting *waitingForNotAnimating;
@property (nonatomic, strong) SFMarkWaiting *waitingForKeyboardShown;

@property (nonatomic, assign) CGFloat topSuperViewLastPositionY;
@property (nonatomic, assign) BOOL topSuperViewPositionReseted;

@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation SFFieldGroupManager

+ (instancetype)managerForRootScrollView:(UIScrollView *)rootScrollView {
    SFFieldGroupManager *manager = [SFFieldGroupManager new];
    manager.rootScrollView = rootScrollView;
    
    return manager;
}

+ (instancetype)manager {
    return [self managerForRootScrollView:nil];
}

- (id)init {
    self = [super init];
    
    _addedFields = [NSMutableArray array];
    
    self.doneReturnKeyType = UIReturnKeyDone;
    self.setReturnKeyAutomatically = YES;
    self.setPositionAutomatically = YES;

    self.waitingForNotAnimating = [SFMarkWaiting markWaiting];
    self.waitingForKeyboardShown = [SFMarkWaiting markWaiting];
    
    __weak typeof(self) weakSelf = self;
    [self sf_depositNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.waitingForKeyboardShown markAsFinish];
        self.keyboardHeight = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        
        id field = nil;
        if ([self _isFirstResponderWithOutField:&field]) {
            [self fieldWillBeginEditing:field];
        }
    }]];
    
    [self sf_depositNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.waitingForKeyboardShown resetMark];
    }]];
    
    [self sf_depositNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        __strong typeof(weakSelf) self = weakSelf;
        id field = nil;
        if ([self _isFirstResponderWithOutField:&field]) {
            [self _restoreSuperViewPositionWithField:field];
        }
    }]];
    
    return self;
}

- (void)removeField:(id)field {
    [self.addedFields removeObject:field];
}

- (void)addTextField:(UITextField *)textField {
    [self addTextField:textField setDelegate:NO];
}

- (void)addTextField:(UITextField *)textField setDelegate:(BOOL)setDelegate {
    [self removeField:textField];
    [self.addedFields addObject:textField];
    if (setDelegate) {
        textField.delegate = self;
    }
}

- (void)addTextView:(UITextView *)textView {
    [self removeField:textView];
    [self.addedFields addObject:textView];
}

- (NSArray *)fields {
    return self.addedFields;
}

- (void)resignFirstResponder {
    for (UITextField *field in self.fields) {
        [field resignFirstResponder];
    }
}

- (void)becomeFirstResponder {
    if (self.fields.count != 0) {
        UITextField *field = [self.fields objectAtIndex:0];
        [field becomeFirstResponder];
    }
}

- (BOOL)isFirstResponder {
    return [self _isFirstResponderWithOutField:nil];
}

- (BOOL)_isFirstResponderWithOutField:(id *)outField {
    BOOL isFirstResponder = NO;
    for (UITextField *field in self.fields) {
        if ([field isFirstResponder]) {
            isFirstResponder = YES;
            if (outField != nil) {
                *outField = field;
            }
            
            break;
        }
    }
    
    return isFirstResponder;
}

- (void)fieldWillBeginEditing:(id)field {
    if (self.whenFieldBecameFirstResponder) {
        self.whenFieldBecameFirstResponder(field);
    }
    if (self.setReturnKeyAutomatically && [field isKindOfClass:[UITextField class]]) {
        NSUInteger index = [self.fields indexOfObject:field];
        if (index != NSNotFound) {
            UITextField *textField = field;
            textField.returnKeyType = index == self.fields.count - 1 ? self.doneReturnKeyType : UIReturnKeyNext;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [self.waitingForKeyboardShown wait:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (self.setPositionAutomatically) {
            CGFloat minimalGapHeight = [self _minimalGapHeightForField:field];
            CGRect fieldFrame = [field frame];
            UIView *tmpView = [field superview];
            
            if (self.rootScrollView == nil) {
                UIView *topSuperView = [[field sf_viewController] view];
                CGFloat absoluteY = fieldFrame.origin.y;
                while (tmpView != topSuperView) {
                    absoluteY += tmpView.frame.origin.y;
                    tmpView = tmpView.superview;
                }
                
                CGFloat gap = topSuperView.frame.size.height - absoluteY - self.keyboardHeight - fieldFrame.size.height;
                
                if (gap < minimalGapHeight || self.alwaysAutoSetPosition) {
                    self.topSuperViewPositionReseted = YES;
                    [self.waitingForNotAnimating resetMark];
                    [UIView animateWithDuration:.25f animations:^{
                        CGRect tmpFrame = topSuperView.frame;
                        tmpFrame.origin.y = self.topSuperViewLastPositionY - (minimalGapHeight - gap);
                        topSuperView.frame = tmpFrame;
                    } completion:^(BOOL finished) {
                        [self.waitingForNotAnimating markAsFinish];
                    }];
                }
            } else {
                CGFloat relativeY = fieldFrame.origin.y;
                while (tmpView != self.rootScrollView) {
                    relativeY += tmpView.frame.origin.y;
                    tmpView = tmpView.superview;
                }
                
                CGFloat gap = self.rootScrollView.frame.size.height - (relativeY - self.rootScrollView.contentOffset.y) - self.keyboardHeight - fieldFrame.size.height;
                
                if (gap < minimalGapHeight || self.alwaysAutoSetPosition) {
                    self.topSuperViewPositionReseted = YES;
                    [self.waitingForNotAnimating resetMark];
                    [UIView animateWithDuration:.25f animations:^{
                        CGPoint contentOffset = self.rootScrollView.contentOffset;
                        contentOffset.y = self.rootScrollView.contentOffset.y + (minimalGapHeight - gap);
                        self.rootScrollView.contentOffset = contentOffset;
                    } completion:^(BOOL finished) {
                        [self.waitingForNotAnimating markAsFinish];
                    }];
                }
            }
        }
    }];
}

- (CGFloat)_minimalGapHeightForField:(id)field {
    return [field sf_gapBetweenKeyboard];
}

- (void)_restoreSuperViewPositionWithField:(id)field {
    if (self.setPositionAutomatically && self.topSuperViewPositionReseted) {
        UIView *topSuperView = [[field sf_viewController] view];
        [UIView animateWithDuration:.25f animations:^{
            if (!self.rootScrollView) {
                CGRect tmpFrame = topSuperView.frame;
                tmpFrame.origin.y = self.topSuperViewLastPositionY;
                topSuperView.frame = tmpFrame;
            } else {
                CGPoint contentOffset = self.rootScrollView.contentOffset;
                contentOffset.y = self.topSuperViewLastPositionY;
                self.rootScrollView.contentOffset = contentOffset;
            }
        }];
    }
}

- (void)fieldDidEndEditing:(id)field {
    __weak typeof(self) weakSelf = self;
    [self.waitingForNotAnimating wait:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (![self isFirstResponder]) {
            if (self.whenFieldBecameFirstResponder) {
                self.whenFieldBecameFirstResponder(nil);
            }
            
            [self _restoreSuperViewPositionWithField:field];
        }
    } uniqueIdentifier:@"QuickNext"];
}

- (void)fieldWillReturn:(id)field {
    NSInteger textFieldIndex = [self.addedFields indexOfObject:field];
    if (textFieldIndex != NSNotFound) {
        NSInteger nextTextFieldIndex = ++textFieldIndex;
        if (nextTextFieldIndex == [self.addedFields count]) {
            [(UIResponder *)field resignFirstResponder];
            if (self.whenReturnDone) {
                self.whenReturnDone();
            }
        } else {
            UITextField *nextField = [self.addedFields objectAtIndex:nextTextFieldIndex];
            [nextField becomeFirstResponder];
        }
    }
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [_textFieldDelegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    BOOL shouldEnd = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        shouldEnd = [_textFieldDelegate textFieldShouldEndEditing:textField];
    }
    
    return shouldEnd;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL shouldChange = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        shouldChange = [_textFieldDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return shouldChange;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    BOOL shouldClear = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        shouldClear = [_textFieldDelegate textFieldShouldClear:textField];
    }
    
    return shouldClear;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self fieldWillBeginEditing:textField];
    
    BOOL shouldBegin = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        shouldBegin = [_textFieldDelegate textFieldShouldBeginEditing:textField];
    }
    
    if (self.setPositionAutomatically && ![self isFirstResponder]) {
        if (self.rootScrollView == nil) {
            UIView *topSuperView = [[textField sf_viewController] view];
            self.topSuperViewLastPositionY = topSuperView.frame.origin.y;
        } else {
            self.topSuperViewLastPositionY = self.rootScrollView.contentOffset.y;
        }
    }
    
    return shouldBegin;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self fieldDidEndEditing:textField];
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_textFieldDelegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self fieldWillReturn:textField];
    
    BOOL shouldReturn = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        shouldReturn = [_textFieldDelegate textFieldShouldReturn:textField];
    }
    
    return shouldReturn;
}

@end
