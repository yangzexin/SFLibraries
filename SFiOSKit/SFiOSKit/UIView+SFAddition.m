//
//  UIView+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 13-7-31.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "UIView+SFAddition.h"

#import <QuartzCore/QuartzCore.h>
#import <SFFoundation/SFFoundation.h>

@interface SFTapGestureRecognizer : UITapGestureRecognizer

@property (nonatomic, copy) void(^tapHandler)();

@end

@implementation SFTapGestureRecognizer

- (id)initWithTapHandler:(void(^)())tapHandler {
    self = [self initWithTarget:self action:@selector(_tapped:)];
    
    self.tapHandler = tapHandler;
    
    return self;
}

- (void)_tapped:(id)gr {
    if (_tapHandler) {
        _tapHandler();
    }
}

@end

@implementation UIView (SFAddition)

- (UIImage *)sf_toImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, [UIScreen mainScreen].scale);
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0f) {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    } else {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage *)sf_toImageLegacy {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, [UIScreen mainScreen].scale);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)sf_fitToShowAllSubviews {
    [self sf_fitToShowAllSubviewsWithPadding:CGSizeZero];
}

- (void)sf_fitToShowAllSubviewsWithPadding:(CGSize)padding {
    CGFloat originalWidth = self.frame.size.width;
    
    CGFloat maxWidth = 0;
    CGFloat maxHeight = 0;
    for(UIView *view in [self subviews]){
        if (!view.hidden) {
            if(view.frame.origin.x + view.frame.size.width > maxWidth){
                maxWidth = view.frame.origin.x + view.frame.size.width;
            }
            if(view.frame.origin.y + view.frame.size.height > maxHeight){
                maxHeight = view.frame.origin.y + view.frame.size.height;
            }
        }
    }
    if (maxWidth != 0 && maxHeight != 0) {
        CGRect tmpRect = self.frame;
        tmpRect.size = CGSizeMake(maxWidth < originalWidth ? originalWidth : maxWidth + padding.width, maxHeight + padding.height);
        self.frame = tmpRect;
    }
}

- (void)sf_removeAllSubviews {
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
}

- (UIViewController *)sf_viewController {
    UIView *view = self;
    UIViewController *vc = (UIViewController *)view.nextResponder;
    
    while (vc != nil && ![vc isKindOfClass:[UIViewController class]]) {
        vc = (UIViewController *)vc.nextResponder;
    }
    
    return vc;
}

- (CGFloat)sf_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)sf_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)sf_width {
    return self.frame.size.width;
}

- (CGFloat)sf_height {
    return self.frame.size.height;
}

- (void)sf_setX:(CGFloat)x {
    CGRect tmpFrame = self.frame;
    tmpFrame.origin.x = x;
    self.frame = tmpFrame;
}

- (void)sf_setY:(CGFloat)y {
    CGRect tmpFrame = self.frame;
    tmpFrame.origin.y = y;
    self.frame = tmpFrame;
}

- (void)sf_setWidth:(CGFloat)width {
    CGRect tmpFrame = self.frame;
    tmpFrame.size.width = width;
    self.frame = tmpFrame;
}

- (void)sf_setHeight:(CGFloat)height {
    CGRect tmpFrame = self.frame;
    tmpFrame.size.height = height;
    self.frame = tmpFrame;
}

- (void)sf_setX:(CGFloat)x y:(CGFloat)y {
    CGRect tmpFrame = self.frame;
    tmpFrame.origin.x = x;
    tmpFrame.origin.y = y;
    self.frame = tmpFrame;
}

- (void)sf_setWidth:(CGFloat)width height:(CGFloat)height {
    CGRect tmpFrame = self.frame;
    tmpFrame.size.width = width;
    tmpFrame.size.height = height;
    self.frame = tmpFrame;
}

@end

@implementation UIView (SFTapSupport)

- (void)sf_addTapListener:(void(^)())tapListener {
    [self sf_addTapListener:tapListener identifier:nil];
}

- (void)sf_addTapListener:(void(^)())tapListener identifier:(NSString *)identifier {
    NSMutableDictionary *keyIdentifierValueTapListener = [self sf_associatedObjectWithKey:@"sf_keyIdentifierValueTapListener"];
    if (keyIdentifierValueTapListener == nil) {
        keyIdentifierValueTapListener = [NSMutableDictionary dictionary];
        [self sf_setAssociatedObject:keyIdentifierValueTapListener key:@"sf_keyIdentifierValueTapListener"];
    }
    if (identifier == nil) {
        identifier = [NSString stringWithFormat:@"%f%ld", [NSDate timeIntervalSinceReferenceDate], (long)tapListener];
    }
    [keyIdentifierValueTapListener setObject:[NSValue sf_valueWithBlock:tapListener] forKey:identifier];
    
    if (self.userInteractionEnabled == NO) {
        self.userInteractionEnabled = YES;
    }
    
    SFTapGestureRecognizer *gr = [self sf_associatedObjectWithKey:@"sf_tap_gesture_recognizer"];
    if (gr == nil) {
        gr = [[SFTapGestureRecognizer alloc] initWithTapHandler:^{
            for (NSValue *blockValue in [keyIdentifierValueTapListener allValues]) {
                void(^tmpTapListener)() = [blockValue sf_block];
                tmpTapListener();
            }
        }];
        [self sf_setAssociatedObject:gr key:@"sf_tap_gesture_recognizer"];
        [self addGestureRecognizer:gr];
    }
}

- (void)sf_removeTapListenerWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *keyIdentifierValueTapListener = [self sf_associatedObjectWithKey:@"sf_keyIdentifierValueTapListener"];
    [keyIdentifierValueTapListener removeObjectForKey:identifier];
    if (keyIdentifierValueTapListener.count == 0) {
        SFTapGestureRecognizer *gr = [self sf_associatedObjectWithKey:@"sf_tap_gesture_recognizer"];
        if (gr) {
            [self removeGestureRecognizer:gr];
            [self sf_removeAssociatedObjectWithKey:@"sf_tap_gesture_recognizer"];
        }
    }
}

@end

@implementation UIView (SFXibSupport)

- (UIView *)sf_loadFromXibName:(NSString *)xibName {
    return [self sf_loadFromXibName:xibName owner:nil];
}

- (UIView *)sf_loadFromXibName:(NSString *)xibName bundle:(NSBundle *)bundle {
    return [self sf_loadFromXibName:xibName owner:nil bundle:bundle];
}

- (UIView *)sf_loadFromXibName:(NSString *)xibName owner:(id)owner {
    return [self sf_loadFromXibName:xibName owner:owner bundle:[NSBundle mainBundle]];
}

- (UIView *)sf_loadFromXibName:(NSString *)xibName owner:(id)owner bundle:(NSBundle *)bundle {
    UIView *view = [[bundle loadNibNamed:xibName owner:owner == nil ? self : owner options:nil] lastObject];
    
    if ([self isKindOfClass:[UITableViewCell class]]) {
        view.frame = [(id)self contentView].bounds;
        [[(id)self contentView] addSubview:view];
    } else {
        view.frame = self.bounds;
        [self addSubview:view];
    }
    
    [self sf_setAssociatedObject:[NSValue sf_valueWithWeakObject:view] key:@"__xib_view"];
    
    return view;
}

- (UIView *)sf_xibView {
    return [[self sf_associatedObjectWithKey:@"__xib_view"] sf_weakObject];
}

@end

@implementation UIView (SFSeparator)

- (SFLineView *)sf_addLeftLineWithColor:(UIColor *)color {
    SFLineView *line = [[SFLineView alloc] initWithFrame:CGRectMake(0, 0, 1, self.frame.size.height)];
    line.color = color;
    line.vertical = YES;
    line.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addSubview:line];
    
    return line;
}

- (SFLineView *)sf_addRightLineWithColor:(UIColor *)color {
    SFLineView *line = [[SFLineView alloc] initWithFrame:CGRectMake(self.frame.size.width - 1, 0, 1, self.frame.size.height)];
    line.color = color;
    line.vertical = YES;
    line.alignment = SFLineViewAlignmentBottom;
    line.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:line];
    
    return line;
}

- (SFLineView *)sf_addTopLineWithColor:(UIColor *)color {
    SFLineView *line = [[SFLineView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    line.color = color;
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:line];
    
    return line;
}

- (SFLineView *)sf_addBottomLineWithColor:(UIColor *)color {
    SFLineView *line = [[SFLineView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    line.color = color;
    line.alignment = SFLineViewAlignmentBottom;
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:line];
    
    return line;
}

@end

@implementation UIView (SFSmallWaiting)

- (CGFloat)sf_smallWaitingAlpha {
    NSNumber *alpha = [self sf_associatedObjectWithKey:@"sf_smallWaitingAlpha"];
    if (alpha == nil) {
        alpha = @(.72f);
        [self sf_setSmallWaitingAlpha:[alpha floatValue]];
    }
    
    return [alpha floatValue];
}

- (void)sf_setSmallWaitingAlpha:(CGFloat)alpha {
    [self sf_setAssociatedObject:@(alpha) key:@"sf_smallWaitingAlpha"];
}

- (void)sf_setSmallWaiting:(BOOL)waiting {
    UIActivityIndicatorView *indicatorView = [self sf_associatedObjectWithKey:@"sf_smallWaitingIndicator"];
    if (indicatorView == nil) {
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:[self sf_smallWaitingAlpha]];
        [self addSubview:view];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:view.bounds];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        indicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:indicatorView];
        [self sf_setAssociatedObject:indicatorView key:@"sf_smallWaitingIndicator"];
    }
    indicatorView.superview.hidden = !waiting;
    if (waiting) {
        [self bringSubviewToFront:indicatorView.superview];
        [indicatorView startAnimating];
    } else {
        [indicatorView stopAnimating];
    }
}

@end
