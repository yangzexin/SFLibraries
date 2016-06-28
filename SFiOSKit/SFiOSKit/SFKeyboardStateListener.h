//
//  SFKeyboardStateListener.h
//  SFiOSKit
//
//  Created by yangzexin on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SFFoundation/SFFoundation.h>

OBJC_EXPORT NSString *const SFKeyboardHeightDidChangeNotification;

@class SFKeyboardState;

@interface SFKeyboardStateListener : NSObject

@property (nonatomic, readonly, getter=isListening) BOOL listening;
@property (nonatomic, readonly, getter=isKeyboardVisible) BOOL keyboardVisible;
@property (nonatomic, readonly) CGFloat keyboardHeight;
@property (nonatomic, readonly) CGFloat keyboardY;

@property (nonatomic, readonly) NSTimeInterval keyboardShowAnimationDuration;
@property (nonatomic, readonly) NSTimeInterval keyboardHideAnimationDuration;
@property (nonatomic, readonly) UIViewAnimationOptions keyboardShowAnimationCurve;
@property (nonatomic, readonly) UIViewAnimationOptions keyboardHideAnimationCurve;

+ (SFKeyboardStateListener *)sharedListener;

- (void)startListening;
- (void)stopListening;

- (void)addKeyboardHeightObserverWithIdentifier:(NSString *)identifier usingBlock:(void(^)(SFKeyboardState *state))usingBlock;
- (void)removeKeyboardObserverWithIdentifier:(NSString *)identifier;

@end

typedef NS_ENUM(NSUInteger, SFKeyboardStateType){
    SFKeyboardStateTypeWillShow,
    SFKeyboardStateTypeDidShow,
    SFKeyboardStateTypeWillHide,
    SFKeyboardStateTypeDidHide,
    SFKeyboardStateTypeWillChangeFrame,
    SFKeyboardStateTypeDidChangeFrame
};

@interface SFKeyboardState : NSObject

@property (nonatomic, assign, readonly) SFKeyboardStateType type;
@property (nonatomic, assign, readonly) BOOL visible;
@property (nonatomic, assign, readonly) CGFloat height;
@property (nonatomic, assign, readonly) NSTimeInterval animationDuration;
@property (nonatomic, assign, readonly) UIViewAnimationOptions animationCurve;

@end

@interface UIViewController (SFKeyboardStateListenerExt)

- (SFCancellable *)sf_trackKeyboardStateChange:(void(^)(SFKeyboardState *state))change;
- (SFCancellable *)sf_trackKeyboardStateChange:(void(^)(SFKeyboardState *state))change identifier:(NSString *)identifier;

@end