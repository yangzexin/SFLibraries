//
//  UIWebView+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 11/12/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIWebView (SFAddition)

- (CGPoint)sf_pageScrollOffset;
- (CGSize)sf_windowSize;
- (NSString *)sf_loadJavascriptWithFileName:(NSString *)fileName;;
- (void)sf_disableWebViewContextMenu;
- (NSString *)sf_HTMLElementsAtPoint:(CGPoint)point;
- (NSString *)sf_linkHrefAtPoint:(CGPoint)point;
- (NSString *)sf_ALinkAtPoint:(CGPoint)point;
- (NSString *)sf_linkSrcAtPoint:(CGPoint)point;
- (void)sf_loadWithURLString:(NSString *)URLString;
- (NSString *)sf_selectedText;
- (NSInteger)sf_selectedTextStartOffset;
- (void)sf_removeShadow;
- (UIScrollView *)sf_scrollView;

@end
