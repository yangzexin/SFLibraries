//
//  SFServant+Private.h
//  SFFoundation
//
//  Created by yangzexin on 11/2/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFServant.h"

@interface SFServant ()

@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, copy) SFServantCallback callback;

@end
