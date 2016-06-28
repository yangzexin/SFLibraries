//
//  SFToast.m
//  SFiOSKit
//
//  Created by yangzexin on 11/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <SFFoundation/SFFoundation.h>

#import "SFToast.h"

#import "NSString+SFiOSAddition.h"
#import "SFKeyboardStateListener.h"

@interface SFToastView : UIView

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, assign) UIEdgeInsets textLabelEdgeInsets;
@property (nonatomic, assign) CGSize maxSize;

@end

@implementation SFToastView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.alpha = 0.72f;
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.layer.cornerRadius = 5.0f;
    _backgroundView.clipsToBounds = YES;
    [self addSubview:_backgroundView];
    
    _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.numberOfLines = 0;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLabel];
    
    return self;
}

- (void)animateShowWithCompletion:(void(^)())completion {
    self.backgroundView.alpha = 0.0f;
    self.textLabel.alpha = 0.0f;
    [UIView animateWithDuration:0.25f animations:^{
        self.backgroundView.alpha = 0.72f;
        self.textLabel.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)animateHideWithCompletion:(void(^)())completion {
    self.backgroundView.alpha = 0.72f;
    self.textLabel.alpha = 1.0f;
    [UIView animateWithDuration:0.25f animations:^{
        self.backgroundView.alpha = 0.0f;
        self.textLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)setTextLabelEdgeInsets:(UIEdgeInsets)textLabelEdgeInsets {
    _textLabelEdgeInsets = textLabelEdgeInsets;
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text {
    self.textLabel.text = text;
    CGSize size = [text sf_sizeWithFont:self.textLabel.font];
    if (size.width > self.maxSize.width) {
        size = [text sf_sizeWithFont:self.textLabel.font
                          constrainedToSize:CGSizeMake(self.maxSize.width - self.textLabelEdgeInsets.left - self.textLabelEdgeInsets.right,
                                                       self.maxSize.height - self.textLabelEdgeInsets.top - self.textLabelEdgeInsets.bottom)];
    }
    CGRect tmpRect = self.textLabel.frame;
    tmpRect.size = size;
    tmpRect.origin = CGPointMake(self.textLabelEdgeInsets.left, self.textLabelEdgeInsets.top);
    self.textLabel.frame = tmpRect;
    
    tmpRect = self.frame;
    tmpRect.size.width = self.textLabelEdgeInsets.left + self.textLabelEdgeInsets.right + self.textLabel.frame.size.width;
    tmpRect.size.height = self.textLabelEdgeInsets.top + self.textLabelEdgeInsets.bottom + self.textLabel.frame.size.height;
    self.frame = tmpRect;
}

@end

@interface SFToastManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *keyIdentifierValueView;

@end

@implementation SFToastManager

+ (id)sharedManager {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    
    _keyIdentifierValueView = [NSMutableDictionary dictionary];
    
    return self;
}

- (void)addView:(UIView *)view identifier:(NSString *)identifier {
    [self removeViewWithIdentifier:identifier];
    if (view) {
        [self.keyIdentifierValueView setObject:view forKey:identifier];
    }
}

- (void)removeViewWithIdentifier:(NSString *)identifier {
    if (identifier) {
        UIView *view = [self.keyIdentifierValueView objectForKey:identifier];
        view.hidden = YES;
        [self.keyIdentifierValueView removeObjectForKey:identifier];
    }}

@end

@implementation SFToast

+ (void)toastInView:(UIView *)view text:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier {
    [self toastInView:view text:text hideAfterSeconds:hideAfterSeconds autoPositionForKeyboard:YES identifier:identifier completion:nil];
}

+ (void)toastInView:(UIView *)view text:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier completion:(void(^)())completion {
    [self toastInView:view text:text hideAfterSeconds:hideAfterSeconds autoPositionForKeyboard:YES identifier:identifier completion:completion];
}

+ (void)toastInView:(UIView *)view text:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds autoPositionForKeyboard:(BOOL)autoPositionForKeyboard identifier:(NSString *)identifier completion:(void(^)())completion {
    if (![[SFKeyboardStateListener sharedListener] isListening]) {
        [[SFKeyboardStateListener sharedListener] startListening];
    }
    SFToastView *toastView = [[SFToastView alloc] initWithFrame:CGRectZero];
    toastView.maxSize = CGSizeMake(view.frame.size.width - 20, view.frame.size.height - 20);
    toastView.textLabelEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [toastView setText:text];
    toastView.userInteractionEnabled = NO;
    
    if (identifier) {
        [[SFToastManager sharedManager] addView:toastView identifier:identifier];
    }
    
    [view addSubview:toastView];
    
    __weak typeof(toastView) weakToastView = toastView;
    __weak typeof(view) weakView = view;
    void(^positBlock)(BOOL) = ^(BOOL animated){
        __strong typeof(weakToastView) toastView = weakToastView;
        __strong typeof(weakView) view = weakView;
        [UIView animateWithDuration:animated ? .25f : .0f animations:^{
            CGRect tmpRect = toastView.frame;
            tmpRect.origin.x = (view.frame.size.width - toastView.frame.size.width) / 2;
            CGFloat disabledHeight = autoPositionForKeyboard ? ([[SFKeyboardStateListener sharedListener] isKeyboardVisible] ? [[SFKeyboardStateListener sharedListener] keyboardHeight] : 0) : 0;
            tmpRect.origin.y = (view.frame.size.height - toastView.frame.size.height - disabledHeight) / 2;
            toastView.frame = tmpRect;
        }];
    };
    positBlock(NO);
    
    if (autoPositionForKeyboard) {
        NSString *identifier = [NSString stringWithFormat:@"%p", toastView];
        [[SFKeyboardStateListener sharedListener] addKeyboardHeightObserverWithIdentifier:identifier usingBlock:^(SFKeyboardState *state) {
            positBlock(YES);
        }];
        [toastView sf_addDeallocObserver:^{
            [[SFKeyboardStateListener sharedListener] removeKeyboardObserverWithIdentifier:identifier];
        }];
    }
    
    [toastView animateShowWithCompletion:^{
        double delayInSeconds = hideAfterSeconds;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [toastView animateHideWithCompletion:^{
                [toastView removeFromSuperview];
                if (completion) {
                    completion();
                }
            }];
        });
    }];
}

+ (void)hideToastInView:(UIView *)view identifier:(NSString *)identifier {
    [[SFToastManager sharedManager] removeViewWithIdentifier:identifier];
}

+ (void)toastWithText:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier {
    [self toastWithText:text hideAfterSeconds:hideAfterSeconds identifier:identifier completion:nil];
}

+ (void)toastWithText:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier completion:(void(^)())completion {
    [self toastInView:[[UIApplication sharedApplication] keyWindow] text:text hideAfterSeconds:hideAfterSeconds autoPositionForKeyboard:YES identifier:identifier completion:completion];
}

+ (void)dismissWithIdentifier:(NSString *)identifier {
    [[SFToastManager sharedManager] removeViewWithIdentifier:identifier];
}

@end
