//
//  SFPropertyObserveContext.h
//  SFFoundation
//
//  Created by yangzexin on 5/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDepositable.h"

@interface SFPropertyObserveContext : NSObject <SFDepositable>

- (void)startObserve;
- (void)cancelObserve;

- (id)initWithTarget:(id)target propertyName:(NSString *)propertyName options:(NSKeyValueObservingOptions)options usingBlock:(void(^)(id value))usingBlock;

@end
