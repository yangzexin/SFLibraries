//
//  SFPropertyObserveContext.m
//  SFFoundation
//
//  Created by yangzexin on 5/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFPropertyObserveContext.h"

@interface SFPropertyObserveContext ()

@property (nonatomic, assign) id target;
@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, assign) NSKeyValueObservingOptions options;
@property (nonatomic, copy) void(^usingBlock)(id value);
@property (nonatomic, assign) BOOL observing;
@property (nonatomic, assign) BOOL cancelled;

@end

@implementation SFPropertyObserveContext

- (void)dealloc {
    if (_observing) {
        [self cancelObserve];
    }
}

- (id)initWithTarget:(id)target propertyName:(NSString *)propertyName options:(NSKeyValueObservingOptions)options usingBlock:(void(^)(id value))usingBlock {
    self = [super init];
    
    self.target = target;
    self.propertyName = propertyName;
    self.options = options;
    self.usingBlock = usingBlock;
    self.observing = NO;
    self.cancelled = NO;
    
    return self;
}

- (void)startObserve {
    if (!_observing) {
        self.observing = YES;
        [_target addObserver:self forKeyPath:_propertyName options:_options context:NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id value = [change objectForKey:NSKeyValueChangeNewKey];
    _usingBlock(value == [NSNull null] ? nil : value);
}

- (void)cancelObserve {
    if (_observing) {
        self.cancelled = YES;
        
        [_target removeObserver:self forKeyPath:_propertyName];
        self.target = nil;
        self.usingBlock = nil;
        
        self.observing = NO;
    }
}

- (BOOL)shouldRemoveDepositable {
    return _cancelled && !_observing;
}

- (void)depositableWillRemove {
    [self cancelObserve];
}

@end
