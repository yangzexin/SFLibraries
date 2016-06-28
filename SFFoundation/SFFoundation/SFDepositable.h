//
//  SFDepositable.h
//  SFFoundation
//
//  Created by yangzexin on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFDepositable <NSObject>

- (BOOL)shouldRemoveDepositable;
- (void)depositableWillRemove;
@optional
- (void)depositableDidAdd;

@end
