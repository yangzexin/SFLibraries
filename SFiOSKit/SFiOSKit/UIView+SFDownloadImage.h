//
//  UIView+SFDownloadImage.h
//  SFiOSKit
//
//  Created by yangzexin on 7/5/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (SFDownloadImage)

- (void)sf_downloadImageWithURL:(NSURL *)url completion:(void(^)(UIImage *image, NSError *error))completion;
- (void)sf_downloadImageWithURL:(NSURL *)url maxPixelSize:(CGFloat)maxPixelSize completion:(void(^)(UIImage *image, NSError *error))completion;

@end
