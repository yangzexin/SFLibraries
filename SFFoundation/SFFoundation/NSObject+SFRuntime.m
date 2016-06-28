//
//  NSObject+SFRuntime.m
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSObject+SFRuntime.h"

#import "SFObjcProperty.h"
#import "SFDeallocObserver+Private.h"
#import "NSObject+SFObjectAssociation.h"

static const char *SFKeyIdentifierDeallocObserver = "SFKeyIdentifierDeallocObserver";

@implementation NSObject (SFRuntime)

+ (NSArray *)sf_objcProperties {
    return [SFObjcProperty objcPropertiesOfClass:[self class]];
}

+ (NSArray *)sf_objcPropertiesStopAtNSObject {
    return [SFObjcProperty objcPropertiesOfClass:[self class] stopClass:[NSObject class]];
}

+ (NSArray *)sf_objcPropertiesWithSearchingSuperClass:(BOOL)searchingSuperClass {
    return [SFObjcProperty objcPropertiesOfClass:[self class] searchingSuperClass:searchingSuperClass];
}

+ (NSArray *)sf_objcPropertiesWithSearchingSuperClass:(BOOL)searchingSuperClass exceptPropertyNames:(NSArray *)exceptPropertyNames {
    NSArray *objcProperties = [self sf_objcPropertiesWithSearchingSuperClass:NO];
    NSMutableArray *filteredObjcProperties = [NSMutableArray array];
    [objcProperties enumerateObjectsUsingBlock:^(SFObjcProperty *obj, NSUInteger idx, BOOL *stop) {
        if ([exceptPropertyNames indexOfObject:obj.name] == NSNotFound) {
            [filteredObjcProperties addObject:obj];
        }
    }];
    
    return filteredObjcProperties;
}

+ (NSArray *)sf_objcPropertiesWithStepController:(BOOL(^)(Class tmpClass, BOOL *stop))stepController {
    return [SFObjcProperty objcPropertiesOfClass:[self class] stepController:stepController];
}

- (void)sf_copyPropertyValuesFromObject:(id)object specificObjcProperties:(NSArray *)specificObjcProperties exceptPropertyNames:(NSArray *)exceptPropertyNames {
    NSArray *properties = specificObjcProperties;
    if (properties == nil) {
        properties = [SFObjcProperty objcPropertiesOfClass:[self class] searchingSuperClass:NO];
    }
    for (SFObjcProperty *property in properties) {
        if (exceptPropertyNames == nil || [exceptPropertyNames indexOfObject:property.name] == NSNotFound) {
            [self setValue:[object valueForKey:property.name] forKey:property.name];
        }
    }
}

- (SFDeallocObserver *)sf_addDeallocObserver:(void(^)())trigger {
    return [self sf_addDeallocObserver:trigger identifier:nil];
}

- (void)sf_removeDeallocObserver:(SFDeallocObserver *)observer {
    [self sf_removeDeallocObserverByIdentifier:[observer sf_associatedObjectWithKey:@"_identifier"]];
}

- (NSMutableDictionary *)_keyIdentifierValueDeallocObserver {
    NSMutableDictionary *keyIdentifierValueDeallocObserver = objc_getAssociatedObject(self, SFKeyIdentifierDeallocObserver);
    @synchronized(self) {
        if (keyIdentifierValueDeallocObserver == nil) {
            keyIdentifierValueDeallocObserver = [NSMutableDictionary dictionary];
            objc_setAssociatedObject(self, SFKeyIdentifierDeallocObserver, keyIdentifierValueDeallocObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    return keyIdentifierValueDeallocObserver;
}

- (SFDeallocObserver *)sf_addDeallocObserver:(void(^)())trigger identifier:(NSString *)identifier {
    SFDeallocObserver *observer = nil;
    @synchronized(self) {
        if (identifier == nil) {
            identifier = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
        }
        
        observer = [SFDeallocObserver observerWthTrigger:trigger];
        [observer sf_setAssociatedObject:identifier key:@"_identifier"];
        [[self _keyIdentifierValueDeallocObserver] setObject:observer forKey:identifier];
    }
    
    return observer;
}

- (void)sf_removeDeallocObserverByIdentifier:(NSString *)identifier {
    if (identifier) {
        @synchronized(self) {
            NSMutableDictionary *keyIdentifierValueDeallocObserver = [self _keyIdentifierValueDeallocObserver];
            SFDeallocObserver *observer = [keyIdentifierValueDeallocObserver objectForKey:identifier];
            [observer cancel];
            [keyIdentifierValueDeallocObserver removeObjectForKey:identifier];
        }
    }
}

- (void)sf_depositNotificationObserver:(id)observer {
    [self sf_depositNotificationObserver:observer identifier:nil];
}

- (void)sf_depositNotificationObserver:(id)observer identifier:(NSString *)identifier {
    [self sf_addDeallocObserver:^{
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    } identifier:identifier];
}

- (void)sf_removeDepositedNotificationObserverByIdentifier:(NSString *)identifier {
    [self sf_removeDeallocObserverByIdentifier:identifier];
}

@end

