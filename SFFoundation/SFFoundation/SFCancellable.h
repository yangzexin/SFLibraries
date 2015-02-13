//
//  SFEvetCancellable.h
//  SFFoundation
//
//  Created by yangzexin on 5/24/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFObjectRepository.h"

@interface SFCancellable : NSObject <SFRepositionSupportedObject>

+ (instancetype)cancellableWithWhenCancel:(void(^)())block;

- (void)cancel;

@end
