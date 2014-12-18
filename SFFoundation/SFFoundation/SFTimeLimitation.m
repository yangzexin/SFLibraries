//
//  SFTimeLimitation.m
//  esl
//
//  Created by yangzexin on 5/6/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFTimeLimitation.h"

@interface SFTimeLimitation ()

@property (nonatomic, strong) NSMutableDictionary *keyIdentifierValueDate;

@end

@implementation SFTimeLimitation

+ (instancetype)sharedTimeLimitation
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    
    self.keyIdentifierValueDate = [NSMutableDictionary dictionary];
    
    return self;
}

- (void)limitWithIdentifier:(NSString *)identifier
          limitTimeInterval:(NSTimeInterval)limitTimeInterval
                    doBlock:(void(^)())doBlock
                  failBlock:(void(^)(NSTimeInterval remainingTime))failBlock
{
    NSDate *lastExecuteDate = [_keyIdentifierValueDate objectForKey:identifier];
    NSDate *nowDate = [NSDate date];
    
    NSTimeInterval remainingTime = [lastExecuteDate timeIntervalSinceReferenceDate] + limitTimeInterval - [nowDate timeIntervalSinceReferenceDate];
    
    if (lastExecuteDate == nil || remainingTime < 0) {
        [_keyIdentifierValueDate setObject:nowDate forKey:identifier];
        doBlock();
    } else {
        if (failBlock) {
            failBlock(remainingTime);
        }
    }
}

- (void)resetLimitationWithIdentifier:(NSString *)identifier
{
    [_keyIdentifierValueDate removeObjectForKey:identifier];
}

@end
