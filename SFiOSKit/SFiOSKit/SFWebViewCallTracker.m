//
//  SFWebViewCallTracker.m
//  SFiOSKit
//
//  Created by yangzexin on 3/17/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "SFWebViewCallTracker.h"

#define SFWebViewProtocolCallbackMethodKey  @"_callback_func"
#define SFWebViewProtocolUserDataKey        @"_user_data"

@interface SFWebViewProtocolObserverContext : NSObject

@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) void(^handler)(NSString *method, NSDictionary *parameters, SFWebViewProtocolNotifier notifier);

@end

@implementation SFWebViewProtocolObserverContext

@end

@interface SFWebViewProtocolObserver ()

@property (nonatomic, copy) NSString *protocol;

@property (nonatomic, assign, getter=isConnected) BOOL connected;

@property (nonatomic, strong) NSMutableArray *contexts;

@end

@implementation SFWebViewProtocolObserver

- (id)init {
    self = [super init];
    
    self.contexts = [NSMutableArray array];
    
    return self;
}

- (void)disconnect {
    self.connected = NO;
}

- (void)connect {
    self.connected = YES;
}

- (SFCancellable *)observeMethod:(NSString *)method handler:(void(^)(NSString *method, NSDictionary *parameters, SFWebViewProtocolNotifier notifier))handler {
    SFWebViewProtocolObserverContext *context = [SFWebViewProtocolObserverContext new];
    context.method = method;
    context.handler = handler;
    
    [self.contexts addObject:context];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(context) weakContext = context;
    return [SFCancellable cancellableWithWhenCancel:^{
        __strong typeof(weakSelf) self = weakSelf;
        __strong typeof(weakContext) context = weakContext;
        [self.contexts removeObject:context];
    }];
}

- (BOOL)processURL:(NSURL *)url javascriptExecutor:(SFWebViewJavascriptExecutor)javascriptExecutor {
    NSString *query = [url query];
    
    NSString *resourceSpecifier = url.resourceSpecifier;
    NSString *method = [url.resourceSpecifier substringWithRange:NSMakeRange(2, resourceSpecifier.length - query.length - 3)];
    
    BOOL processed = NO;
    for (SFWebViewProtocolObserverContext *context in self.contexts) {
        if ([context.method isEqualToString:method]) {
            processed = YES;
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            
            NSArray *keyValues = [query componentsSeparatedByString:@"&"];
            for (NSString *keyValue in keyValues) {
                NSArray *arr = [keyValue componentsSeparatedByString:@"="];
                if (arr.count == 2) {
                    NSString *key = [[arr objectAtIndex:0] stringByRemovingPercentEncoding];
                    NSString *value = [[arr objectAtIndex:1] stringByRemovingPercentEncoding];
                    if (key != nil) {
                        [params setObject:value != nil ? value : @"" forKey:key];
                    }
                }
            }
            
            NSString *callbackFuncName = [params objectForKey:SFWebViewProtocolCallbackMethodKey];
            NSString *userData = [params objectForKey:SFWebViewProtocolUserDataKey];
            if (callbackFuncName != nil) {
                [params removeObjectForKey:SFWebViewProtocolCallbackMethodKey];
            }
            if (userData != nil) {
                [params removeObjectForKey:SFWebViewProtocolUserDataKey];
            }
            
            if (userData != nil) {
                NSString *userDataParamValue = [NSString stringWithFormat:@"\"%@\"", _SFCommonCallbackValueFilter(userData)];
                
                context.handler(method, [params copy], ^(NSString *result){
                    javascriptExecutor([NSString stringWithFormat:@"%@(%@, \"%@\");", callbackFuncName, userDataParamValue, _SFCommonCallbackValueFilter(result)]);
                });
            } else {
                context.handler(method, [params copy], ^(NSString *result){
                    javascriptExecutor([NSString stringWithFormat:@"%@(\"%@\");", callbackFuncName, _SFCommonCallbackValueFilter(result)]);
                });
            }
            
            break;
        }
    }
    
    return processed;
}

NSString *_SFCommonCallbackValueFilter(NSString *value) {
    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    return value;
}

@end

@interface SFWebViewCallTracker ()

@property (nonatomic, strong) NSMutableArray *observers;

@end

@implementation SFWebViewCallTracker

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    
    self.observers = [NSMutableArray array];
    
    return self;
}

- (BOOL)isURLTrackable:(NSURL *)url javascriptExecutor:(SFWebViewJavascriptExecutor)javascriptExecutor {
    NSString *scheme = [[url scheme] lowercaseString];
    
    BOOL processed = NO;
    
    for (SFWebViewProtocolObserver *observer in self.observers) {
        if ([observer isConnected] && [observer.protocol isEqualToString:scheme]) {
            processed = [observer processURL:url javascriptExecutor:javascriptExecutor];
            if (processed) {
                break;
            }
        }
    }
    
    return processed;
}

- (SFWebViewProtocolObserver *)addObserverForProtocol:(NSString *)protocol {
    SFWebViewProtocolObserver *observer = [SFWebViewProtocolObserver new];
    observer.protocol = [protocol lowercaseString];
    [observer connect];
    
    [self.observers addObject:observer];
    
    return observer;
}

- (void)removeObserver:(SFWebViewProtocolObserver *)observer {
    [self.observers removeObject:observer];
}

@end
