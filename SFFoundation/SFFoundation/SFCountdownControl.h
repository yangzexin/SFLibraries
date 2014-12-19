//
//  SFCountdownControl.h
//  SFFoundation
//
//  Created by yangzexin on 12/23/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFObjectRepository.h"

@interface SFCountdownControl : NSObject <SFRepositionSupportedObject>

@property (nonatomic, assign) NSTimeInterval deltaTimeInterval;

- (void)startCountdownWithTimeInterval:(NSTimeInterval)timeInterval countBlock:(void(^)(NSTimeInterval countdown))countBlock completion:(void(^)())completion;
- (void)stop;

@end