//
//  SFToast.h
//  SFiOSKit
//
//  Created by yangzexin on 11/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFToast : NSObject

+ (void)toastInView:(UIView *)view text:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier;

+ (void)toastInView:(UIView *)view text:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier completion:(void(^)())completion;

+ (void)toastWithText:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier;

+ (void)toastWithText:(NSString *)text hideAfterSeconds:(NSTimeInterval)hideAfterSeconds identifier:(NSString *)identifier completion:(void(^)())completion;

+ (void)dismissWithIdentifier:(NSString *)identifier;

@end
