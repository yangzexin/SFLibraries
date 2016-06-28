//
//  UIDevice+SFUDID.m
//  SFiOSKit
//
//  Created by yangzexin on 11/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "UIDevice+SFUDID.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import <SFFoundation/SFFoundation.h>

#import "SFKeychainAccess.h"

@implementation UIDevice (SFUDID)

- (NSString *)_macAddress {
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return outstring;
}

- (NSString *)_sf_UDIDFromFile {
    return [[NSUserDefaults standardUserDefaults] safe_stringForKey:@"sf_udid"];
}

- (void)_sf_saveUDIDToLocalFile:(NSString *)udid {
    [[NSUserDefaults standardUserDefaults] safe_setString:udid forKey:@"sf_udid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)sf_UDID {
    NSString *UDIDString = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
        UDIDString = [[self _macAddress] sf_stringByEncryptingUsingMD5];
    } else {
        UDIDString = [self _sf_UDIDFromFile];
        if ([UDIDString length] == 0) {
            UDIDString = [[self identifierForVendor] UUIDString];
            [self _sf_saveUDIDToLocalFile:UDIDString];
        }
    }
    
    return UDIDString;
}

- (NSString *)sf_UDID_inKeychain {
    NSString *UDIDString = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
        UDIDString = [[self _macAddress] sf_stringByEncryptingUsingMD5];
    } else {
        UDIDString = [SFKeychainAccess stringForKey:@"sf_udid"];
        if ([UDIDString length] == 0) {
            UDIDString = [[self identifierForVendor] UUIDString];
            [SFKeychainAccess setString:UDIDString forKey:@"sf_udid"];
        }
    }
    
    return UDIDString;
}

@end
