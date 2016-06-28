//
//  SFObjectMappingCollector.h
//  SFFoundation
//
//  Created by yangzexin on 11/22/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFObjectMapping.h"

@protocol SFObjectMappingCollector <NSObject>

- (id<SFObjectMapping>)objectMappingForClass:(Class)clss;

@end

@interface SFObjectMappingCollectorContext : NSObject

@property (nonatomic, strong) NSDictionary *keyPropertyNameValueKeyMapping;
@property (nonatomic, strong) NSDictionary *keyPropertyNameValueClass;
@property (nonatomic, strong) NSArray *propertyProcessors;

@end

@protocol SFObjectMappingCollectorDelegate <NSObject>

- (SFObjectMappingCollectorContext *)collectorContextForClass:(Class)clss;

@end

@interface SFObjectMappingCollector : NSObject <SFObjectMappingCollector>

/**
 Using delegate to get unknown ObjectMappings
 */
@property (nonatomic, assign) id<SFObjectMappingCollectorDelegate> delegate;

@end