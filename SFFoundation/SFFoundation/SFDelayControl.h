//
//  SFDelayControl.h
//  SFFoundation
//
//  Created by yangzexin on 12-11-28.
//  Copyright (c) 2012年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDepositable.h"

@interface SFDelayControl : NSObject <SFDepositable>

- (instancetype)initWithInterval:(NSTimeInterval)timeInterval completion:(void(^)())completion;
- (instancetype)start;
- (void)cancel;

+ (instancetype)delayWithInterval:(NSTimeInterval)timeInterval completion:(void(^)())completion;

@end
