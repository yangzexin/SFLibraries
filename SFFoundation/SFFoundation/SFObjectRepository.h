//
//  ProviderPool.h
//
//
//  Created by yangzexin on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFObjectRepository;

@protocol SFRepositionSupportedObject <NSObject>

- (BOOL)shouldRemoveFromObjectRepository;
- (void)willRemoveFromObjectRepository;
@optional
- (void)didAddToRepository:(SFObjectRepository *)repository;

@end

@protocol SFRepositoryAnalyzer <NSObject>

- (void)repositoryDidAddObject:(id<SFRepositionSupportedObject>)object;
- (void)repositoryDidRemoveObject:(id<SFRepositionSupportedObject>)object;
- (NSArray *)removableObjects;

@end

@interface SFObjectRepository : NSObject

@property (nonatomic, strong, readonly) id<SFRepositoryAnalyzer> analyzer;

+ (instancetype)sharedRepository;

- (void)addObject:(id<SFRepositionSupportedObject>)object;
- (void)removeObject:(id<SFRepositionSupportedObject>)object;

- (void)addObject:(id<SFRepositionSupportedObject>)object identifier:(id)identifier;
- (void)removeObjectWithIdentifier:(id)identifier;
- (id<SFRepositionSupportedObject>)objectWithIdentifier:(id)identifier;

- (void)tryCleanRepository;

+ (instancetype)objectRepository;
+ (instancetype)objectRepositoryWithAnalyzer:(id<SFRepositoryAnalyzer>)analyzer;

@end
