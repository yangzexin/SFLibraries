//
//  SFRepeatTimer.h
//  SFFoundation
//
//  Created by yangzexin on 10/18/13.
//  Copyright (c) 2013 __MyCompany__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDepositable.h"

@interface SFRepeatTimer : NSObject <SFDepositable>

@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, copy) void(^tick)();

- (id)initWithTimeInterval:(NSTimeInterval)timeInterval tick:(void(^)())tick;
- (void)start;
- (void)stop;

+ (instancetype)timerStartWithTimeInterval:(NSTimeInterval)timeInterval tick:(void(^)())tick;

@end
