//
//  SFWebViewCallTracker.h
//  SFiOSKit
//
//  Created by yangzexin on 3/17/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SFFoundation/SFFoundation.h>

typedef void(^SFWebViewProtocolNotifier)(NSString *result);

@interface SFWebViewProtocolObserver : NSObject

@property (nonatomic, copy, readonly) NSString *protocol;

- (void)disconnect;

- (void)connect;

- (SFCancellable *)observeMethod:(NSString *)method handler:(void(^)(NSString *method, NSDictionary *parameters, SFWebViewProtocolNotifier notifier))handler;

@end

typedef NSString *(^SFWebViewJavascriptExecutor)(NSString *javascript);

@interface SFWebViewCallTracker : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isURLTrackable:(NSURL *)url javascriptExecutor:(SFWebViewJavascriptExecutor)javascriptExecutor;

- (SFWebViewProtocolObserver *)addObserverForProtocol:(NSString *)protocol;

- (void)removeObserver:(SFWebViewProtocolObserver *)observer;

@end
