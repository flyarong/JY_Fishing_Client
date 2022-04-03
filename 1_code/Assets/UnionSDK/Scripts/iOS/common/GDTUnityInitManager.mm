//
//  UnityInitManager.m
//
//  Created by holdenjing on 2020/7/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDTSDKConfig.h"

#if defined (__cplusplus)
extern "C" {
#endif

void registerAppId(const char *appId) {
    NSString *appIdStr = [NSString stringWithUTF8String:appId];
    [GDTSDKConfig registerAppId:appIdStr];
}

#if defined (__cplusplus)
}
#endif
