//
//  SFWaiting.h
//  SFFoundation
//
//  Created by yangzexin on 8/27/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

/**
 循环检查condition，如果condition通过，则会调用所有注册了等待condition通过的block。
 如果wait方法提供了identifier，会根据该identifier替换已经注册的wait block操作
 */

#import <Foundation/Foundation.h>
#import "SFDepositable.h"

@interface SFWaiting : NSObject <SFDepositable>

@property (nonatomic, copy) NSString *name;

+ (instancetype)waitWithCondition:(BOOL(^)())condition;

- (NSString *)generateRandomUniqueIdentifier;

- (void)wait:(void(^)())block;
- (void)wait:(void(^)())block uniqueIdentifier:(NSString *)identifier;
- (void)cancelByUniqueIdentifier:(NSString *)identifier;
- (void)cancelAll;

@end
