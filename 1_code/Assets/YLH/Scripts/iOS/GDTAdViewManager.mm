//
//  GDTAdViewManager.m
//
//  Created by holdenjing on 2020/7/20.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDTUnifiedBannerView.h"
#import "UnityAppController.h"

#if defined (__cplusplus)
extern "C" {
#endif

void GDT_UnionPlatform_Ad_ShowAdView(UIView *adView) {
    [GetAppController().rootViewController.view addSubview:adView];
}

#if defined (__cplusplus)
}
#endif

