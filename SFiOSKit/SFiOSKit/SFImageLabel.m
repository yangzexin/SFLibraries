//
//  SFImageLabel.m
//  SFiOSKit
//
//  Created by yangzexin on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFImageLabel.h"

#import <CoreText/CoreText.h>
#import <SFFoundation/SFFoundation.h>

NSString *SFImageLabelDefaultImageLeftMatchingText = @"{IMG";
NSString *SFImageLabelDefaultImageRightMatchingText = @"}";

@interface SFImageAttribute : NSObject

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

@implementation SFImageAttribute

@end

@interface SFImageLabelTextDefaultDataDetector ()

@property (nonatomic, strong) NSDataDetector *dataDetector;

@end

@implementation SFImageLabelTextDefaultDataDetector

+ (instancetype)defaultDataDetectorWithDataDetector:(NSDataDetector *)dataDetector {
    SFImageLabelTextDefaultDataDetector *defaultDataDetector = [SFImageLabelTextDefaultDataDetector new];
    defaultDataDetector.dataDetector = dataDetector;
    
    return defaultDataDetector;
}

- (void)imageLabelText:(SFImageLabelText *)imageLabelText enumerateMatchesInString:(NSString *)text usingBlock:(void(^)(NSRange range, NSTextCheckingType type))usingBlock {
    [self.dataDetector enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        usingBlock(result.range, result.resultType);
    }];
}

- (NSAttributedString *)imageLabelText:(SFImageLabelText *)imageLabelText attributedStringForString:(NSString *)string type:(NSTextCheckingType)type highlighted:(BOOL)highlighted {
    NSDictionary *dataStringAttrs = highlighted ? self.highlightedTextAttributes : self.textAttributes;
    
    return [[NSAttributedString alloc] initWithString:string attributes:dataStringAttrs];
}

@end

@interface SFImageLabelText ()

@property (nonatomic, copy) NSString *string;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) NSAttributedString *attributedString;

@property (nonatomic, strong) NSMutableArray *imageAttributes;

@property (nonatomic, strong) NSMutableArray *detectedDataStringRanges;

@property (nonatomic, assign) NSRange selectedDetectedDataStringRange;

@property (nonatomic, strong) NSMutableDictionary *keyDetectedDataStringValueType;

@end

@implementation SFImageLabelText

+ (instancetype)textFromString:(NSString *)string constraitsWidth:(CGFloat)constraitsWidth {
    return [self textFromString:string constraitsWidth:constraitsWidth imageSizeCalculator:nil];
}

+ (instancetype)textFromString:(NSString *)string constraitsWidth:(CGFloat)constraitsWidth imageSizeCalculator:(CGSize(^)(NSString *imageName))imageSizeCalculator {
    SFImageLabelText *text = [SFImageLabelText new];
    text.string = [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f ? [NSString stringWithFormat:@"%@ ", string] : string;
    text.constraitsWidth = constraitsWidth;
    text.imageSizeCalculator = imageSizeCalculator;
    
    text.font = [UIFont systemFontOfSize:15.0f];
    text.imageMatchingLeft = SFImageLabelDefaultImageLeftMatchingText;
    text.imageMatchingRight = SFImageLabelDefaultImageRightMatchingText;
    text.textColor = [UIColor blackColor];
    
    return text;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_font.pointSize forKey:@"font"];
    [aCoder encodeFloat:_constraitsWidth forKey:@"constraitsWidth"];
    [aCoder encodeObject:_textColor forKey:@"textColor"];
    [aCoder encodeObject:_imageMatchingLeft forKey:@"imageMatchingLeft"];
    [aCoder encodeObject:_imageMatchingRight forKey:@"imageMatchingRight"];
    
    [aCoder encodeObject:_string forKey:@"string"];
    [aCoder encodeFloat:_width forKey:@"width"];
    [aCoder encodeFloat:_height forKey:@"height"];
    [aCoder encodeObject:_attributedString forKey:@"attributedString"];
    [aCoder encodeObject:_imageAttributes forKey:@"imageAttributes"];
    [aCoder encodeObject:_keyDetectedDataStringValueType forKey:@"keyDetectedDataStringValueType"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    _font = [UIFont systemFontOfSize:[aDecoder decodeIntegerForKey:@"font"]];
    _constraitsWidth = [aDecoder decodeFloatForKey:@"constraitsWidth"];
    _textColor = [aDecoder decodeObjectForKey:@"textColor"];
    _imageMatchingLeft = [aDecoder decodeObjectForKey:@"imageMatchingLeft"];
    _imageMatchingRight = [aDecoder decodeObjectForKey:@"imageMatchingRight"];
    
    _string = [aDecoder decodeObjectForKey:@"string"];
    _width = [aDecoder decodeFloatForKey:@"width"];
    _height = [aDecoder decodeFloatForKey:@"height"];
    _attributedString = [aDecoder decodeObjectForKey:@"attributedString"];
    _imageAttributes = [aDecoder decodeObjectForKey:@"imageAttributes"];
    _keyDetectedDataStringValueType = [aDecoder decodeObjectForKey:@"keyDetectedDataStringValueType"];
    
    return self;
}

static CGFloat SFImageLabelAscentCallback(void *ref) {
    return [(__bridge SFImageAttribute *)ref height];
}

static CGFloat SFImageLabelWidthCallback(void *ref) {
    return [(__bridge SFImageAttribute *)ref width];
}

static void SFImageLabelDeallocCallback(void *ref) {
}

static CGFloat SFImageLabelDescentCallback(void *ref) {
    return 0;
}

- (instancetype)build {
    NSString *text = _string;
    
    self.imageAttributes = [NSMutableArray array];
    
    NSDictionary *defaultTextAttrs = [self currentTextAttributes];
    
    if (self.dataDetector != nil) {
        self.detectedDataStringRanges = [NSMutableArray array];
        self.keyDetectedDataStringValueType = [NSMutableDictionary dictionary];
    }
    
    NSMutableAttributedString *attrString = [NSMutableAttributedString new];
    
    NSInteger leftMatchingIndex = 0;
    NSInteger rightMatchingIndex = 0;
    NSUInteger numberOfExistsAttributedStrings = 0;
    while ((leftMatchingIndex = [text sf_find:_imageMatchingLeft fromIndex:rightMatchingIndex]) != -1) {
        NSString *prefix = [text sf_substringWithBeginIndex:rightMatchingIndex endIndex:leftMatchingIndex];
        NSAttributedString *textAttrString = [self _attributedStringForText:prefix defaultAttrs:defaultTextAttrs numberOfExistsAttributedStrings:numberOfExistsAttributedStrings];
        [attrString appendAttributedString:textAttrString];
        numberOfExistsAttributedStrings += prefix.length;
        
        NSInteger tmpRightMatchingIndex = [text sf_find:_imageMatchingRight fromIndex:leftMatchingIndex + _imageMatchingLeft.length];
        if (tmpRightMatchingIndex == -1) {
            break;
        }
        
        NSString *imageName = [text sf_substringWithBeginIndex:leftMatchingIndex + 1 endIndex:tmpRightMatchingIndex];
        
        CGSize imageSize = CGSizeZero;
        if (_imageSizeCalculator) {
            imageSize = _imageSizeCalculator(imageName);
        }
        BOOL imageFinded = imageSize.width != 0 && imageSize.height != 0;
        if (imageFinded) {
            SFImageAttribute *attr = [[SFImageAttribute alloc] init];
            attr.width = imageSize.width;
            attr.height = imageSize.height;
            attr.imageName = imageName;
            [_imageAttributes addObject:attr];
            
            CTRunDelegateCallbacks callbacks;
            memset(&callbacks, 0, sizeof(callbacks));
            callbacks.version = kCTRunDelegateVersion1;
            callbacks.getAscent = SFImageLabelAscentCallback;
            callbacks.getDescent = SFImageLabelDescentCallback;
            callbacks.getWidth = SFImageLabelWidthCallback;
            callbacks.dealloc = SFImageLabelDeallocCallback;
            
            CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(attr));
            NSDictionary *runAttr = @{(id)kCTRunDelegateAttributeName : (__bridge id)runDelegate};
            unichar runReplacementChar = 0xFFFC;
            NSString *runReplacementString = [NSString stringWithCharacters:&runReplacementChar length:1];
            NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:runReplacementString attributes:runAttr];
            
            [attrString appendAttributedString:imageAttributedString];
            ++numberOfExistsAttributedStrings;
            
            CFRelease(runDelegate);
        } else {
            NSString *brokenImage = [text sf_substringWithBeginIndex:leftMatchingIndex endIndex:tmpRightMatchingIndex + 1];
            NSAttributedString *textAttrString = [self _attributedStringForText:brokenImage defaultAttrs:defaultTextAttrs numberOfExistsAttributedStrings:numberOfExistsAttributedStrings];
            [attrString appendAttributedString:textAttrString];
            numberOfExistsAttributedStrings += brokenImage.length;
        }
        rightMatchingIndex = tmpRightMatchingIndex + _imageMatchingRight.length;
    }
    
    if (rightMatchingIndex < text.length) {
        NSString *suffix = [text substringFromIndex:rightMatchingIndex];
        NSAttributedString *textAttrString = [self _attributedStringForText:suffix defaultAttrs:defaultTextAttrs numberOfExistsAttributedStrings:numberOfExistsAttributedStrings];
        [attrString appendAttributedString:textAttrString];
        numberOfExistsAttributedStrings += suffix.length;
    }
    
    if (self.attributedStringWrapper) {
        self.attributedString = self.attributedStringWrapper(attrString);
    } else {
        self.attributedString = attrString;
    }
    
    CFAttributedStringRef attrStringRef = (__bridge CFAttributedStringRef)_attributedString;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrStringRef);
    
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                               CFRangeMake(0, _attributedString.length),
                                                               NULL,
                                                               CGSizeMake(_constraitsWidth, CGFLOAT_MAX),
                                                               NULL);
    CFRelease(framesetter);
    self.height = size.height;
    self.width = size.width;
    
    return self;
}

- (NSAttributedString *)_attributedStringForText:(NSString *)text defaultAttrs:(NSDictionary *)defaultAttrs numberOfExistsAttributedStrings:(NSInteger)numberOfExistsAttributedStrings {
    __block NSInteger tmpNumberOfExistsAttributedStrings = numberOfExistsAttributedStrings;
    
    NSAttributedString *attrString = nil;
    
    if (self.dataDetector) {
        NSMutableAttributedString *mutableAttrString = [NSMutableAttributedString new];
        __block NSUInteger lastMatchingPosition = 0;
        __weak typeof(self) weakSelf = self;
        [self.dataDetector imageLabelText:self enumerateMatchesInString:text usingBlock:^(NSRange range, NSTextCheckingType type) {
            __strong typeof(weakSelf) self = weakSelf;
            if (range.location != lastMatchingPosition) {
                NSString *prefix = [text sf_substringWithBeginIndex:lastMatchingPosition endIndex:range.location];
                [mutableAttrString appendAttributedString:[[NSAttributedString alloc] initWithString:prefix attributes:defaultAttrs]];
                tmpNumberOfExistsAttributedStrings += prefix.length;
            }
            
            NSUInteger location = tmpNumberOfExistsAttributedStrings + attrString.string.length;
            NSInteger length = range.length;
            [self.detectedDataStringRanges addObject:[NSValue valueWithRange:NSMakeRange(location, length)]];
            
            NSString *dataString = [text substringWithRange:range];
            BOOL highlighted = location == self.selectedDetectedDataStringRange.location && length == self.selectedDetectedDataStringRange.length;
            [mutableAttrString appendAttributedString:[self.dataDetector imageLabelText:self attributedStringForString:dataString type:type highlighted:highlighted]];
            tmpNumberOfExistsAttributedStrings += dataString.length;
            [self.keyDetectedDataStringValueType setObject:[NSNumber numberWithInteger:type] forKey:dataString];
            
            lastMatchingPosition = range.location + range.length;
        }];
        
        if (lastMatchingPosition != 0) {
            if (lastMatchingPosition != text.length) {
                [mutableAttrString appendAttributedString:[[NSAttributedString alloc] initWithString:[text substringFromIndex:lastMatchingPosition] attributes:defaultAttrs]];
            }
            attrString = mutableAttrString;
        }
    }
    if (attrString == nil) {
        attrString = [[NSAttributedString alloc] initWithString:text attributes:defaultAttrs];;
    }
    
    return attrString;
}

- (CGSize)size {
    return CGSizeMake(_width, _height);
}

- (SFImageLabelText *)textByAppendingText:(SFImageLabelText *)text {
    if (_attributedString == nil || text.attributedString == nil) {
        return nil;
    }
    SFImageLabelText *resultText = [SFImageLabelText new];
    
    NSMutableArray *resultImageAttributes = [NSMutableArray arrayWithArray:_imageAttributes];
    [resultImageAttributes addObjectsFromArray:text.imageAttributes];
    
    NSMutableAttributedString *resultAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:_attributedString];
    [resultAttributedString appendAttributedString:text.attributedString];
    
    resultText.attributedString = resultAttributedString;
    resultText.imageAttributes = resultImageAttributes;
    resultText.height = _height + text.height;
    resultText.width = _width;
    
    return resultText;
}

- (NSDictionary *)currentTextAttributes {
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)_font.fontName, _font.pointSize, NULL);
    NSDictionary *defaultTextAttrs = @{(id)kCTForegroundColorAttributeName : (__bridge id)_textColor.CGColor , (id)kCTFontAttributeName : (__bridge id)fontRef};
    CFRelease(fontRef);
    
    return defaultTextAttrs;
}

@end

@interface SFImageLabel () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CTFrameRef drawnFrame;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation SFImageLabel

- (void)dealloc {
    if (_drawnFrame) {
        CFRelease(_drawnFrame);
    }
}

- (id)init {
    self = [self initWithFrame:CGRectZero];
    
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
    self.highlightedTextBackgroundColor = [UIColor colorWithRed:0 green:0 blue:1.0f alpha:.20f];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizerTrigger:)];
    __weak typeof(self) weakSelf = self;
    [SFTrackProperty(self, detectedDataStringInteractable) change:^(id value) {
        __strong typeof(weakSelf) self = weakSelf;
        self.tapGestureRecognizer.enabled = [value boolValue];
    }];
    self.tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self initialize];
    
    return self;
}

- (void)setText:(SFImageLabelText *)text {
    _text = text;
    
    self.text.selectedDetectedDataStringRange = NSMakeRange(NSNotFound, 0);
    
    [self setNeedsDisplay];
}

- (NSRange)_selectedDetectedDataStringWithLocation:(CGPoint)location {
    NSRange stringRange = NSMakeRange(NSNotFound, 0);
    
    location.y = self.text.size.height - location.y;
    
    CFArrayRef lines = CTFrameGetLines(_drawnFrame);
    
    CGPoint origins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(_drawnFrame, CFRangeMake(0, 0), origins);
    
    CTLineRef line = NULL;
    CGPoint lineOrigin = CGPointZero;
    CGFloat paddingTop = 0;
    const NSInteger numberOfLines = CFArrayGetCount(lines);
    CGFloat separatedLineY[numberOfLines];
    for (NSInteger i = numberOfLines - 1; i >= 0; --i) {
        CGPoint origin = origins[i];
        if (paddingTop == 0) {
            paddingTop = origin.y;
        }
        CGFloat lineY = origin.y - paddingTop;
        separatedLineY[numberOfLines - 1 - i] = lineY;
    }
    
    BOOL collapsed = self.numberOfVisibleLines != 0;
    if (collapsed) {
        location.y = self.text.size.height - location.y;
    }
    for (NSInteger i = 0; i < numberOfLines; ++i) {
        CGFloat y = separatedLineY[i];
        CGFloat height = (i + 1) == numberOfLines ? (self.text.size.height - y) : (separatedLineY[i + 1] - y);
        if (location.y >= y && location.y <= y + height) {
            NSInteger lineIndex = collapsed ? i : (numberOfLines - i - 1);
            line = CFArrayGetValueAtIndex(lines, lineIndex);
            lineOrigin = origins[lineIndex];
            
            break;
        }
    }
    
    location.x -= lineOrigin.x;
    CFIndex index = CTLineGetStringIndexForPosition(line, location);
    NSString *string = self.text.attributedString.string;
    if (index < string.length) {
        for (NSValue *dataStringRange in self.text.detectedDataStringRanges) {
            NSRange range = [dataStringRange rangeValue];
            if (index >= range.location && index < range.location + range.length) {
                stringRange = range;
                break;
            }
        }
    }
    
    return stringRange;
}

- (void)_tapGestureRecognizerTrigger:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self];
    
    if (self.detectedDataStringInteractable) {
        NSRange stringRange = [self _selectedDetectedDataStringWithLocation:location];
        if (stringRange.location != NSNotFound) {
            NSString *dataString = [self.text.attributedString.string substringWithRange:stringRange];
            if ([self.delegate respondsToSelector:@selector(imageLabel:didSelectDetectedDataString:type:)]) {
                [self.delegate imageLabel:self didSelectDetectedDataString:dataString type:[[[self.text keyDetectedDataStringValueType] objectForKey:dataString] integerValue]];
            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.detectedDataStringInteractable) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        
        NSRange stringRange = [self _selectedDetectedDataStringWithLocation:location];
        if (stringRange.location != NSNotFound) {
            self.text.selectedDetectedDataStringRange = stringRange;
            [self.text build];
            [self setNeedsDisplay];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (self.detectedDataStringInteractable) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        
        [self _touchesEndWithLocation:location cancelled:YES];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.detectedDataStringInteractable) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        
        [self _touchesEndWithLocation:location cancelled:NO];
    }
}

- (void)_touchesEndWithLocation:(CGPoint)location cancelled:(BOOL)cancelled {
    self.text.selectedDetectedDataStringRange = NSMakeRange(NSNotFound, 0);
    [self.text build];
    [self setNeedsDisplay];
}

- (void)setDrawnFrame:(CTFrameRef)drawnFrame {
    if (_drawnFrame != drawnFrame) {
        if (_drawnFrame) {
            CFRelease(_drawnFrame);
            _drawnFrame = NULL;
        }
        CFRetain(drawnFrame);
        _drawnFrame = drawnFrame;
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (_text == nil) {
        return;
    }
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_text.attributedString);
    
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                               CFRangeMake(0, _text.attributedString.length),
                                                               NULL,
                                                               CGSizeMake(self.frame.size.width, CGFLOAT_MAX),
                                                               NULL);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _text.attributedString.length), path, NULL);
    CFRelease(path);
    CFRelease(framesetter);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    const NSInteger numberOfCTLines = CFArrayGetCount(lines);
    
    CGPoint lineOrigins[numberOfCTLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    BOOL ios7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f;
    
    for (NSInteger lineIndex = 0; lineIndex < numberOfCTLines && (_numberOfVisibleLines > 0 ? lineIndex < _numberOfVisibleLines : YES); lineIndex++) {
        CTLineRef line = CFRetain(CFArrayGetValueAtIndex(lines, lineIndex));

        if (_numberOfVisibleLines != numberOfCTLines && lineIndex == _numberOfVisibleLines - 1) {
            CFRange lineStringRange = CTLineGetStringRange(line);
            NSString *lineString = [[self.text.attributedString string] substringWithRange:NSMakeRange(lineStringRange.location, lineStringRange.length)];
            NSString *lastChar = [lineString substringFromIndex:lineString.length - 1];
            if ([lastChar isEqualToString:@"\n"]) {
                CFAttributedStringRef newAttrStringRef = CFAttributedStringCreateWithSubstring(NULL, (__bridge CFAttributedStringRef)_text.attributedString, CFRangeMake(lineStringRange.location, lineStringRange.length - 1));
                CFRelease(line);
                line = CTLineCreateWithAttributedString(newAttrStringRef);
                CFRelease(newAttrStringRef);
            }
            
            NSAttributedString *truncatedString = [[NSAttributedString alloc] initWithString:@"\u2026" attributes:[self.text currentTextAttributes]];
            CTLineRef token = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncatedString);
            CGRect tokenBounds = CTLineGetBoundsWithOptions(token, 0);
            CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
            CTLineRef newline = CTLineCreateTruncatedLine(line, lineBounds.size.width - tokenBounds.size.width, kCTLineTruncationEnd, token);
            CFRelease(token);
            
            if (newline) {
                CFRelease(line);
                line = newline;
            }
        }
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        
        NSMutableArray *textRuns = [NSMutableArray array];
        NSMutableArray *runRects = [NSMutableArray array];
        NSMutableArray *textRunPositionAndHeights = [NSMutableArray array];
        
        CGFloat maxImageHeight = 0;
        for (NSInteger runIndex = 0; runIndex < CFArrayGetCount(runs); runIndex++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[lineIndex];
            CTRunRef run = CFArrayGetValueAtIndex(runs, runIndex);
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
            runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y + runDescent, runRect.size.width, runAscent);
            
            id refCon = (__bridge id)(CTRunDelegateGetRefCon((__bridge CTRunDelegateRef)([(__bridge NSDictionary*)CTRunGetAttributes(run) valueForKey:(id)kCTRunDelegateAttributeName])));
            if (refCon) {
                SFImageAttribute *imageAttribute = refCon;
                UIImage *image = [_delegate imageLabel:self imageWithName:imageAttribute.imageName];
                if (image) {
                    CGRect drawImageRect = CGRectMake(runRect.origin.x,
                                                      runRect.origin.y,
                                                      _drawsImageWithImageSize ? image.size.width : runRect.size.width,
                                                      _drawsImageWithImageSize ? image.size.height : runRect.size.height);
                    CGContextDrawImage(context, drawImageRect, image.CGImage);
                    if (runRect.size.height > maxImageHeight) {
                        maxImageHeight = runRect.size.height;
                    }
                }
            } else {
                [textRuns addObject:[NSValue valueWithPointer:run]];
                [runRects addObject:[NSValue valueWithCGRect:runRect]];
                [textRunPositionAndHeights addObject:[NSValue valueWithCGRect:CGRectMake(lineOrigin.x, lineOrigin.y, 0, runRect.size.height - runDescent)]];
            }
        }
        
        CGFloat maxHighlightedRunHeight = 0;
        if (self.text.selectedDetectedDataStringRange.location != NSNotFound) {
            for (NSInteger runIndex = 0; runIndex < textRuns.count; ++runIndex) {
                CTRunRef run = [[textRuns objectAtIndex:runIndex] pointerValue];
                
                CFRange runTextRange = CTRunGetStringRange(run);
                if (self.text.selectedDetectedDataStringRange.location != NSNotFound
                    && runTextRange.location >= self.text.selectedDetectedDataStringRange.location
                    && runTextRange.location + runTextRange.length <= self.text.selectedDetectedDataStringRange.location + self.text.selectedDetectedDataStringRange.length) {
                    
                    CGRect runRect = [[runRects objectAtIndex:runIndex] CGRectValue];
                    runRect.size.height += 4;
                    
                    if (runRect.size.height > maxHighlightedRunHeight) {
                        maxHighlightedRunHeight = runRect.size.height;
                    }
                }
            }
        }
        
        for (NSInteger runIndex = 0; runIndex < textRuns.count; ++runIndex) {
            CTRunRef run = [[textRuns objectAtIndex:runIndex] pointerValue];
            CGRect runPositionAndHeight = [[textRunPositionAndHeights objectAtIndex:runIndex] CGRectValue];
            
            CFRange runTextRange = CTRunGetStringRange(run);
            CGFloat runY = runPositionAndHeight.origin.y + (maxImageHeight != 0 ? (fabs(maxImageHeight - runPositionAndHeight.size.height) / 2)  : 0);
            CGRect runRect = [[runRects objectAtIndex:runIndex] CGRectValue];
            runRect.origin.y = runY - 4;
            runRect.origin.x -= 0;
            runRect.size.width += 0;
            runRect.size.height = maxHighlightedRunHeight;
            
            BOOL runHighlighted = NO;
            if (self.text.selectedDetectedDataStringRange.location != NSNotFound
                && runTextRange.location >= self.text.selectedDetectedDataStringRange.location
                && runTextRange.location + runTextRange.length <= self.text.selectedDetectedDataStringRange.location + self.text.selectedDetectedDataStringRange.length) {
                runHighlighted = YES;
            }
            if (runHighlighted) {
                // draw background color
                UIColor *highlightColor = nil;
                if ([self.delegate respondsToSelector:@selector(imageLabel:highlightedTextBackgroundColorForDetectedDataString:type:)]) {
                    NSRange stringRange = self.text.selectedDetectedDataStringRange;
                    if (stringRange.location != NSNotFound) {
                        NSString *dataString = [self.text.attributedString.string substringWithRange:stringRange];
                        highlightColor = [self.delegate imageLabel:self highlightedTextBackgroundColorForDetectedDataString:dataString
                                                              type:[[[self.text keyDetectedDataStringValueType] objectForKey:dataString] integerValue]];
                    }
                }
                if (highlightColor == nil) {
                    highlightColor = self.highlightedTextBackgroundColor;
                }
                CGContextSetFillColorWithColor(context, highlightColor.CGColor);
                CGContextFillRect(context, runRect);
            }
            
            // draw underline for ios 6 or earlier
            if (!ios7) {
                NSDictionary *attr = (__bridge id)CTRunGetAttributes(run);
                NSNumber *underline = [attr objectForKey:(__bridge id)kCTUnderlineStyleAttributeName];
                if (underline && [underline integerValue] == 1) {
                    CGColorRef foregroundColor = (__bridge CGColorRef)[attr objectForKey:(__bridge id)kCTForegroundColorAttributeName];
                    
                    CGContextSetLineWidth(context, 1);
                    CGContextSetStrokeColorWithColor(context, foregroundColor);
                    CGContextBeginPath(context);
                    CGContextMoveToPoint(context, runRect.origin.x, runRect.origin.y + 1);
                    CGContextAddLineToPoint(context, runRect.origin.x + runRect.size.width, runRect.origin.y + 1);
                    CGContextClosePath(context);
                    CGContextDrawPath(context, kCGPathStroke);
                }
            }
            
            // draw text
            CGContextSetTextPosition(context, runPositionAndHeight.origin.x, runY);
            CTRunDraw(run, context, CFRangeMake(0, 0));
        }
        CFRelease(line);
    }
    
    self.drawnFrame = frame;
    CFRelease(frame);
}

- (NSInteger)numberOfLines {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_text.attributedString);
    
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                               CFRangeMake(0, _text.attributedString.length),
                                                               NULL,
                                                               CGSizeMake(self.frame.size.width, CGFLOAT_MAX),
                                                               NULL);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _text.attributedString.length), path, NULL);
    CFRelease(path);
    CFRelease(framesetter);
    
    NSInteger numberOfLines = 0;
    
    CFArrayRef lines = CTFrameGetLines(frame);
    numberOfLines = CFArrayGetCount(lines);
    
    CFRelease(frame);
    
    return numberOfLines;
}

- (CGFloat)heightOfTextWithNumberOfVisibleLines:(NSInteger)numberOfVisibleLines {
    CGFloat height = 0;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_text.attributedString);
    
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                               CFRangeMake(0, _text.attributedString.length),
                                                               NULL,
                                                               CGSizeMake(self.frame.size.width, CGFLOAT_MAX),
                                                               NULL);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _text.attributedString.length), path, NULL);
    CFRelease(path);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    const NSInteger numberOfLines = CFArrayGetCount(lines);
    
    if (numberOfVisibleLines != 0 && numberOfVisibleLines < numberOfLines) {
        NSInteger lastLineIndex = numberOfVisibleLines - 1;
        CTLineRef lastLine = CFArrayGetValueAtIndex(lines, lastLineIndex);
        CFRange lastLineStringRange = CTLineGetStringRange(lastLine);
        CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, lastLineStringRange.location + lastLineStringRange.length), NULL, CGSizeMake(self.frame.size.width, CGFLOAT_MAX), NULL);
        height = size.height;
    } else {
        height = self.text.size.height;
    }
    
    CFRelease(framesetter);
    CFRelease(frame);
    
    return height;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceiveTouch = NO;
    if (self.detectedDataStringInteractable) {
        CGPoint location = [touch locationInView:self];
        
        NSRange stringRange = [self _selectedDetectedDataStringWithLocation:location];
        if (stringRange.location != NSNotFound) {
            shouldReceiveTouch = YES;
        }
    }
    
    return shouldReceiveTouch;
}

@end
