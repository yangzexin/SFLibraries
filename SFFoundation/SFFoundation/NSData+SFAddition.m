//
//  NSData+SFAddition.m
//  SFFoundation
//
//  Created by yangzexin on 10/23/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "NSData+SFAddition.h"

#import <CommonCrypto/CommonDigest.h>

char _SFCustomHexCharForByte(unsigned char c, const char *customHexList) {
    return *(customHexList + c);
}

unsigned char _SFByteForCustomHexChar(char c, const char *customHexList) {
    size_t len = strlen(customHexList);
    for(int i = 0; i < len; ++i){
        if(c == *(customHexList + i)){
            return i;
        }
    }
    
    return 0;
}

NSString *SFHexStringByEncodingData(NSData *data, const char *customHexList) {
    unsigned char *bytes = malloc(sizeof(unsigned char) * [data length]);
    [data getBytes:bytes length:data.length];
    
    size_t len = sizeof(char) * [data length] * 2 + 1;
    char *result = malloc(len);
    for(int i = 0; i < [data length]; ++i){
        unsigned char tmp = *(bytes + i);
        unsigned char low = tmp & 0xF;
        unsigned char high = (tmp & 0xF0) >> 4;
        *(result + i * 2) = _SFCustomHexCharForByte(low, customHexList);
        *(result + i * 2 + 1) = _SFCustomHexCharForByte(high, customHexList);
    }
    free(bytes);
    
    *(result + len - 1) = '\0';
    
    NSString *str = [NSString stringWithUTF8String:result];
    free(result);
    
    return str;
}

NSData *SFDataByDecodingHexString(NSString *string, const char *customHexList) {
    if([string isEqualToString:@""]){
        return nil;
    }
    if([string length] % 2 != 0){
        return nil;
    }
    size_t resultBytesLen = sizeof(char) * [string length] / 2;
    char *resultBytes = malloc(resultBytesLen);
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    char *bytes = malloc(sizeof(char) * [data length]);
    [data getBytes:bytes length:data.length];
    for(int i = 0, j = 0; i < [data length]; i += 2, ++j){
        unsigned char low = _SFByteForCustomHexChar(*(bytes + i), customHexList);
        unsigned char high = _SFByteForCustomHexChar(*(bytes + i + 1), customHexList);
        unsigned char tmp = ((high << 4) & 0xF0) + low;
        *(resultBytes + j) = tmp;
    }
    
    free(bytes);
    
    NSData *resultData = [NSData dataWithBytes:resultBytes length:resultBytesLen];
    free(resultBytes);
    
    return resultData;
}

@implementation NSData (SFAddition)

- (NSString *)sf_hexRepresentation {
    const unsigned char *bytes = (unsigned char *)[self bytes];
    NSMutableString *hexString = [NSMutableString string];
    for (NSInteger i = 0; i < [self length]; ++i) {
        [hexString appendFormat:@"%02x", bytes[i]];
    }
    
    return [NSString stringWithFormat:@"%@", hexString];
}

- (NSData *)sf_dataByEncryptingUsingMD5 {
    unsigned char result[16];
    CC_MD5(self.bytes, (CC_LONG)self.length, result);
    
    return [NSData dataWithBytes:result length:16];
}

- (NSData *)sf_dataByExchangingByteHigh4ToLow4 {
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

- (NSData *)sf_dataByPerformingDESOperation:(CCOperation)operation key:(NSString *)key {
    return [self sf_dataByPerformingDESOperation:operation options:kCCOptionPKCS7Padding | kCCOptionECBMode key:key];
}

- (NSData *)sf_dataByPerformingDESOperation:(CCOperation)operation options:(CCOptions)options key:(NSString *)key {
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeDES;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t bufferNumBytes;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmDES,
                                          options,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          NULL,
                                          [self bytes],
                                          [self length],
                                          buffer,
                                          bufferSize,
                                          &bufferNumBytes);
    
    NSData *resultData = nil;
    if (cryptStatus == kCCSuccess) {
        resultData = [NSData dataWithBytes:buffer length:bufferNumBytes];
    }
    
    free(buffer);
    
    return resultData;
}

@end
