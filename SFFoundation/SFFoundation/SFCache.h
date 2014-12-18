//
//  SFCache.h
//  SFFoundation
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

typedef NSString *(^SFCacheControlCacheKeyBuilder)();

typedef BOOL (^SFCacheControlCacheValidator)(SFCache *cache);

typedef void(^SFCacheControlCacheFinishUpdate)(id object);

@interface SFCacheControl : NSObject

@property (nonatomic, copy) SFCacheControlCacheFinishUpdate cacheFinishUpdate;

@property (nonatomic, copy) SFCacheControlCacheKeyBuilder cacheKeyBuilder;

@property (nonatomic, copy) SFCacheControlCacheValidator cacheValidator;

// 如果遇到无效的缓存，立即清除，默认为NO
@property (nonatomic, assign) BOOL clearsInvalidCache;

// 如果缓存有效，则不向服务器请求数据，默认为NO
@property (nonatomic, assign) BOOL interuptWhenCacheValid;

// 取消请求的回调
@property (nonatomic, copy) void(^cancelNotifier)();

+ (instancetype)cacheControl;

- (void)cancel;

@end
