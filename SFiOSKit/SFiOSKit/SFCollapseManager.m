//
//  SFCollapseManager.m
//  SFiOSKit
//
//  Created by yangzexin on 3/11/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFCollapseManager.h"

NSInteger SFCollapseManagerItemIndexNotFound = -1;

@interface SFCollapseManager ()

@property (nonatomic, strong) NSMutableDictionary *keyItemIndexValueCollapseState;
@property (nonatomic, strong) NSMutableDictionary *keyItemIndexValueNumberOfSubItems;

@end

@implementation SFCollapseManager

+ (instancetype)managerWithNumberOfItems:(NSInteger)numberOfItems {
    SFCollapseManager *mgr = [self new];
    mgr.numberOfItems = numberOfItems;
    return mgr;
}

- (void)setNumberOfItems:(NSInteger)numberOfItems {
    _numberOfItems = numberOfItems;
    
    self.keyItemIndexValueCollapseState = [NSMutableDictionary dictionary];
    self.keyItemIndexValueNumberOfSubItems = [NSMutableDictionary dictionary];
    
    for (NSInteger i = 0; i < _numberOfItems; ++i) {
        [self.keyItemIndexValueCollapseState setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:i]];
        [self.keyItemIndexValueNumberOfSubItems setObject:[NSNumber numberWithInteger:0] forKey:[NSNumber numberWithInteger:i]];
    }
}

- (void)setNumberOfSubItems:(NSInteger)numberOfSubItems atItemIndex:(NSInteger)itemIndex {
    [self.keyItemIndexValueNumberOfSubItems setObject:[NSNumber numberWithInteger:numberOfSubItems]
                                               forKey:[NSNumber numberWithInteger:itemIndex]];
}

- (NSInteger)numberOfSubItemsAtItemIndex:(NSInteger)itemIndex {
    NSNumber *num = [_keyItemIndexValueNumberOfSubItems objectForKey:[NSNumber numberWithInteger:itemIndex]];
    return [num integerValue];
}

- (void)toggleCollapseAtItemIndex:(NSInteger)itemIndex {
    id<NSCopying> key = [NSNumber numberWithInteger:itemIndex];
    NSNumber *state = [_keyItemIndexValueCollapseState objectForKey:key];
    if ([state boolValue]) {
        [_keyItemIndexValueCollapseState setObject:[NSNumber numberWithBool:NO] forKey:key];
    } else {
        [_keyItemIndexValueCollapseState setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
}

- (void)toggleCollapseAtConfusedItemIndex:(NSInteger)confusedItemIndex {
    NSInteger targetItemIndex = [self _parentItemIndexWithConfusedItemIndex:confusedItemIndex];
    
    if (targetItemIndex != SFCollapseManagerItemIndexNotFound) {
        [self toggleCollapseAtItemIndex:targetItemIndex];
    }
}

- (BOOL)isParentItemAtConfusedItemIndex:(NSInteger)confusedItemIndex {
    NSInteger itemIndex = 0;
    NSInteger subItemIndex = 0;
    [self confusedItemIndex:confusedItemIndex outItemIndex:&itemIndex outSubItemIndex:&subItemIndex];
    return itemIndex != SFCollapseManagerItemIndexNotFound && subItemIndex == SFCollapseManagerItemIndexNotFound;
}

- (NSInteger)_parentItemIndexWithConfusedItemIndex:(NSInteger)confusedItemIndex {
    NSInteger targetItemIndex = SFCollapseManagerItemIndexNotFound;
    
    [self confusedItemIndex:confusedItemIndex outItemIndex:&targetItemIndex outSubItemIndex:NULL];
    
    return targetItemIndex;
}

- (void)confusedItemIndex:(NSInteger)confusedItemIndex outItemIndex:(NSInteger *)outItemIndex outSubItemIndex:(NSInteger *)outSubItemIndex {
    NSInteger targetItemIndex = SFCollapseManagerItemIndexNotFound;
    NSInteger targetSubItemIndex = SFCollapseManagerItemIndexNotFound;
    
    NSInteger leftEdgeIndex = 0;
    for (NSInteger i = 0; i < _numberOfItems; ++i) {
        NSInteger rightEdgeIndex = leftEdgeIndex + [self visibleItemsAtItemIndex:i] - 1;
        if (confusedItemIndex >= leftEdgeIndex && confusedItemIndex <= rightEdgeIndex) {
            targetItemIndex = i;
            if (confusedItemIndex != leftEdgeIndex) {
                targetSubItemIndex = confusedItemIndex - leftEdgeIndex - 1;
            }
            break;
        }
        leftEdgeIndex = rightEdgeIndex + 1;
    }
    
    if (outItemIndex) {
        *outItemIndex = targetItemIndex;
    }
    if (outSubItemIndex) {
        *outSubItemIndex = targetSubItemIndex;
    }
}

- (BOOL)isCollapseAtItemIndex:(NSInteger)itemIndex {
    id<NSCopying> key = [NSNumber numberWithInteger:itemIndex];
    NSNumber *state = [_keyItemIndexValueCollapseState objectForKey:key];
    
    return [state boolValue];
}

- (NSInteger)visibleItemsAtItemIndex:(NSInteger)itemIndex {
    NSInteger visibleItems = 0;
    if (itemIndex >= 0 && itemIndex < _numberOfItems) {
        visibleItems += 1;
        BOOL collapsed = [self isCollapseAtItemIndex:itemIndex];
        if (!collapsed) {
            visibleItems += [self numberOfSubItemsAtItemIndex:itemIndex];
        }
    }
    
    return visibleItems;
}

- (NSInteger)visibleItems {
    NSInteger visibleItems = 0;
    for (NSInteger i = 0; i < _numberOfItems; ++i) {
        visibleItems += [self visibleItemsAtItemIndex:i];
    }
    
    return visibleItems;
}

- (void)collapseAll {
    for (NSInteger i = 0; i < _numberOfItems; ++i) {
        [_keyItemIndexValueCollapseState setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:i]];
    }
}

- (void)expandAll {
    for (NSInteger i = 0; i < _numberOfItems; ++i) {
        [_keyItemIndexValueCollapseState setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInteger:i]];
    }
}

@end
