//
//  SFPropertyObserving.h
//  SFFoundation
//
//  Created by yangzexin on 5/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFPropertyObserving : NSObject

@property (nonatomic, copy, readonly) void(^changeBlock)(id);

@property (nonatomic, copy) void(^observeStarted)(void);
@property (nonatomic, copy) void(^cancelHandler)(void);

- (instancetype)change:(void(^)(id value))change;
- (void)cancel;

@end
