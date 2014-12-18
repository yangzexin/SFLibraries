//
//  SFResourceDisposer.h
//  SFFoundation
//
//  Created by yangzexin on 5/24/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFResourceDisposer : NSObject

+ (instancetype)resourceDisposerWithBlock:(void(^)())block;

- (void)cancel;

@end
