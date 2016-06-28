//
//  SFCollapseManager.h
//  SFiOSKit
//
//  Created by yangzexin on 3/11/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXPORT NSInteger SFCollapseManagerItemIndexNotFound;

@interface SFCollapseManager : NSObject

@property (nonatomic, assign) NSInteger numberOfItems;

+ (instancetype)managerWithNumberOfItems:(NSInteger)numberOfItems;

- (void)setNumberOfSubItems:(NSInteger)numberOfSubItems atItemIndex:(NSInteger)itemIndex;
- (NSInteger)numberOfSubItemsAtItemIndex:(NSInteger)itemIndex;

- (void)toggleCollapseAtItemIndex:(NSInteger)itemIndex;
- (BOOL)isCollapseAtItemIndex:(NSInteger)itemIndex;

- (void)toggleCollapseAtConfusedItemIndex:(NSInteger)confusedItemIndex;
- (BOOL)isParentItemAtConfusedItemIndex:(NSInteger)confusedItemIndex;
- (void)confusedItemIndex:(NSInteger)confusedItemIndex outItemIndex:(NSInteger *)outItemIndex outSubItemIndex:(NSInteger *)outSubItemIndex;

- (NSInteger)visibleItemsAtItemIndex:(NSInteger)itemIndex;
- (NSInteger)visibleItems;

- (void)collapseAll;
- (void)expandAll;

@end
