//
//  SFObjectMappingCollector.m
//  SFFoundation
//
//  Created by yangzexin on 11/22/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFObjectMappingCollector.h"

#import <objc/runtime.h>

#import "SFPropertyProcessor.h"

@implementation SFObjectMappingCollectorContext

@end

@interface SFClassWrapper : NSObject

@property (nonatomic, assign) Class clss;

+ (instancetype)wrapperWithClass:(Class)clss;

@end

@implementation SFClassWrapper

+ (instancetype)wrapperWithClass:(Class)clss {
    SFClassWrapper *wrapper = [SFClassWrapper new];
    wrapper.clss = clss;
    
    return wrapper;
}

@end

@interface SFUnhandledSubObjectMappingContext : NSObject

@property (nonatomic, strong) id<SFObjectMapping> targetObjectMapping;
@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *className;

+ (instancetype)contextWithObjectMapping:(id<SFObjectMapping>)objectMapping propertyName:(NSString *)propertyName className:(NSString *)className;

@end

@implementation SFUnhandledSubObjectMappingContext

+ (instancetype)contextWithObjectMapping:(id<SFObjectMapping>)objectMapping propertyName:(NSString *)propertyName className:(NSString *)className {
    SFUnhandledSubObjectMappingContext *context = [SFUnhandledSubObjectMappingContext new];
    context.targetObjectMapping = objectMapping;
    context.propertyName = propertyName;
    context.className = className;
    
    return context;
}

@end

@implementation SFObjectMappingCollector

- (id<SFObjectMapping>)objectMappingForClass:(Class)clss {
    NSMutableDictionary *keyClassNameValueObjectMapping = [NSMutableDictionary dictionary];
    NSMutableArray *unhandledClassWrappers = [NSMutableArray arrayWithObject:[SFClassWrapper wrapperWithClass:clss]];
    NSMutableArray *handledClassWrappers = [NSMutableArray array];
    NSMutableArray *allUnhandledSubObjectMappingContexts = [NSMutableArray array];
    
    id<SFObjectMapping> rootObjectMapping = nil;
    
    while (unhandledClassWrappers.count != 0) {
        SFClassWrapper *tmpWrapper = [unhandledClassWrappers objectAtIndex:0];
        [handledClassWrappers addObject:tmpWrapper];
        NSArray *tmpUnhandledSubObjectMappingContexts = nil;
        id<SFObjectMapping> objectMapping = [self _readMappingWithClass:tmpWrapper.clss outUnhandledSubObjectMappingContexts:&tmpUnhandledSubObjectMappingContexts];
        if (rootObjectMapping == nil) {
            rootObjectMapping = objectMapping;
        }
        if (objectMapping != nil) {
            [keyClassNameValueObjectMapping setObject:objectMapping forKey:NSStringFromClass(tmpWrapper.clss)];
            [allUnhandledSubObjectMappingContexts addObjectsFromArray:tmpUnhandledSubObjectMappingContexts];
            
            for (SFUnhandledSubObjectMappingContext *context in tmpUnhandledSubObjectMappingContexts) {
                NSString *className = context.className;
                Class clss = NSClassFromString(className);
                if (clss != Nil) {
                    BOOL clssExistsInUnhandledClassWrappers = NO;
                    for (SFClassWrapper *unhandledWrapper in unhandledClassWrappers) {
                        if (unhandledWrapper.clss == clss) {
                            clssExistsInUnhandledClassWrappers = YES;
                            break;
                        }
                    }
                    BOOL clssExistsInHandledClassWrappers = NO;
                    for (SFClassWrapper *handledWrapper in handledClassWrappers) {
                        if (handledWrapper.clss == clss) {
                            clssExistsInHandledClassWrappers = YES;
                            break;
                        }
                    }
                    if (clssExistsInUnhandledClassWrappers == NO && clssExistsInHandledClassWrappers == NO) {
                        [unhandledClassWrappers addObject:[SFClassWrapper wrapperWithClass:clss]];
                    }
                }
            }
        }
        [unhandledClassWrappers removeObjectAtIndex:0];
    }
    for (SFUnhandledSubObjectMappingContext *context in allUnhandledSubObjectMappingContexts) {
        id<SFObjectMapping> subObjectMapping = [keyClassNameValueObjectMapping objectForKey:context.className];
        if (subObjectMapping) {
            [context.targetObjectMapping addObjectMapping:subObjectMapping forPropertyName:context.propertyName];
        }
    }
    
    return rootObjectMapping;
}

- (id<SFObjectMapping>)_readMappingWithClass:(Class)clss outUnhandledSubObjectMappingContexts:(NSArray **)outUnhandledSubObjectMappingContexts {
    id<SFObjectMapping> mapping = nil;
    NSMutableArray *unhandledSubObjectMappingContexts = [NSMutableArray array];
    NSAssert(_delegate != nil, @"delegate can't be nil");
    SFObjectMappingCollectorContext *context = [self.delegate collectorContextForClass:clss];
    if (context) {
        mapping = [SFObjectMapping objectMappingWithClass:clss];
        for (NSString *propertyName in [context.keyPropertyNameValueKeyMapping allKeys]) {
            [mapping addPropertyNameMapping:[context.keyPropertyNameValueKeyMapping objectForKey:propertyName] forPropertyName:propertyName];
        }
        for (NSString *propertyName in [context.keyPropertyNameValueClass allKeys]) {
            id value = [context.keyPropertyNameValueClass objectForKey:propertyName];
            if (class_isMetaClass(object_getClass(value))) {
                [unhandledSubObjectMappingContexts addObject:[SFUnhandledSubObjectMappingContext contextWithObjectMapping:mapping
                                                                                                             propertyName:propertyName
                                                                                                                className:NSStringFromClass(value)]];
            }
        }
        for (SFPropertyProcessor *propertyProcessor in context.propertyProcessors) {
            [mapping addPropertyProcessing:propertyProcessor.propertyProcessing forPropertyName:propertyProcessor.propertyName];
        }
    }
    if (mapping == nil) {
        mapping = [SFObjectMapping objectMappingWithClass:clss];
    }
    *outUnhandledSubObjectMappingContexts = unhandledSubObjectMappingContexts;
    
    return mapping;
}

@end