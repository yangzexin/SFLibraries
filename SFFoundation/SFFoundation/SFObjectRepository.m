//
//  ProviderPool.m
//
//
//  Created by yangzexin on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFObjectRepository.h"

@interface _SFSharedObjectRepository : SFObjectRepository

+ (instancetype)sharedInstance;

@end

@implementation _SFSharedObjectRepository

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [_SFSharedObjectRepository new];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
#if TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidReceiveMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
    
    return self;
}

- (void)_applicationDidReceiveMemoryWarningNotification:(NSNotification *)note
{
    [self tryCleanRepository];
}

@end

@interface SFRepositoryAnalyzerDefault : NSObject <SFRepositoryAnalyzer>

@property (nonatomic, strong) NSMutableArray *objects;

@end

@implementation SFRepositoryAnalyzerDefault

- (id)init
{
    self = [super init];
    
    _objects = [NSMutableArray new];
    
    return self;
}

- (void)repositoryDidAddObject:(id<SFRepositionSupportedObject>)object
{
    [_objects addObject:object];
}

- (void)repositoryDidRemoveObject:(id<SFRepositionSupportedObject>)object
{
    [_objects removeObject:object];
}

- (NSArray *)removableObjects
{
    NSArray *analyzingObjects = [NSArray arrayWithArray:_objects];
    NSMutableArray *removableObjects = [NSMutableArray array];
    for (id<SFRepositionSupportedObject> object in analyzingObjects) {
        if ([object shouldRemoveFromObjectRepository]) {
            [removableObjects addObject:object];
            [_objects removeObject:object];
        }
    }
    
    return removableObjects;
}

@end

@interface SFObjectRepository ()

@property (nonatomic, strong) id<SFRepositoryAnalyzer> analyzer;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSMutableDictionary *keyIdentifierValueObject;

@end

@implementation SFObjectRepository

- (void)dealloc
{
    [self _releaseAllObjects];
}

+ (instancetype)sharedRepository
{
    return [_SFSharedObjectRepository sharedInstance];
}

- (id)init
{
    self = [super init];
    
    self.objects = [NSMutableArray array];
    self.analyzer = [SFRepositoryAnalyzerDefault new];
    self.keyIdentifierValueObject = [NSMutableDictionary dictionary];
    
    return self;
}

- (void)addObject:(id<SFRepositionSupportedObject>)object
{
    @synchronized(self) {
        [self _analyze];
        if (object) {
            [_objects addObject:object];
            if ([object respondsToSelector:@selector(didAddToRepository:)]) {
                [object didAddToRepository:self];
            }
            [_analyzer repositoryDidAddObject:object];
        }
    }
}

- (void)removeObject:(id<SFRepositionSupportedObject>)object
{
    if (object) {
        @synchronized(self) {
            [object willRemoveFromObjectRepository];
            [_objects removeObject:object];
            [self _objectDidRemove:object];
        }
    }
}

- (NSString *)_wrapIdentifier:(id)identifier
{
    return [NSString stringWithFormat:@"%@", identifier];
}

- (void)addObject:(id<SFRepositionSupportedObject>)object identifier:(id)identifier
{
    [self addObject:object];
    if (identifier) {
        [self removeObjectWithIdentifier:identifier];
        NSString *wrappedIdentifier = [self _wrapIdentifier:identifier];
        [_keyIdentifierValueObject setObject:object forKey:wrappedIdentifier];
    }
}

- (void)removeObjectWithIdentifier:(id)identifier
{
    if (identifier) {
        NSString *wrappedIdentifier = [self _wrapIdentifier:identifier];
        id<SFRepositionSupportedObject> existsObject = nil;
        
        if ((existsObject = [_keyIdentifierValueObject objectForKey:wrappedIdentifier]) != nil) {
            [existsObject willRemoveFromObjectRepository];
            [_objects removeObject:existsObject];
            [self _objectDidRemove:existsObject];
            [_keyIdentifierValueObject removeObjectForKey:wrappedIdentifier];
        }
    }
}

- (id<SFRepositionSupportedObject>)objectWithIdentifier:(id)identifier
{
    return [_keyIdentifierValueObject objectForKey:[self _wrapIdentifier:identifier]];
}

- (void)_objectDidRemove:(id)object
{
    [_analyzer repositoryDidRemoveObject:object];
}

- (void)tryCleanRepository
{
    @synchronized(self) {
        [self _analyze];
    }
}

- (void)_analyze
{
    NSArray *removableObjects = [_analyzer removableObjects];
    for (id<SFRepositionSupportedObject> object in removableObjects) {
        [object willRemoveFromObjectRepository];
        [_objects removeObject:object];
        [self _objectDidRemove:object];
    }
}

- (void)_releaseAllObjects
{
    for (id<SFRepositionSupportedObject> obj in _objects) {
        [obj willRemoveFromObjectRepository];
        [self _objectDidRemove:obj];
    }
    [_objects removeAllObjects];
}

+ (instancetype)objectRepository
{
    return [[self class] objectRepositoryWithAnalyzer:nil];
}

+ (instancetype)objectRepositoryWithAnalyzer:(id<SFRepositoryAnalyzer>)analyzer
{
    SFObjectRepository *repository = [SFObjectRepository new];
    if (analyzer != nil) {
        repository.analyzer = analyzer;
    }
    
    return repository;
}

@end
