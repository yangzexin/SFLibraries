//
//  SFGestureBackNavigationController.h
//  SFiOSKit
//
//  Created by yangzexin on 9/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFGestureBackable <NSObject>

@optional
- (void)gestureBackDidTrigger;
- (BOOL)shouldTriggerGestureBack;
- (BOOL)restoreToOriginalPosition;

@end

@interface SFGestureBackNavigationController : UINavigationController

@property (nonatomic, assign) CGFloat leftPanDistance;
@property (nonatomic, assign) BOOL disableGestureBack;
@property (nonatomic, assign) BOOL endEditingWhenGestureWillTrigger;

@end