//
//  SFCombinationEnd.m
//  SFFoundation
//
//  Created by yangzexin on 8/5/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFCombinationEnd.h"

@implementation SFCombinationEnd

+ (instancetype)end {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    
    return instance;
}

@end
