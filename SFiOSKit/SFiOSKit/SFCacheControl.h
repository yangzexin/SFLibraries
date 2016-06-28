//
//  SFCacheControl.h
//  SFiOSKit
//
//  Created by yangzexin on 2/28/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFCache;

typedef NSString *(^SFCacheControlCacheKeyBuilder)();

typedef BOOL (^SFCacheControlCacheValidator)(SFCache *cache);

typedef void(^SFCacheControlCacheFinishUpdate)(id object);

@interface SFCacheControl : NSObject

@property (nonatomic, copy) SFCacheControlCacheFinishUpdate cacheFinishUpdate;

@property (nonatomic, copy) SFCacheControlCacheKeyBuilder cacheKeyBuilder;

@property (nonatomic, copy) SFCacheControlCacheValidator cacheValidator;

// 如果遇到无效的缓存，立即清除，默认为NO
@property (nonatomic, assign) BOOL clearsInvalidCache;

// 如果缓存有效，则中断，默认为NO
@property (nonatomic, assign) BOOL interuptWhenCacheValid;

// 取消请求的回调
@property (nonatomic, copy) void(^cancelNotifier)();

+ (instancetype)cacheControl;

- (void)cancel;

@end
