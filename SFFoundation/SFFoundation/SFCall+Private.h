//
//  SFCall+Private.h
//  SFFoundation
//
//  Created by yangzexin on 11/2/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFCall.h"

@interface SFCall ()

@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign, getter = isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, copy) SFCallCompletion completion;

@end
