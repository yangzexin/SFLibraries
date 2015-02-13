//
//  DelayControl.h
// 
//
//  Created by yangzexin on 12-11-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFObjectRepository.h"

@interface SFDelayControl : NSObject <SFRepositionSupportedObject>

- (instancetype)initWithInterval:(NSTimeInterval)timeInterval completion:(void(^)())completion;
- (instancetype)start;
- (void)cancel;

+ (instancetype)delayWithInterval:(NSTimeInterval)timeInterval completion:(void(^)())completion;

@end
