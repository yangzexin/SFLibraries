//
//  SFDeallocObserver.h
//  SFFoundation
//
//  Created by yangzexin on 5/24/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDepositable.h"

@interface SFDeallocObserver : NSObject <SFDepositable>

- (void)cancel;

@end
