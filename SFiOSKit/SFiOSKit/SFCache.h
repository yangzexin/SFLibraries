//
//  SFCache.h
//  SFiOSKit
//
//  Created by yangzexin on 6/9/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXPORT NSString *SFCurrentApplicationIdentifier();

@interface SFCache : NSObject <NSCoding>

// 缓存上次更新时间
@property (nonatomic, assign, readonly) NSTimeInterval time;

// 可以通过此属性来判断是否本次程序生命周期内生成的缓存
@property (nonatomic, copy, readonly) NSString *applicationIdentifier;

@property (nonatomic, strong, readonly) NSData *data;

+ (instancetype)cacheWithData:(NSData *)data;

@end
