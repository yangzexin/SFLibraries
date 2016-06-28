//
//  SFCancellable.h
//  SFFoundation
//
//  Created by yangzexin on 5/24/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDepositable.h"

@interface SFCancellable : NSObject <SFDepositable>

+ (instancetype)cancellableWithWhenCancel:(void(^)())block;

- (void)cancel;

@end
