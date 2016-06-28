//
//  NSObject+SFDepositable.m
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSObject+SFDepositable.h"

#import "NSObject+SFObjectAssociation.h"

@protocol SFDepositableRepositoryAnalyzer <NSObject>

- (void)repositoryDidAddDepositable:(id<SFDepositable>)depositable;
- (void)repositoryDidRemoveDepositable:(id<SFDepositable>)depositable;
- (NSArray *)removableDepositables;

@end

@interface SFDepositableRepository : NSObject

@property (nonatomic, strong, readonly) id<SFDepositableRepositoryAnalyzer> analyzer;

- (void)addDepositable:(id<SFDepositable>)depositable;
- (void)removeDepositable:(id<SFDepositable>)depositable;

- (void)addDepositable:(id<SFDepositable>)depositable identifier:(id)identifier;
- (void)removeDepositableWithIdentifier:(id)identifier;
- (id<SFDepositable>)depositableWithIdentifier:(id)identifier;

- (void)tryCleanRecyclableDepositables;

+ (instancetype)depositableRepository;
+ (instancetype)depositableRepositoryWithAnalyzer:(id<SFDepositableRepositoryAnalyzer>)analyzer;

@end

@interface SFRepositoryAnalyzerDefault : NSObject <SFDepositableRepositoryAnalyzer>

@property (nonatomic, strong) NSMutableArray *depositables;

@end

@implementation SFRepositoryAnalyzerDefault

- (id)init {
    self = [super init];
    
    _depositables = [NSMutableArray new];
    
    return self;
}

- (void)repositoryDidAddDepositable:(id<SFDepositable>)depositable {
    [_depositables addObject:depositable];
}

- (void)repositoryDidRemoveDepositable:(id<SFDepositable>)depositable {
    [_depositables removeObject:depositable];
}

- (NSArray *)removableDepositables {
    NSArray *analyzingObjects = [NSArray arrayWithArray:_depositables];
    NSMutableArray *removableObjects = [NSMutableArray array];
    for (id<SFDepositable> object in analyzingObjects) {
        if ([object shouldRemoveDepositable]) {
            [removableObjects addObject:object];
            [_depositables removeObject:object];
        }
    }
    
    return removableObjects;
}

@end

@interface SFDepositableRepository ()

@property (nonatomic, strong) id<SFDepositableRepositoryAnalyzer> analyzer;
@property (nonatomic, strong) NSMutableArray *depositables;
@property (nonatomic, strong) NSMutableDictionary *keyIdentifierValueDepositable;

@end

@implementation SFDepositableRepository

- (void)dealloc {
    [self _releaseAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    
    self.depositables = [NSMutableArray array];
    self.analyzer = [SFRepositoryAnalyzerDefault new];
    self.keyIdentifierValueDepositable = [NSMutableDictionary dictionary];
    
#if TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidReceiveMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
    
    return self;
}

- (void)_applicationDidReceiveMemoryWarningNotification:(NSNotification *)note {
    [self tryCleanRecyclableDepositables];
}

- (void)addDepositable:(id<SFDepositable>)depositable {
    @synchronized(self) {
        if (depositable) {
            [_depositables addObject:depositable];
            if ([depositable respondsToSelector:@selector(depositableDidAdd)]) {
                [depositable depositableDidAdd];
            }
            [_analyzer repositoryDidAddDepositable:depositable];
        }
    }
}

- (void)removeDepositable:(id<SFDepositable>)depositable {
    if (depositable) {
        @synchronized(self) {
            [depositable depositableWillRemove];
            [_depositables removeObject:depositable];
            [self _objectDidRemove:depositable];
        }
    }
}

- (NSString *)_wrapIdentifier:(id)identifier {
    return [NSString stringWithFormat:@"%@", identifier];
}

- (void)addDepositable:(id<SFDepositable>)depositable identifier:(id)identifier {
    [self addDepositable:depositable];
    if (identifier) {
        [self removeDepositableWithIdentifier:identifier];
        NSString *wrappedIdentifier = [self _wrapIdentifier:identifier];
        [_keyIdentifierValueDepositable setObject:depositable forKey:wrappedIdentifier];
    }
}

- (void)removeDepositableWithIdentifier:(id)identifier {
    if (identifier) {
        NSString *wrappedIdentifier = [self _wrapIdentifier:identifier];
        id<SFDepositable> existsObject = nil;
        
        if ((existsObject = [_keyIdentifierValueDepositable objectForKey:wrappedIdentifier]) != nil) {
            [existsObject depositableWillRemove];
            [_depositables removeObject:existsObject];
            [self _objectDidRemove:existsObject];
            [_keyIdentifierValueDepositable removeObjectForKey:wrappedIdentifier];
        }
    }
}

- (id<SFDepositable>)depositableWithIdentifier:(id)identifier {
    return [_keyIdentifierValueDepositable objectForKey:[self _wrapIdentifier:identifier]];
}

- (void)_objectDidRemove:(id)object {
    [_analyzer repositoryDidRemoveDepositable:object];
}

- (void)tryCleanRecyclableDepositables {
    @synchronized(self) {
        [self _analyze];
    }
}

- (void)_analyze {
    NSArray *removableObjects = [_analyzer removableDepositables];
    for (id<SFDepositable> object in removableObjects) {
        [object depositableWillRemove];
        [_depositables removeObject:object];
        [self _objectDidRemove:object];
    }
}

- (void)_releaseAllObjects {
    for (id<SFDepositable> obj in _depositables) {
        [obj depositableWillRemove];
        [self _objectDidRemove:obj];
    }
    [_depositables removeAllObjects];
}

+ (instancetype)depositableRepository {
    return [[self class] depositableRepositoryWithAnalyzer:nil];
}

+ (instancetype)depositableRepositoryWithAnalyzer:(id<SFDepositableRepositoryAnalyzer>)analyzer {
    SFDepositableRepository *repository = [SFDepositableRepository new];
    if (analyzer != nil) {
        repository.analyzer = analyzer;
    }
    
    return repository;
}

@end

static NSString *const SFDepositableRepositoryKey = @"kObjectRepositoryKey";

@implementation NSObject (SFDepositable)

- (SFDepositableRepository *)_depositableRepository {
    SFDepositableRepository *obj = [self sf_associatedObjectWithKey:SFDepositableRepositoryKey];
    if (obj == nil) {
        obj = [SFDepositableRepository depositableRepository];
        [self sf_setAssociatedObject:obj key:SFDepositableRepositoryKey];
    }
    
    return obj;
}

- (id)sf_deposit:(id<SFDepositable>)depositable {
    [[self _depositableRepository] addDepositable:depositable];
    
    return depositable;
}

- (void)sf_removeDepositable:(id<SFDepositable>)depositable {
    [[self _depositableRepository] removeDepositable:depositable];
}

- (id)sf_deposit:(id<SFDepositable>)depositable identifier:(NSString *)identifier {
    [[self _depositableRepository] addDepositable:depositable identifier:identifier];
    
    return depositable;
}

- (id<SFDepositable>)sf_depositableWithIdentifier:(NSString *)identifier {
    return [[self _depositableRepository] depositableWithIdentifier:identifier];
}

- (void)sf_removeDepositableWithIdentifier:(NSString *)identifier {
    [[self _depositableRepository] removeDepositableWithIdentifier:identifier];
}

- (void)sf_tryCleanRecyclableDepositables {
    [[self _depositableRepository] tryCleanRecyclableDepositables];
}

@end
