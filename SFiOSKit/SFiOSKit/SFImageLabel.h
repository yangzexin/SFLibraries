//
//  SFImageLabel.h
//  SFiOSKit
//
//  Created by yangzexin on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXPORT NSString *SFImageLabelDefaultImageLeftMatchingText;
OBJC_EXPORT NSString *SFImageLabelDefaultImageRightMatchingText;

@class SFImageLabelText;

@protocol SFImageLabelTextDataDetector <NSObject>

- (void)imageLabelText:(SFImageLabelText *)imageLabelText enumerateMatchesInString:(NSString *)text usingBlock:(void(^)(NSRange range, NSTextCheckingType type))usingBlock;
- (NSAttributedString *)imageLabelText:(SFImageLabelText *)imageLabelText attributedStringForString:(NSString *)string type:(NSTextCheckingType)type highlighted:(BOOL)highlighted;

@end

@interface SFImageLabelTextDefaultDataDetector : NSObject <SFImageLabelTextDataDetector>

@property (nonatomic, strong) NSDictionary *textAttributes;
@property (nonatomic, strong) NSDictionary *highlightedTextAttributes;

@property (nonatomic, strong, readonly) NSDataDetector *dataDetector;

+ (instancetype)defaultDataDetectorWithDataDetector:(NSDataDetector *)dataDetector;

@end

@interface SFImageLabelText : NSObject <NSCoding>

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, assign) CGFloat constraitsWidth;

@property (nonatomic, copy) CGSize(^imageSizeCalculator)(NSString *imageName);

@property (nonatomic, copy) NSString *imageMatchingLeft;
@property (nonatomic, copy) NSString *imageMatchingRight;

@property (nonatomic, readonly) CGSize size;

@property (nonatomic, strong) id<SFImageLabelTextDataDetector> dataDetector;

@property (nonatomic, copy) NSAttributedString *(^attributedStringWrapper)(NSAttributedString *attributedString);

+ (instancetype)textFromString:(NSString *)string
               constraitsWidth:(CGFloat)constraitsWidth;

+ (instancetype)textFromString:(NSString *)string
               constraitsWidth:(CGFloat)constraitsWidth
           imageSizeCalculator:(CGSize(^)(NSString *imageName))imageSizeCalculator;

- (instancetype)build;

- (SFImageLabelText *)textByAppendingText:(SFImageLabelText *)text;

- (NSDictionary *)currentTextAttributes;

@end

@class SFImageLabel;

@protocol SFImageLabelDelegate <NSObject>

- (UIImage *)imageLabel:(SFImageLabel *)imageLabel imageWithName:(NSString *)imageName;
@optional
- (void)imageLabel:(SFImageLabel *)imageLabel didSelectDetectedDataString:(NSString *)string type:(NSTextCheckingType)type;
- (UIColor *)imageLabel:(SFImageLabel *)imageLabel highlightedTextBackgroundColorForDetectedDataString:(NSString *)string type:(NSTextCheckingType)type;

@end

@interface SFImageLabel : UIView

@property (nonatomic, weak) id<SFImageLabelDelegate> delegate;
@property (nonatomic, strong) SFImageLabelText *text;

@property (nonatomic, assign) NSInteger numberOfVisibleLines;

@property (nonatomic, assign) BOOL detectedDataStringInteractable;

@property (nonatomic, assign) BOOL drawsImageWithImageSize;

@property (nonatomic, strong) UIColor *highlightedTextBackgroundColor;

@property (nonatomic, readonly) NSInteger numberOfLines;

- (CGFloat)heightOfTextWithNumberOfVisibleLines:(NSInteger)numberOfVisibleLines;

@end