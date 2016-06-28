//
//  SFBlockedBarButtonItem.m
//  SFiOSKit
//
//  Created by yangzexin on 13-7-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "SFBlockedBarButtonItem.h"

@interface SFBlockedBarButtonItem ()

@property (nonatomic, copy) void(^eventHandler)();
@property (nonatomic, strong) UITapGestureRecognizer *customViewTapGestureRecognizer;

@end

@implementation SFBlockedBarButtonItem

- (void)dealloc {
    if (self.customView && _customViewTapGestureRecognizer) {
        [self.customView removeGestureRecognizer:_customViewTapGestureRecognizer];
    }
}

- (void)initialize {
    self.target = self;
    self.action = @selector(tapped);
}

- (id)initWithTitle:(NSString *)title {
    self = [super initWithTitle:title style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    [self initialize];
    
    return self;
}

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem {
    self = [super initWithBarButtonSystemItem:systemItem target:nil action:nil];
    
    [self initialize];
    
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self initialize];
    
    return self;
}

- (id)initWithCustomView:(UIView *)customView eventHandler:(void(^)())eventHandler {
    self = [super initWithCustomView:customView];

    if (eventHandler) {
        self.customViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customViewTapGestureRecognizer:)];
        [customView addGestureRecognizer:self.customViewTapGestureRecognizer];
    }
    self.eventHandler = eventHandler;
    
    return self;
}

- (void)tapped {
    if (self.eventHandler) {
        self.eventHandler();
    }
}

- (void)customViewTapGestureRecognizer:(UITapGestureRecognizer *)gr {
    [self tapped];
}

+ (id)blockedBarButtonItemWithTitle:(NSString *)title eventHandler:(void (^)())eventHandler {
    SFBlockedBarButtonItem *tmp = [[SFBlockedBarButtonItem alloc] initWithTitle:title];
    tmp.eventHandler = eventHandler;
    
    return tmp;
}

+ (id)blockedBarButtonItemWithImage:(UIImage *)image eventHandler:(void (^)())eventHandler {
    SFBlockedBarButtonItem *tmp = [[SFBlockedBarButtonItem alloc] initWithImage:image];
    tmp.eventHandler = eventHandler;
    
    return tmp;
}

+ (id)blockedBarButtonItemWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem eventHandler:(void (^)())eventHandler {
    SFBlockedBarButtonItem *tmp = [[SFBlockedBarButtonItem alloc] initWithBarButtonSystemItem:systemItem];
    tmp.eventHandler = eventHandler;
    
    return tmp;
}

+ (id)blockedBarButtonItemWithCustomView:(UIView *)customView {
    return [[self class] blockedBarButtonItemWithCustomView:customView eventHandler:nil];
}

+ (id)blockedBarButtonItemWithCustomView:(UIView *)customView eventHandler:(void (^)())eventHandler {
    SFBlockedBarButtonItem *item = [[SFBlockedBarButtonItem alloc] initWithCustomView:customView eventHandler:eventHandler];
    
    return item;
}

@end
