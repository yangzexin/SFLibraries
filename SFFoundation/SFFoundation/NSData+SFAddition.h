//
//  NSData+SFAddition.h
//  SFFoundation
//
//  Created by yangzexin on 10/23/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

OBJC_EXPORT NSString *SFHexStringByEncodingData(NSData *data, const char *customHexList);
OBJC_EXPORT NSData *SFDataByDecodingHexString(NSString *string, const char *customHexList);

@interface NSData (SFAddition)

- (NSString *)sf_hexRepresentation;

- (NSData *)sf_dataByEncryptingUsingMD5;

- (NSData *)sf_dataByPerformingDESOperation:(CCOperation)operation key:(NSString *)key;
- (NSData *)sf_dataByPerformingDESOperation:(CCOperation)operation options:(CCOptions)options key:(NSString *)key;

- (NSData *)sf_dataByExchangingByteHigh4ToLow4;

@end
