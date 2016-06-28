//
//  SFKeyboardStateListener.m
//  SFiOSKit
//
//  Created by yangzexin on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFKeyboardStateListener.h"

NSString *const SFKeyboardHeightDidChangeNotification = @"SFKeyboardHeightDidChangeNotification";

@interface _SFKeyboardObserverBlockWrapper : NSObject

@property (nonatomic, copy) void(^block)(SFKeyboardState *state);
@property (nonatomic, copy) NSString *identifier;

@end

@implementation _SFKeyboardObserverBlockWrapper

+ (instancetype)wrapperWithIdentifier:(NSString *)identifier block:(void(^)(SFKeyboardState *))block {
    _SFKeyboardObserverBlockWrapper *wrapper = [_SFKeyboardObserverBlockWrapper new];
    wrapper.identifier = identifier;
    wrapper.block = block;
    
    return wrapper;
}

@end

@interface SFKeyboardState ()

@property (nonatomic, assign) SFKeyboardStateType type;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) UIViewAnimationOptions animationCurve;

@end

@implementation SFKeyboardState

@end

@interface SFKeyboardStateListener ()

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) NSMutableArray *observerWrappers;
@property (nonatomic, assign) BOOL listening;
@property (nonatomic, assign) CGFloat keyboardY;

@property (nonatomic, assign) NSTimeInterval keyboardShowAnimationDuration;
@property (nonatomic, assign) NSTimeInterval keyboardHideAnimationDuration;
@property (nonatomic, assign) UIViewAnimationOptions keyboardShowAnimationCurve;
@property (nonatomic, assign) UIViewAnimationOptions keyboardHideAnimationCurve;

@end

@implementation SFKeyboardStateListener {
    BOOL _keyboardVisible;
}

@synthesize keyboardVisible = _keyboardVisible;

+ (SFKeyboardStateListener *)sharedListener {
    static SFKeyboardStateListener *instance = nil;
    if (!instance) {
        instance = [[SFKeyboardStateListener alloc] init];
    }
    
    return instance;
}

- (id)init {
    self = [super init];
    
    _observerWrappers = [NSMutableArray array];
    
    return self;
}

#pragma mark - instance methods
- (void)startListening {
    if (self.listening == NO) {
        self.listening = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardDidChangeFrameNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
    }
}

- (void)stopListening {
    if (self.listening) {
        self.listening = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)addKeyboardHeightObserverWithIdentifier:(NSString *)identifier usingBlock:(void(^)(SFKeyboardState *state))usingBlock {
    [self startListening];
    [self removeKeyboardObserverWithIdentifier:identifier];
    [self.observerWrappers addObject:[_SFKeyboardObserverBlockWrapper wrapperWithIdentifier:identifier block:usingBlock]];
}

- (void)removeKeyboardObserverWithIdentifier:(NSString *)identifier {
    [[self.observerWrappers copy] enumerateObjectsUsingBlock:^(_SFKeyboardObserverBlockWrapper *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            [self.observerWrappers removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
}

- (void)_keyboardStateChangedWithType:(SFKeyboardStateType)type {
    [[self.observerWrappers copy] enumerateObjectsUsingBlock:^(_SFKeyboardObserverBlockWrapper *obj, NSUInteger idx, BOOL *stop) {
        if (obj.block) {
            SFKeyboardState *state = [SFKeyboardState new];
            state.type = type;
            state.visible = self.keyboardVisible;
            state.height = self.keyboardHeight;
            state.animationDuration = self.keyboardVisible ? [self keyboardShowAnimationDuration] : [self keyboardHideAnimationDuration];
            state.animationCurve = self.keyboardVisible ? [self keyboardShowAnimationCurve] : [self keyboardHideAnimationCurve];
            
            obj.block(state);
        }
    }];
}

- (void)_keyboardShowOrChanged:(BOOL)changed notification:(NSNotification *)n type:(SFKeyboardStateType)type {
    NSNumber *curveValue = n.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    self.keyboardShowAnimationCurve = curveValue.intValue << 16;
    NSNumber *durationValue = n.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    self.keyboardShowAnimationDuration = durationValue.doubleValue;
    
    CGRect keyboardBounds = [[n.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardHeight = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? keyboardBounds.size.width: keyboardBounds.size.height;
    self.keyboardY = keyboardBounds.origin.y;
    [[NSNotificationCenter defaultCenter] postNotificationName:SFKeyboardHeightDidChangeNotification object:[NSNumber numberWithInt:self.keyboardHeight]];
    [self _keyboardStateChangedWithType:type];
}

#pragma mark - notifications
- (void)_keyboardWillShow:(NSNotification *)n {
    _keyboardVisible = YES;
    [self _keyboardShowOrChanged:NO notification:n type:SFKeyboardStateTypeWillShow];
}

- (void)_keyboardWillChangeFrameNotification:(NSNotification *)n {
    [self _keyboardShowOrChanged:YES notification:n type:SFKeyboardStateTypeWillChangeFrame];
}

- (void)_keyboardDidChangeFrameNotification:(NSNotification *)note {
    self.keyboardY = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.x : [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    [self _keyboardStateChangedWithType:SFKeyboardStateTypeDidChangeFrame];
}

- (void)_keyboardDidShow:(NSNotification *)n {
    [self _keyboardStateChangedWithType:SFKeyboardStateTypeDidShow];
}

- (void)_keyboardWillHide:(NSNotification *)n {
    _keyboardVisible = NO;
    NSNumber *curveValue = n.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    self.keyboardHideAnimationCurve = curveValue.intValue << 16;
    NSNumber *durationValue = n.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    self.keyboardHideAnimationDuration = durationValue.doubleValue;
    
    self.keyboardHeight = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:SFKeyboardHeightDidChangeNotification object:[NSNumber numberWithInt:self.keyboardHeight]];
    [self _keyboardStateChangedWithType:SFKeyboardStateTypeWillHide];
}

- (void)_keyboardDidHide:(NSNotification *)n {
    [self _keyboardStateChangedWithType:SFKeyboardStateTypeDidHide];
}

@end

@implementation UIViewController (SFKeyboardStateListenerExt)

- (SFCancellable *)sf_trackKeyboardStateChange:(void(^)(SFKeyboardState *state))change {
    NSString *identifier = [NSString stringWithFormat:@"%p", change];
    
    return [self sf_trackKeyboardStateChange:change identifier:identifier];
}

- (SFCancellable *)sf_trackKeyboardStateChange:(void(^)(SFKeyboardState *state))change identifier:(NSString *)identifier {
    [[SFKeyboardStateListener sharedListener] addKeyboardHeightObserverWithIdentifier:identifier usingBlock:change];
    SFDeallocObserver *disposer = [self sf_addDeallocObserver:^{
        [[SFKeyboardStateListener sharedListener] removeKeyboardObserverWithIdentifier:identifier];
    }];
    
    __weak typeof(self) weakSelf = self;
    return [SFCancellable cancellableWithWhenCancel:^{
        [weakSelf sf_removeDeallocObserver:disposer];
        [[SFKeyboardStateListener sharedListener] removeKeyboardObserverWithIdentifier:identifier];
    }];
}

@end
