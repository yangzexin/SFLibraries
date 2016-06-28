//
//  SFGridViewWrapper.h
//  SFiOSKit
//
//  Created by yangzexin on 10/16/12.
//  Copyright (c) 2012 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFGridViewWrapper;

@protocol SFGridViewWrapperDelegate <NSObject>

- (NSInteger)numberOfItemsInGridViewWrapper:(SFGridViewWrapper *)gridViewTableViewHelper;
- (void)gridViewWrapper:(SFGridViewWrapper *)gridViewTableViewHelper configureView:(UIView *)view atIndex:(NSInteger)index;

@end

@interface SFGridViewWrapper : NSObject <UITableViewDataSource>

@property (nonatomic, assign) id<SFGridViewWrapperDelegate> delegate;
@property (nonatomic, readonly) NSInteger numberOfColumns;
@property (nonatomic, assign) BOOL forceSquare;

- (id)initWithNumberOfColumns:(NSInteger)columns;

@end
