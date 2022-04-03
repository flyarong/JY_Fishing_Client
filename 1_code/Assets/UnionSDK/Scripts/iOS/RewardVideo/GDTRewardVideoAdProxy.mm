//
//  RewardVideoAd.mm
//
//  Created by holdenjing on 2020/4/23.
//  Copyright © 2020 Tencent. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import "UnityAppController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GDTRewardVideoAd.h"
#import "GDTSDKConfig.h"

extern const char *GDTAutonomousStringCopy(const char *string);

typedef void(*gdt_rewardVideoAdDidLoad)(int context);
typedef void(*gdt_rewardVideoAdVideoDidLoad)(int context);
typedef void(*gdt_rewardVideoAdWillVisible)(int context);
typedef void(*gdt_rewardVideoAdDidExposed)(int context);
typedef void(*gdt_rewardVideoAdDidClose)(int context);
typedef void(*gdt_rewardVideoAdDidClicked)(int context);
typedef void(*gdt_rewardVideoAdDidFailWithError)(int code, const char *message, int context);
typedef void(*gdt_rewardVideoAdDidRewardEffective)(int context);
typedef void(*gdt_rewardVideoAdDidPlayFinish)(int context);

@interface GDTRewardVideoAdProxy : NSObject

@end

@interface GDTRewardVideoAdProxy () <GDTRewardedVideoAdDelegate>

@property (nonatomic, assign) int loadContext;

@property (nonatomic, assign) gdt_rewardVideoAdDidLoad onRewardVideoAdDidLoad;
@property (nonatomic, assign) gdt_rewardVideoAdVideoDidLoad onRewardVideoAdVideoDidLoad;
@property (nonatomic, assign) gdt_rewardVideoAdWillVisible onRewardVideoAdWillVisible;
@property (nonatomic, assign) gdt_rewardVideoAdDidExposed onRewardVideoAdDidExposed;
@property (nonatomic, assign) gdt_rewardVideoAdDidClose onRewardVideoAdDidClose;
@property (nonatomic, assign) gdt_rewardVideoAdDidClicked onRewardVideoAdDidClicked;
@property (nonatomic, assign) gdt_rewardVideoAdDidFailWithError onRewardVideoAdDidFailWithError;
@property (nonatomic, assign) gdt_rewardVideoAdDidRewardEffective onRewardVideoAdDidRewardEffective;
@property (nonatomic, assign) gdt_rewardVideoAdDidPlayFinish onRewardVideoAdDidPlayFinish;

@property (nonatomic, strong) GDTRewardVideoAd *rewardVideoAd;

@end


@implementation GDTRewardVideoAdProxy

/**
 广告数据加载成功回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    NSLog(@"%s",__FUNCTION__);
    self.onRewardVideoAdDidLoad(self.loadContext);
}

/**
 视频数据下载成功回调，已经下载过的视频会直接回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    NSLog(@"%s",__FUNCTION__);
    self.onRewardVideoAdVideoDidLoad(self.loadContext);
}

/**
 视频播放页即将展示回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdWillVisible:(GDTRewardVideoAd *)rewardedVideoAd {
    NSLog(@"%s",__FUNCTION__);
    self.onRewardVideoAdWillVisible(self.loadContext);
}

/**
 视频广告曝光回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd {
    NSLog(@"%s",__FUNCTION__);
    self.onRewardVideoAdDidExposed(self.loadContext);
}

/**
 视频播放页关闭回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd {
    NSLog(@"%s",__FUNCTION__);
    self.onRewardVideoAdDidClose(self.loadContext);
}

/**
 视频广告信息点击回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd {
    NSLog(@"%s",__FUNCTION__);
    self.onRewardVideoAdDidClicked(self.loadContext);
}

/**
 视频广告各种错误信息回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 @param error 具体错误信息
 */
- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    self.onRewardVideoAdDidFailWithError((int)error.code, GDTAutonomousStringCopy([[error localizedDescription] UTF8String]), self.loadContext);
}

/**
 视频广告播放达到激励条件回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd {
    NSLog(@"%s",__FUNCTION__);
    self.onRewardVideoAdDidRewardEffective(self.loadContext);
}

/**
 视频广告视频播放完成

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd {
    NSLog(@"%s",__FUNCTION__);
    self.onRewardVideoAdDidPlayFinish(self.loadContext);
}

@end

#if defined (__cplusplus)
extern "C" {
#endif
GDTRewardVideoAdProxy* GDT_UnionPlatform_RewardVideoAd_Init(
    const char *placementId) {
    NSString *placementIDStr = [[NSString alloc] initWithUTF8String:placementId];
    GDTRewardVideoAd *rewardVideoAd = [[GDTRewardVideoAd alloc] initWithPlacementId:placementIDStr];
    GDTRewardVideoAdProxy *instance = [[GDTRewardVideoAdProxy alloc] init];
    instance.rewardVideoAd = rewardVideoAd;
    rewardVideoAd.delegate = instance;
    (__bridge_retained void*)instance;
    return instance;
}
    
void GDT_UnionPlatform_RewardVideoAd_LoadAd(
    void *rewardedVideoAdPtr,
    gdt_rewardVideoAdDidFailWithError onError,
    gdt_rewardVideoAdDidLoad onRewardVideoAdDidLoad,
    gdt_rewardVideoAdVideoDidLoad onRewardVideoAdVideoDidLoad,
    int context) {
    GDTRewardVideoAdProxy *instance = (__bridge GDTRewardVideoAdProxy*)rewardedVideoAdPtr;

    instance.onRewardVideoAdVideoDidLoad = onRewardVideoAdVideoDidLoad;
    instance.onRewardVideoAdDidFailWithError = onError;
    instance.onRewardVideoAdDidLoad = onRewardVideoAdDidLoad;
    instance.loadContext = context;

    [instance.rewardVideoAd loadAd];
}
      
void GDT_UnionPlatform_RewardVideoAd_SetRewardVideoAdListener(
    void *rewardedVideoAdPtr,
    gdt_rewardVideoAdWillVisible onAdWillVisible,
    gdt_rewardVideoAdDidClicked onAdDidClicked,
    gdt_rewardVideoAdDidClose onAdDidClose,
    gdt_rewardVideoAdDidPlayFinish onAdDidPlayFinish,
    gdt_rewardVideoAdDidExposed onRewardVideoAdDidExposed,
    gdt_rewardVideoAdDidRewardEffective onAdDidRewardEffective,
    gdt_rewardVideoAdDidFailWithError onAdDidFailWithError) {
    GDTRewardVideoAdProxy *rewardVideoAd = (__bridge GDTRewardVideoAdProxy*)rewardedVideoAdPtr;
    rewardVideoAd.onRewardVideoAdWillVisible = onAdWillVisible;
    rewardVideoAd.onRewardVideoAdDidClicked = onAdDidClicked;
    rewardVideoAd.onRewardVideoAdDidClose = onAdDidClose;
    rewardVideoAd.onRewardVideoAdDidPlayFinish = onAdDidPlayFinish;
    rewardVideoAd.onRewardVideoAdDidExposed = onRewardVideoAdDidExposed;
    rewardVideoAd.onRewardVideoAdDidRewardEffective = onAdDidRewardEffective;
    rewardVideoAd.onRewardVideoAdDidFailWithError = onAdDidFailWithError;
}

void GDT_UnionPlatform_RewardVideoAd_ShowRewardVideoAd(void *rewardedVideoAdPtr) {
    GDTRewardVideoAdProxy *rewardedVideoAd = (__bridge GDTRewardVideoAdProxy*)rewardedVideoAdPtr;
    [rewardedVideoAd.rewardVideoAd showAdFromRootViewController:GetAppController().rootViewController];
}

void GDT_UnionPlatform_RewardVideoAd_Dispose(void *rewardedVideoAdPtr) {
    (__bridge_transfer GDTRewardVideoAdProxy*)rewardedVideoAdPtr;
}
     
void GDT_UnionPlatform_RewardVideoAd_SetVideoMuted(
    void *rewardedVideoAdPtr,
    bool videoMuted) {
    GDTRewardVideoAdProxy *rewardedVideoAd = (__bridge GDTRewardVideoAdProxy*)rewardedVideoAdPtr;
    rewardedVideoAd.rewardVideoAd.videoMuted = videoMuted;
}

long GDT_UnionPlatform_RewardVideoAd_GetExpireTimestamp(void *rewardedVideoAdPtr) {
    GDTRewardVideoAdProxy *rewardedVideoAd = (__bridge GDTRewardVideoAdProxy*)rewardedVideoAdPtr;
    return rewardedVideoAd.rewardVideoAd.expiredTimestamp;
}

void GDT_UnionPlatform_RewardVideoAd_SetEnableDefaultAudioSessionSetting(bool audioSessionSetting) {
    [GDTSDKConfig enableDefaultAudioSessionSetting:audioSessionSetting];
}

const char* GDT_UnionPlatform_RewardVideoAd_GetECPMLevel(void *rewardedVideoAdPtr) {
    GDTRewardVideoAdProxy *rewardedVideoAd = (__bridge GDTRewardVideoAdProxy*)rewardedVideoAdPtr;
    return GDTAutonomousStringCopy([[rewardedVideoAd.rewardVideoAd eCPMLevel] UTF8String]);
}

#if defined (__cplusplus)
}
#endif
