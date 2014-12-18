//
//  SFFieldGroupManager.m
//  SFiOSKit
//
//  Created by yangzexin on 11/6/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFFieldGroupManager.h"
#import "SFWaiting.h"
#import "UIView+SFAddition.h"

@interface SFFieldGroupManager () <UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *addedFields;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) NSValue *keyboardFrame;
@property (nonatomic, strong) NSNumber *animationCurve;
@property (nonatomic, strong) NSNumber *animationDuration;
@property (nonatomic, strong) SFWaiting *waitingForNotAnimating;
@property (nonatomic, assign) CGRect tmpFrame;
@property (nonatomic, assign) BOOL tmpFrameDirty;
@end

@implementation SFFieldGroupManager

- (id)init
{
    self = [super init];
    
    _addedFields = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];

    __weak typeof(self) weakSelf = self;
    self.waitingForNotAnimating = [SFWaiting waitWithCondition:^BOOL{
        __strong typeof(weakSelf) self = weakSelf;
        return !self.animating;
    }];
    
    return self;
}

- (void)removeField:(id)field
{
    [self.addedFields removeObject:field];
}

- (void)addTextField:(UITextField *)textField
{
    [self addTextField:textField setDelegate:NO];
}

- (void)addTextField:(UITextField *)textField setDelegate:(BOOL)setDelegate
{
    [self removeField:textField];
    [self.addedFields addObject:textField];
    if (setDelegate) {
        textField.delegate = self;
    }
    
    [self searchContainViewFrom:textField];
}

- (void)addTextView:(UITextView *)textView
{
    [self removeField:textView];
    [self.addedFields addObject:textView];
}

- (void)removeItem:(id)item
{
    [self removeField:item];
}

- (NSArray *)fields
{
    return self.addedFields;
}

- (void)resignFirstResponder
{
    for (UITextField *field in self.fields) {
        [field resignFirstResponder];
    }
}

- (void)becomeFirstResponder
{
    if (self.fields.count != 0) {
        UITextField *field = [self.fields objectAtIndex:0];
        [field becomeFirstResponder];
    }
}

- (BOOL)isFirstResponder
{
    BOOL isFirstResponder = NO;
    for (UITextField *field in self.fields) {
        if ([field isFirstResponder]) {
            isFirstResponder = YES;
            break;
        }
    }
    return isFirstResponder;
}

- (void)fieldWillBeginEditing:(id)field
{
    self.animating = YES;
    [UIView animateWithDuration:.25f animations:^{
        if (self.fieldPositor) {
            self.fieldPositor(field);
        } else if (field) {
            [self _scrollViewForFirstResponder:field];
        }
        if (self.setReturnKeyAutomatically && [field isKindOfClass:[UITextField class]]) {
            NSUInteger index = [self.fields indexOfObject:field];
            if (index != NSNotFound) {
                UITextField *textField = field;
                textField.returnKeyType = index == self.fields.count - 1 ? UIReturnKeyDone : UIReturnKeyNext;
            }
        }
    } completion:^(BOOL finished) {
        self.animating = NO;
    }];
}

#pragma mark scroll to suitable position
- (void)_scrollViewForFirstResponder:(UIView *)firstResponder
{
    CGFloat screenHeight = [[UIScreen mainScreen] currentMode].size.height / [[UIScreen mainScreen] scale];
    CGFloat statusBarHeight = [self statusBarHeight];
    
    CGRect r = [self _rectToKeyWindow:firstResponder];
    CGFloat bottom = CGRectGetMaxY(r);
    CGFloat scrollOffsetY = MAXFLOAT;
    
    CGFloat oldOffset = ([_fieldsContainView isKindOfClass:[UIScrollView class]] ? [(UIScrollView *)_fieldsContainView contentOffset].y : 0);
    
    if (r.origin.y < statusBarHeight) {
        //上面盖住了
        CGFloat offsetY = r.origin.y + oldOffset;
        
        if (offsetY >= statusBarHeight) {
            scrollOffsetY = 0;
        } else if (offsetY >= 0) {
            scrollOffsetY = -statusBarHeight;
        }
        
    } else if (bottom + self.keyboardHeight + self.keyboardInset > screenHeight) {
        //键盘盖住输入框了
        scrollOffsetY = bottom + self.keyboardHeight + self.keyboardInset - screenHeight + oldOffset;
    }
    
    if (scrollOffsetY != MAXFLOAT) {
        [self setfieldsSuperviewOffset:scrollOffsetY];
    }
}

- (CGFloat)statusBarHeight
{
    return CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
}

- (void)setfieldsSuperviewOffset:(CGFloat)offsetY
{
    if (_fieldsContainView) {
        if ([_fieldsContainView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView *)_fieldsContainView;
            [scroll setContentOffset:CGPointMake(scroll.contentOffset.x, offsetY)];
        } else {
            if (!self.tmpFrameDirty) {
                _tmpFrame = _fieldsContainView.frame;
                self.tmpFrameDirty = YES;
            }
            CGRect rect = _fieldsContainView.frame;
            rect.origin.y = _fieldsContainView.frame.origin.y - offsetY;
            _fieldsContainView.frame = rect;
        }
    }
}

- (void)restoreFieldsSuperview
{
    if (_fieldsContainView) {
        if ([_fieldsContainView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView *)_fieldsContainView;
            [scroll setContentOffset:CGPointMake(scroll.contentOffset.x, 0)];
        } else {
            _fieldsContainView.frame = _tmpFrame;
        }
    }
}

- (CGRect)_rectToKeyWindow:(UIView *)fromView
{
    return [fromView convertRect:fromView.bounds toView:[[UIApplication sharedApplication] keyWindow]];
}


- (void)searchContainViewFrom:(UIView *)field
{
    if (_fieldsContainView == nil) {
        UIViewController *cont = [field sf_viewController];
        _fieldsContainView = cont ? cont.view : field.superview;
    }
}

- (void)setfieldsContainView:(UIView *)fieldsContainView
{
    _fieldsContainView = fieldsContainView;
}

- (void)fieldDidEndEditing:(id)field
{
    if ([field isKindOfClass:[UITextField class]]) {
        NSUInteger index = [self.fields indexOfObject:field];
        if (index != NSNotFound) {
            if (index == self.fields.count - 1) {
                if (_doneHandler) {
                    _doneHandler();
                }
            }
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [self.waitingForNotAnimating wait:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (![self isFirstResponder]) {
            [UIView animateWithDuration:0.25f animations:^{
                if (self.fieldPositor) {
                    self.fieldPositor(nil);
                } else {
                    [self restoreFieldsSuperview];
                }
            }];
        }
    } uniqueIdentifier:@"QuickNext"];
}

- (void)fieldWillReturn:(id)field
{
    NSInteger textFieldIndex = [self.addedFields indexOfObject:field];
    if (textFieldIndex != NSNotFound) {
        NSInteger nextTextFieldIndex = ++textFieldIndex;
        if (nextTextFieldIndex == [self.addedFields count]) {
            [(UIResponder *)field resignFirstResponder];
        } else {
            UITextField *nextField = [self.addedFields objectAtIndex:nextTextFieldIndex];
            [nextField becomeFirstResponder];
        }
    }
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [_textFieldDelegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL shouldEnd = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        shouldEnd = [_textFieldDelegate textFieldShouldEndEditing:textField];
    }
    
    return shouldEnd;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        shouldChange = [_textFieldDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return shouldChange;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    BOOL shouldClear = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        shouldClear = [_textFieldDelegate textFieldShouldClear:textField];
    }
    
    return shouldClear;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self fieldWillBeginEditing:textField];
    
    BOOL shouldBegin = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        shouldBegin = [_textFieldDelegate textFieldShouldBeginEditing:textField];
    }
    
    return shouldBegin;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self fieldDidEndEditing:textField];
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_textFieldDelegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self fieldWillReturn:textField];
    
    BOOL shouldReturn = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        shouldReturn = [_textFieldDelegate textFieldShouldReturn:textField];
    }
    
    return shouldReturn;
}

#pragma mark track keyboard frame
- (void)_keyboardWillChangeFrameNotification:(NSNotification *)n
{
    [self updateKeyboardStatus:n];
}

- (void)updateKeyboardStatus:(NSNotification *)notice
{
    NSValue *tmpValue = notice.userInfo[UIKeyboardFrameEndUserInfoKey];
    if (self.keyboardFrame && [tmpValue isEqualToValue:self.keyboardFrame]) {
        return;
    } else {
        self.keyboardFrame = tmpValue;
    }
    
    self.animationCurve = notice.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    self.animationDuration = notice.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    self.keyboardHeight = [tmpValue CGRectValue].size.height;
    
    UIControl *firstResponder = nil;
    for (int i = 0; i < self.addedFields.count; i++) {
        UIControl *field = self.addedFields[i];
        if ([field isFirstResponder]) {
            firstResponder = field;
            break;
        }
    }
    
    if (firstResponder) {
        [self _scrollViewForFirstResponder:firstResponder];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
