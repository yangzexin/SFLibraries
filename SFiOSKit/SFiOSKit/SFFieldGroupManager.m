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

@property (nonatomic, copy) void(^fieldPositor)(id field);
@property (nonatomic, copy) void(^doneHandler)();

@property (nonatomic, strong) NSMutableArray *addedFields;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) NSNumber *animationCurve;
@property (nonatomic, strong) NSNumber *animationDuration;
@property (nonatomic, strong) SFWaiting *waitingForNotAnimating;

@property (nonatomic, assign) BOOL donePerforming;

@end

@implementation SFFieldGroupManager

+ (instancetype)fieldGroupManagerWithFieldPositor:(void(^)(id field))fieldPositor
{
    SFFieldGroupManager *manager = [SFFieldGroupManager new];
    manager.fieldPositor = fieldPositor;
    
    return manager;
}

+ (instancetype)fieldGroupManagerWithFieldPositor:(void(^)(id field))fieldPositor doneHandler:(void(^)())doneHandler
{
    SFFieldGroupManager *manager = [SFFieldGroupManager new];
    manager.fieldPositor = fieldPositor;
    manager.doneHandler = doneHandler;
    
    return manager;
}

- (id)init
{
    self = [super init];
    
    _setReturnKeyAutomatically = YES;
    _doneReturnKeyType = UIReturnKeyDone;
    _addedFields = [NSMutableArray array];

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
        }
        if (self.setReturnKeyAutomatically && [field isKindOfClass:[UITextField class]]) {
            NSUInteger index = [self.fields indexOfObject:field];
            if (index != NSNotFound) {
                UITextField *textField = field;
                textField.returnKeyType = index == self.fields.count - 1 ? self.doneReturnKeyType : UIReturnKeyNext;
            }
        }
    } completion:^(BOOL finished) {
        self.animating = NO;
    }];
}

- (void)fieldDidEndEditing:(id)field
{
    if ([field isKindOfClass:[UITextField class]]) {
        NSUInteger index = [self.fields indexOfObject:field];
        if (index != NSNotFound) {
            if (self.donePerforming && index == self.fields.count - 1) {
                self.donePerforming = NO;
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
            self.donePerforming = YES;
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

@end
