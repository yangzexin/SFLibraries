//
//  SFDeallocObserver+Private.h
//  SFFoundation
//
//  Created by yangzexin on 5/23/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "SFDeallocObserver.h"

@interface SFDeallocObserver ()

@property (nonatomic, copy) void(^trigger)();

@property (nonatomic, copy) void(^whenCancelled)();

+ (instancetype)observerWthTrigger:(void(^)())trigger;

@end
