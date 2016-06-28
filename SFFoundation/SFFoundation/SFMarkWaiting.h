//
//  SFMarkWaiting.h
//  SFFoundation
//
//  Created by yangzexin on 9/22/13.
//  Copyright (c) 2013 __MyCompany__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFWaiting.h"

@interface SFMarkWaiting : SFWaiting

+ (instancetype)markWaiting;

- (void)markAsFinish;
- (void)resetMark;
- (BOOL)isMarked;

@end
