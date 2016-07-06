//
//  SFBlockedBarButtonItem.m
//  SFiOSKit
//
//  Created by yangzexin on 13-7-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "SFBlockedBarButtonItem.h"

@interface SFBlockedBarButtonItem ()

@property (nonatomic, copy) void(^tap)();
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

- (id)initWithCustomView:(UIView *)customView tap:(void(^)())tap {
    self = [super initWithCustomView:customView];

    if (tap) {
        self.customViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customViewTapGestureRecognizer:)];
        [customView addGestureRecognizer:self.customViewTapGestureRecognizer];
    }
    self.tap = tap;
    
    return self;
}

- (void)tapped {
    if (self.tap) {
        self.tap();
    }
}

- (void)customViewTapGestureRecognizer:(UITapGestureRecognizer *)gr {
    [self tapped];
}

+ (instancetype)blockedBarButtonItemWithTitle:(NSString *)title tap:(void (^)())tap {
    SFBlockedBarButtonItem *tmp = [[SFBlockedBarButtonItem alloc] initWithTitle:title];
    tmp.tap = tap;
    
    return tmp;
}

+ (instancetype)blockedBarButtonItemWithImage:(UIImage *)image tap:(void (^)())tap {
    SFBlockedBarButtonItem *tmp = [[SFBlockedBarButtonItem alloc] initWithImage:image];
    tmp.tap = tap;
    
    return tmp;
}

+ (instancetype)blockedBarButtonItemWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem tap:(void (^)())tap {
    SFBlockedBarButtonItem *tmp = [[SFBlockedBarButtonItem alloc] initWithBarButtonSystemItem:systemItem];
    tmp.tap = tap;
    
    return tmp;
}

+ (instancetype)blockedBarButtonItemWithCustomView:(UIView *)customView {
    return [[self class] blockedBarButtonItemWithCustomView:customView tap:nil];
}

+ (instancetype)blockedBarButtonItemWithCustomView:(UIView *)customView tap:(void (^)())tap {
    SFBlockedBarButtonItem *item = [[SFBlockedBarButtonItem alloc] initWithCustomView:customView tap:tap];
    
    return item;
}

@end
