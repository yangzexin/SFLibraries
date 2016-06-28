//
//  UIDatePicker+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 5/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "UIDatePicker+SFAddition.h"

#import "SFBlockedButton.h"
#import "UIColor+SFAddition.h"
#import "SFiOSKitConstants.h"
#import "UIView+SFAddition.h"
#import "SFBlockedBarButtonItem.h"

@interface SFDatePickerDialogOptions ()

@property (nonatomic, copy) NSString *_title;
@property (nonatomic, strong) NSDate *_date;
@property (nonatomic, strong) NSDate *_miniumDate;
@property (nonatomic, strong) NSDate *_maximumDate;
@property (nonatomic, assign) UIDatePickerMode _mode;

@end

@implementation SFDatePickerDialogOptions

+ (instancetype)dialogOptionsWithTitle:(NSString *)title {
    SFDatePickerDialogOptions *options = [SFDatePickerDialogOptions new];
    options._title = title;
    
    return options;
}

- (instancetype)setTitle:(NSString *)title {
    self._title = title;
    
    return self;
}

- (instancetype)setDate:(NSDate *)date {
    self._date = date;
    
    return self;
}

- (instancetype)setMiniumDate:(NSDate *)miniumDate {
    self._miniumDate = miniumDate;
    
    return self;
}

- (instancetype)setMaximumDate:(NSDate *)maximumDate {
    self._maximumDate = maximumDate;
    
    return self;
}

- (instancetype)setMode:(UIDatePickerMode)mode {
    self._mode = mode;
    
    return self;
}

@end

@implementation UIDatePicker (SFAddition)

+ (void)sf_pickInViewController:(UIViewController *)viewController options:(SFDatePickerDialogOptions *)options completion:(void(^)(NSDate *selecteDate, BOOL cancelled))completion {
    UIView *container = [[UIView alloc] initWithFrame:viewController.view.bounds];
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [viewController.view addSubview:container];
    
    SFBlockedButton *backgroundView = [[SFBlockedButton alloc] initWithFrame:container.bounds];
    backgroundView.backgroundColor = [UIColor sf_colorWithRed:0 green:0 blue:0 alpha:50];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [container addSubview:backgroundView];
    
    const CGFloat datePickerHeight = 216;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, container.frame.size.height - datePickerHeight, container.frame.size.width, datePickerHeight)];
    datePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    if (options._date) {
        datePicker.date = options._date;
    }
    if (options._miniumDate) {
        datePicker.minimumDate = options._miniumDate;
    }
    if (options._maximumDate) {
        datePicker.maximumDate = options._maximumDate;
    }
    if (SFDeviceSystemVersion >= 7.0f) {
        datePicker.backgroundColor = [UIColor whiteColor];
    }
    datePicker.datePickerMode = options._mode;
    [container addSubview:datePicker];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, container.frame.size.height - datePickerHeight - 44, container.frame.size.width, 44)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [container addSubview:toolbar];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:toolbar.bounds];
    if (SFDeviceSystemVersion < 7.0f) {
        titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
        titleLabel.shadowColor = [UIColor darkGrayColor];
        titleLabel.textColor = [UIColor whiteColor];
    } else {
        titleLabel.textColor = [UIColor darkGrayColor];
    }
    titleLabel.text = options._title;
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.userInteractionEnabled = NO;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [toolbar addSubview:titleLabel];
    
    __weak typeof(container) weakContainer = container;
    __weak typeof(datePicker) weakDatePicker = datePicker;
    __weak typeof(backgroundView) weakBackgroundView = backgroundView;
    __weak typeof(toolbar) weakToolbar = toolbar;
    void(^closeAnimation)() = ^{
        __strong typeof(weakContainer) strongContainer = weakContainer;
        __strong typeof(weakToolbar) strongToolbar = weakToolbar;
        __strong typeof(weakDatePicker) strongDatePicker = weakDatePicker;
        __strong typeof(weakBackgroundView) strongBackgroundView = weakBackgroundView;
        
        CGRect rect = strongToolbar.frame;
        rect.origin.y = strongContainer.frame.size.height;
        strongToolbar.frame = rect;
        
        rect = strongDatePicker.frame;
        rect.origin.y = [strongToolbar sf_bottom];
        strongDatePicker.frame = rect;
        
        strongBackgroundView.backgroundColor = [UIColor sf_colorWithRed:0 green:0 blue:0 alpha:0];
    };
    
    [backgroundView setTapHandler:^{
        [UIView animateWithDuration:0.25f animations:closeAnimation completion:^(BOOL finished) {
            if (completion) {
                completion(nil, YES);
            }
            [weakContainer removeFromSuperview];
        }];
    }];
    
    toolbar.items = @[[SFBlockedBarButtonItem blockedBarButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace eventHandler:nil], [SFBlockedBarButtonItem blockedBarButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemDone eventHandler:^{
        [UIView animateWithDuration:0.25f animations:closeAnimation completion:^(BOOL finished) {
            if (completion) {
                completion(weakDatePicker.date, NO);
            }
            [weakContainer removeFromSuperview];
        }];
    }]];
    
    CGRect originalToolbarFrame = toolbar.frame;
    CGRect originalDatePickerFrame = datePicker.frame;
    UIColor *originalBackgroundColor = backgroundView.backgroundColor;
    
    closeAnimation();
    
    [UIView animateWithDuration:0.25f animations:^{
        toolbar.frame = originalToolbarFrame;
        datePicker.frame = originalDatePickerFrame;
        backgroundView.backgroundColor = originalBackgroundColor;
    }];
}

@end
