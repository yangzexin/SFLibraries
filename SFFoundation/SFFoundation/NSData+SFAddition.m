//
//  NSData+SFAddition.m
//  SimpleFramework
//
//  Created by yangzexin on 10/23/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "NSData+SFAddition.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (SFAddition)

- (NSString *)sf_hexRepresentation
{
    const unsigned char *bytes = (unsigned char *)[self bytes];
    NSMutableString *hexString = [NSMutableString string];
    for (NSInteger i = 0; i < [self length]; ++i) {
        [hexString appendFormat:@"%02x", bytes[i]];
    }
    return [NSString stringWithFormat:@"%@", hexString];
}

- (NSData *)sf_dataByEncryptingUsingMD5
{
    unsigned char result[16];
    CC_MD5(self.bytes, (CC_LONG)self.length, result);
    return [NSData dataWithBytes:result length:16];
}

- (NSData *)sf_dataByExchangingByteHigh4ToLow4
{
    const unsigned char *bytes = (unsigned char *)[self bytes];
    unsigned char *resultBytes = malloc(sizeof(unsigned char) * [self length]);
    
    for (NSInteger i = 0; i < [self length]; ++i) {
        unsigned char originalByte = *(bytes + i);
        unsigned char exchangedByte = ((originalByte & 0xf0) >> 4) + ((originalByte & 0xf) << 4);
        *(resultBytes + i) = exchangedByte;
    }
    
    NSData *data = [NSData dataWithBytes:resultBytes length:[self length]];
    free(resultBytes);
    return data;
}

- (NSData *)sf_dataByPerformingDESOperation:(CCOperation)operation key:(NSString *)key
{
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeDES;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t bufferNumBytes;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          NULL,
                                          [self bytes],
                                          [self length],
                                          buffer,
                                          bufferSize,
                                          &bufferNumBytes);
    
    NSData *resultData = nil;
    if(cryptStatus == kCCSuccess) {
        resultData = [NSData dataWithBytes:buffer length:bufferNumBytes];
    }
    
    free(buffer);
    
    return resultData;
}

@end
