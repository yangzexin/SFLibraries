//
//  NSData+SFAddition.h
//  SimpleFramework
//
//  Created by yangzexin on 10/23/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (SFAddition)

- (NSString *)sf_hexRepresentation;

- (NSData *)sf_dataByEncryptingUsingMD5;

- (NSData *)sf_dataByPerformingDESOperation:(CCOperation)operation key:(NSString *)key;

- (NSData *)sf_dataByExchangingByteHigh4ToLow4;

@end
