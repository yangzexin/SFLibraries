//
//  SFComposableMappingCollector.m
//  SFFoundation
//
//  Created by yangzexin on 11/22/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFComposableMappingCollector.h"

#import "NSString+SFJavaLikeStringHandle.h"
#import "SFPropertyProcessor.h"
#import "SFRuntimeUtils.h"

SFPropertyMapping * SFConcatPropertyMappings(SFPropertyMapping *mapping, ...) {
    SFPropertyMapping *concatedMapping = [SFPropertyMapping new];
    
    va_list params;
    va_start(params, mapping);
    for (id tmpMapping = mapping; tmpMapping != nil; tmpMapping = va_arg(params, id)) {
        [concatedMapping append:tmpMapping];
    }
    va_end(params);
    
    return concatedMapping;
}

@interface SFPropertyMappingSingleClass ()

@property (nonatomic, assign) Class clss;

@property (nonatomic, strong) NSMutableDictionary *keyPropertyNameValueKeyMapping;
@property (nonatomic, strong) NSMutableDictionary *keyPropertyNameValueClass;

@end

@implementation SFPropertyMappingSingleClass

- (id)initWithClass:(Class)clss {
    self = [super init];
    
    self.clss = clss;
    
    self.keyPropertyNameValueKeyMapping = [NSMutableDictionary dictionary];
    self.keyPropertyNameValueClass = [NSMutableDictionary dictionary];
    
    return self;
}

- (void)addPropertyMappingKeyWithPropertyName:(NSString *)propertyName keyName:(NSString *)keyName {
    [_keyPropertyNameValueKeyMapping setObject:keyName forKey:propertyName];
}

- (void)addPropertyMappingClassWithPropertyName:(NSString *)propertyName clss:(Class)clss {
    [_keyPropertyNameValueClass setObject:clss forKey:propertyName];
}

@end

@interface SFPropertyMapping ()

@property (nonatomic, strong) NSMutableArray *propertyMappingSingleClasses;

@end

@implementation SFPropertyMapping

- (id)init {
    self = [super init];
    
    self.propertyMappingSingleClasses = [NSMutableArray array];
    
    return self;
}

- (void)addPropertyMappingSingleClass:(SFPropertyMappingSingleClass *)single {
    [self.propertyMappingSingleClasses addObject:single];
}

- (instancetype)append:(SFPropertyMapping *)propertyMapping {
    [self.propertyMappingSingleClasses addObjectsFromArray:propertyMapping.propertyMappingSingleClasses];
    
    return self;
}

@end

@interface SFComposableMappingCollector () <SFObjectMappingCollectorDelegate>

@property (nonatomic, strong) NSMutableDictionary *keyClassNameValueCollectorContext;

@property (nonatomic, strong) NSMutableDictionary *keyClassNameValuePropertyProcessors;

@property (nonatomic, strong) NSArray *allCollectorContextClasses;

@property (nonatomic, strong) NSArray *allPropertyProcessorsClasses;

@property (nonatomic, assign) BOOL inheritanceEnabled;

@end

@implementation SFComposableMappingCollector

+ (instancetype)collector {
    return [self collectorWithMapping:nil];
}

+ (instancetype)collectorWithMapping:(id)mapping {
    SFComposableMappingCollector *collector = [self new];
    if (mapping) {
        [collector addMapping:mapping];
    }
    
    return collector;
}

- (id)init {
    self = [super init];
    
    self.keyClassNameValueCollectorContext = [NSMutableDictionary dictionary];
    self.inheritanceEnabled = YES;
    
    return self;
}

- (void)addMapping:(SFPropertyMapping *)mapping {
    for (SFPropertyMappingSingleClass *singleMapping in mapping.propertyMappingSingleClasses) {
        SFObjectMappingCollectorContext *context = [SFObjectMappingCollectorContext new];
        context.keyPropertyNameValueKeyMapping = singleMapping.keyPropertyNameValueKeyMapping;
        context.keyPropertyNameValueClass = singleMapping.keyPropertyNameValueClass;
        
        [_keyClassNameValueCollectorContext setObject:context forKey:NSStringFromClass(singleMapping.clss)];
    }
}

- (void)addPropertyProcessors:(NSArray *)propertyProcessors {
    if (_keyClassNameValuePropertyProcessors == nil) {
        self.keyClassNameValuePropertyProcessors = [NSMutableDictionary dictionary];
    }
    for (SFPropertyProcessor *propertyProcessor in propertyProcessors) {
        NSString *className = NSStringFromClass([propertyProcessor clss]);
        NSMutableArray *existsPropertyProcessors = [_keyClassNameValuePropertyProcessors objectForKey:className];
        if (existsPropertyProcessors == nil) {
            existsPropertyProcessors = [NSMutableArray array];
            [_keyClassNameValuePropertyProcessors setObject:existsPropertyProcessors forKey:className];
        }
        [existsPropertyProcessors addObject:propertyProcessor];
        
        if ([_keyClassNameValueCollectorContext objectForKey:className] == nil) {
            SFObjectMappingCollectorContext *context = [SFObjectMappingCollectorContext new];
            [_keyClassNameValueCollectorContext setObject:context forKey:className];
        }
    }
}

- (id<SFObjectMapping>)objectMappingForClass:(Class)clss {
    SFObjectMappingCollector *collector = [SFObjectMappingCollector new];
    collector.delegate = self;
    id<SFObjectMapping> objectMapping = [collector objectMappingForClass:clss];
    NSMutableArray *propertyProcessors = [_keyClassNameValuePropertyProcessors objectForKey:NSStringFromClass(clss)];
    for (SFPropertyProcessor *propertyProcessor in propertyProcessors) {
        [objectMapping addPropertyProcessing:propertyProcessor.propertyProcessing forPropertyName:propertyProcessor.propertyName];
    }
    
    return objectMapping;
}

- (NSArray *)allCollectorContextClasses {
    if (_allCollectorContextClasses == nil) {
        NSMutableArray *allCollectorContextClasses = [NSMutableArray array];
        for (NSString *className in [self.keyClassNameValueCollectorContext allKeys]) {
            [allCollectorContextClasses addObject:[NSValue valueWithNonretainedObject:NSClassFromString(className)]];
        }
        
        // sort
        [allCollectorContextClasses sortUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
            Class clss1 = [obj1 nonretainedObjectValue];
            Class clss2 = [obj2 nonretainedObjectValue];
            
            return [clss1 isSubclassOfClass:clss2] ? NSOrderedDescending : NSOrderedSame;
        }];
        
        self.allCollectorContextClasses = allCollectorContextClasses;
    }
    
    return _allCollectorContextClasses;
}

- (NSArray *)allPropertyProcessorsClasses {
    if (_allPropertyProcessorsClasses == nil) {
        NSMutableArray *allPropertyProcessorsClasses = [NSMutableArray array];
        for (NSString *className in [self.keyClassNameValuePropertyProcessors allKeys]) {
            [allPropertyProcessorsClasses addObject:[NSValue valueWithNonretainedObject:NSClassFromString(className)]];
        }
        
        // sort
        [allPropertyProcessorsClasses sortUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
            Class clss1 = [obj1 nonretainedObjectValue];
            Class clss2 = [obj2 nonretainedObjectValue];
            
            return [clss1 isSubclassOfClass:clss2] ? NSOrderedDescending : NSOrderedSame;
        }];
        
        self.allPropertyProcessorsClasses = allPropertyProcessorsClasses;
    }
    
    return _allPropertyProcessorsClasses;
}

- (SFObjectMappingCollectorContext *)collectorContextForClass:(Class)clss {
    SFObjectMappingCollectorContext *context = nil;
    if (_inheritanceEnabled) {
        context = [SFObjectMappingCollectorContext new];
        
        NSArray *allCollectorContextClasses = self.allCollectorContextClasses;
        
        NSMutableDictionary *keyPropertyNameValueKeyMapping = [NSMutableDictionary dictionary];
        NSMutableDictionary *keyPropertyNameValueClass = [NSMutableDictionary dictionary];
        NSMutableDictionary *keyPropertyNameValuePropertyProcessor = [NSMutableDictionary dictionary];
        for (NSValue *tmpClssValue in allCollectorContextClasses) {
            Class tmpClss = [tmpClssValue nonretainedObjectValue];
            if (tmpClss == clss || [clss isSubclassOfClass:tmpClss]) {
                SFObjectMappingCollectorContext *tmpContext = [self.keyClassNameValueCollectorContext objectForKey:NSStringFromClass(tmpClss)];
                [keyPropertyNameValueKeyMapping addEntriesFromDictionary:tmpContext.keyPropertyNameValueKeyMapping];
                [keyPropertyNameValueClass addEntriesFromDictionary:tmpContext.keyPropertyNameValueClass];
                
                NSMutableArray *propertyProcessors = [_keyClassNameValuePropertyProcessors objectForKey:NSStringFromClass(tmpClss)];
                for (SFPropertyProcessor *propertyProcessor in propertyProcessors) {
                    [keyPropertyNameValuePropertyProcessor setObject:propertyProcessor forKey:propertyProcessor.propertyName];
                }
            }
        }
        
        context.keyPropertyNameValueKeyMapping = keyPropertyNameValueKeyMapping;
        context.keyPropertyNameValueClass = keyPropertyNameValueClass;
        context.propertyProcessors = [keyPropertyNameValuePropertyProcessor allValues];
    } else {
        context = [self.keyClassNameValueCollectorContext objectForKey:NSStringFromClass(clss)];
        context.propertyProcessors = [self.keyClassNameValuePropertyProcessors objectForKey:NSStringFromClass(clss)];
    }
    
    return context;
}

@end
