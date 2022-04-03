//
//  UnifiedInterstitialAd.mm
//
//  Created by holdenjing on 2020/4/26.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnityAppController.h"
#import <UIKit/UIKit.h>
#import "GDTUnifiedInterstitialAd.h"

extern const char *GDTAutonomousStringCopy(const char *string);

typedef void(*gdt_InterstitialSuccessToLoadAd)(int context);
typedef void(*gdt_InterstitialFailToLoadAdWithError)(int code, const char *message, int context);
typedef void(*gdt_InterstitialWillPresentScreen)(int context);
typedef void(*gdt_InterstitialFailToPresentWithError)(int code, const char *message, int context);
typedef void(*gdt_InterstitialDidPresentScreen)(int context);
typedef void(*gdt_InterstitialDidDismissScreen)(int context);
typedef void(*gdt_InterstitialWillLeaveApplication)(int context);
typedef void(*gdt_InterstitialWillExposure)(int context);
typedef void(*gdt_InterstitialClicked)(int context);
typedef void(*gdt_InterstitialAdWillPresentFullScreenModal)(int context);
typedef void(*gdt_InterstitialAdDidPresentFullScreenModal)(int context);
typedef void(*gdt_InterstitialAdWillDismissFullScreenModal)(int context);
typedef void(*gdt_InterstitialAdDidDismissFullScreenModal)(int context);
typedef void(*gdt_InterstitialAdPlayerStatusChanged)(int context,int playerStatus);
typedef void(*gdt_InterstitialAdViewWillPresentVideoVC)(int context);
typedef void(*gdt_InterstitialAdViewDidPresentVideoVC)(int context);
typedef void(*gdt_InterstitialAdViewWillDismissVideoVC)(int context);
typedef void(*gdt_InterstitialAdViewDidDismissVideoVC)(int context);

@interface GDTUnifiedInterstitialAdProxy : NSObject

@end

@interface GDTUnifiedInterstitialAdProxy () <GDTUnifiedInterstitialAdDelegate>

@property (nonatomic, assign) int loadContext;

@property (nonatomic, assign) gdt_InterstitialSuccessToLoadAd onInterstitialSuccessToLoadAd;
@property (nonatomic, assign) gdt_InterstitialFailToLoadAdWithError onInterstitialFailToLoadAdWithError;
@property (nonatomic, assign) gdt_InterstitialWillPresentScreen onInterstitialWillPresentScreen;
@property (nonatomic, assign) gdt_InterstitialFailToPresentWithError onInterstitialFailToPresentWithError;
@property (nonatomic, assign) gdt_InterstitialDidPresentScreen onInterstitialDidPresentScreen;
@property (nonatomic, assign) gdt_InterstitialDidDismissScreen onInterstitialDidDismissScreen;
@property (nonatomic, assign) gdt_InterstitialWillLeaveApplication onInterstitialWillLeaveApplication;
@property (nonatomic, assign) gdt_InterstitialWillExposure onInterstitialWillExposure;
@property (nonatomic, assign) gdt_InterstitialClicked onInterstitialClicked;
@property (nonatomic, assign) gdt_InterstitialAdWillPresentFullScreenModal onInterstitialAdWillPresentFullScreenModal;
@property (nonatomic, assign) gdt_InterstitialAdDidPresentFullScreenModal onInterstitialAdDidPresentFullScreenModal;
@property (nonatomic, assign) gdt_InterstitialAdWillDismissFullScreenModal onInterstitialAdWillDismissFullScreenModal;
@property (nonatomic, assign) gdt_InterstitialAdDidDismissFullScreenModal onInterstitialAdDidDismissFullScreenModal;
@property (nonatomic, assign) gdt_InterstitialAdPlayerStatusChanged onInterstitialAdPlayerStatusChanged;
@property (nonatomic, assign) gdt_InterstitialAdViewWillPresentVideoVC onInterstitialAdViewWillPresentVideoVC;
@property (nonatomic, assign) gdt_InterstitialAdViewDidPresentVideoVC onInterstitialAdViewDidPresentVideoVC;
@property (nonatomic, assign) gdt_InterstitialAdViewWillDismissVideoVC onInterstitialAdViewWillDismissVideoVC;
@property (nonatomic, assign) gdt_InterstitialAdViewDidDismissVideoVC onInterstitialAdViewDidDismissVideoVC;

@property (nonatomic, strong) GDTUnifiedInterstitialAd *unifiedInterstitialAd;

@end

@implementation GDTUnifiedInterstitialAdProxy

/**
 *  插屏2.0广告预加载成功回调
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"eCPMLevel:%@", [unifiedInterstitial eCPMLevel]);
    NSLog(@"videoDuration:%lf isVideo: %@", unifiedInterstitial.videoDuration, @(unifiedInterstitial.isVideoAd));
    self.onInterstitialSuccessToLoadAd(self.loadContext);
}

/**
 *  插屏2.0广告预加载失败回调
 *  当接收服务器返回的广告数据失败后调用该函数
 */
- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"interstitial fail to load, Error : %@",error);
    self.onInterstitialFailToLoadAdWithError((int)error.code, GDTAutonomousStringCopy([[error localizedDescription] UTF8String]), self.loadContext);
}

/**
 *  插屏2.0广告将要展示回调
 *  插屏2.0广告即将展示回调该函数
 */
- (void)unifiedInterstitialWillPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialWillPresentScreen(self.loadContext);
}

/**
 *  插屏2.0广告视图展示失败回调
 *  插屏2.0广告展示失败回调该函数
 */
- (void)unifiedInterstitialFailToPresent:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialFailToPresentWithError((int)error.code, GDTAutonomousStringCopy([[error localizedDescription] UTF8String]), self.loadContext);
}

/**
 *  插屏2.0广告视图展示成功回调
 *  插屏2.0广告展示成功回调该函数
 */
- (void)unifiedInterstitialDidPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialDidPresentScreen(self.loadContext);
}

/**
 *  插屏2.0广告展示结束回调
 *  插屏2.0广告展示结束回调该函数
 */
- (void)unifiedInterstitialDidDismissScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialDidDismissScreen(self.loadContext);
}

/**
 *  当点击下载应用时会调用系统程序打开
 */
- (void)unifiedInterstitialWillLeaveApplication:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialWillLeaveApplication(self.loadContext);
}

/**
 *  插屏2.0广告曝光回调
 */
- (void)unifiedInterstitialWillExposure:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialWillExposure(self.loadContext);
}

/**
 *  插屏2.0广告点击回调
 */
- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialClicked(self.loadContext);
}

/**
 *  点击插屏2.0广告以后即将弹出全屏广告页
 */
- (void)unifiedInterstitialAdWillPresentFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialAdWillPresentFullScreenModal(self.loadContext);
}

/**
 *  点击插屏2.0广告以后弹出全屏广告页
 */
- (void)unifiedInterstitialAdDidPresentFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialAdDidPresentFullScreenModal(self.loadContext);
}

/**
 *  全屏广告页将要关闭
 */
- (void)unifiedInterstitialAdWillDismissFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialAdWillDismissFullScreenModal(self.loadContext);
}

/**
 *  全屏广告页被关闭
 */
- (void)unifiedInterstitialAdDidDismissFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialAdDidDismissFullScreenModal(self.loadContext);
}


/**
 * 插屏2.0视频广告 player 播放状态更新回调
 */
- (void)unifiedInterstitialAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial playerStatusChanged:(GDTMediaPlayerStatus)status
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialAdPlayerStatusChanged(self.loadContext,(int)status);
}

/**
 * 插屏2.0视频广告详情页 WillPresent 回调
 */
- (void)unifiedInterstitialAdViewWillPresentVideoVC:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialAdViewWillPresentVideoVC(self.loadContext);
}

/**
 * 插屏2.0视频广告详情页 DidPresent 回调
 */
- (void)unifiedInterstitialAdViewDidPresentVideoVC:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialAdViewDidPresentVideoVC(self.loadContext);
}

/**
 * 插屏2.0视频广告详情页 WillDismiss 回调
 */
- (void)unifiedInterstitialAdViewWillDismissVideoVC:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialAdViewWillDismissVideoVC(self.loadContext);
}

/**
 * 插屏2.0视频广告详情页 DidDismiss 回调
 */
- (void)unifiedInterstitialAdViewDidDismissVideoVC:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    NSLog(@"%s",__FUNCTION__);
    self.onInterstitialAdViewDidDismissVideoVC(self.loadContext);
}

@end


#if defined (__cplusplus)
extern "C" {
#endif

GDTUnifiedInterstitialAdProxy* GDT_UnionPlatform_UnifiedInterstitialAd_Init(
    const char *placementId) {
    NSString *placementIdStr = [[NSString alloc] initWithUTF8String:placementId];
    GDTUnifiedInterstitialAd *unifiedInterstitialAd = [[GDTUnifiedInterstitialAd alloc] initWithPlacementId:placementIdStr];
    GDTUnifiedInterstitialAdProxy* instance = [[GDTUnifiedInterstitialAdProxy alloc] init];
    instance.unifiedInterstitialAd = unifiedInterstitialAd;
    unifiedInterstitialAd.delegate = instance;
    (__bridge_retained void*)instance;
    return instance;
}
      
void GDT_UnionPlatform_UnifiedInterstitialAd_LoadAd(
    void *unifiedInterstitialAdPtr,
    gdt_InterstitialSuccessToLoadAd onInterstitialSuccessToLoadAd,
    gdt_InterstitialFailToLoadAdWithError onInterstitialFailToLoadAdWithError,
    int context) {
    GDTUnifiedInterstitialAdProxy *instance = (__bridge GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;
    instance.onInterstitialSuccessToLoadAd = onInterstitialSuccessToLoadAd;
    instance.onInterstitialFailToLoadAdWithError = onInterstitialFailToLoadAdWithError;
    instance.loadContext = context;
    [instance.unifiedInterstitialAd loadAd];
}
 
void GDT_UnionPlatform_UnifiedInterstitialAd_LoadFullScreenAd(
    void *unifiedInterstitialAdPtr,
    gdt_InterstitialSuccessToLoadAd onInterstitialSuccessToLoadAd,
    gdt_InterstitialFailToLoadAdWithError onInterstitialFailToLoadAdWithError,
    int context) {
    GDTUnifiedInterstitialAdProxy *instance = (__bridge GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;
    instance.onInterstitialSuccessToLoadAd = onInterstitialSuccessToLoadAd;
    instance.onInterstitialFailToLoadAdWithError = onInterstitialFailToLoadAdWithError;
    instance.loadContext = context;
    [instance.unifiedInterstitialAd loadFullScreenAd];
}
   
void GDT_UnionPlatform_UnifiedInterstitialAd_ShowAd(
    void *unifiedInterstitialAdPtr) {
    GDTUnifiedInterstitialAdProxy *unifiedInterstitialAd = (__bridge GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;
    [unifiedInterstitialAd.unifiedInterstitialAd presentAdFromRootViewController:GetAppController().rootViewController];
}
       
void GDT_UnionPlatform_UnifiedInterstitialAd_ShowFullScreenAd(
    void *unifiedInterstitialAdPtr) {
    GDTUnifiedInterstitialAdProxy *unifiedInterstitialAd = (__bridge GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;
    [unifiedInterstitialAd.unifiedInterstitialAd presentFullScreenAdFromRootViewController:GetAppController().rootViewController];
}

void GDT_UnionPlatform_UnifiedInterstitialAd_Dispose(void *unifiedInterstitialAdPtr) {
    (__bridge_transfer GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;
}

void GDT_UnionPlatform_UnifiedInterstitialAd_SetInteractionListener(
    void *unifiedInterstitialAdPtr,
    gdt_InterstitialWillPresentScreen onInterstitialWillPresentScreen,
    gdt_InterstitialFailToPresentWithError onInterstitialFailToPresentWithError,
    gdt_InterstitialDidPresentScreen onInterstitialDidPresentScreen,
    gdt_InterstitialDidDismissScreen onInterstitialDidDismissScreen,
    gdt_InterstitialWillLeaveApplication onInterstitialWillLeaveApplication,
    gdt_InterstitialWillExposure onInterstitialWillExposure,
    gdt_InterstitialClicked onInterstitialClicked,
    gdt_InterstitialAdWillPresentFullScreenModal onInterstitialAdWillPresentFullScreenModal,
    gdt_InterstitialAdDidPresentFullScreenModal onInterstitialAdDidPresentFullScreenModal,
    gdt_InterstitialAdWillDismissFullScreenModal onInterstitialAdWillDismissFullScreenModal,
    gdt_InterstitialAdDidDismissFullScreenModal onInterstitialAdDidDismissFullScreenModal,
    gdt_InterstitialAdPlayerStatusChanged onInterstitialAdPlayerStatusChanged,
    gdt_InterstitialAdViewWillPresentVideoVC onInterstitialAdViewWillPresentVideoVC,
    gdt_InterstitialAdViewDidPresentVideoVC onInterstitialAdViewDidPresentVideoVC,
    gdt_InterstitialAdViewWillDismissVideoVC onInterstitialAdViewWillDismissVideoVC,
    gdt_InterstitialAdViewDidDismissVideoVC onInterstitialAdViewDidDismissVideoVC) {
    GDTUnifiedInterstitialAdProxy *unifiedInterstitialAd = (__bridge GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;

    unifiedInterstitialAd.onInterstitialWillPresentScreen = onInterstitialWillPresentScreen;
    unifiedInterstitialAd.onInterstitialFailToPresentWithError = onInterstitialFailToPresentWithError;
    unifiedInterstitialAd.onInterstitialDidPresentScreen = onInterstitialDidPresentScreen;
    unifiedInterstitialAd.onInterstitialDidDismissScreen = onInterstitialDidDismissScreen;
    unifiedInterstitialAd.onInterstitialWillLeaveApplication = onInterstitialWillLeaveApplication;
    unifiedInterstitialAd.onInterstitialWillExposure = onInterstitialWillExposure;
    unifiedInterstitialAd.onInterstitialClicked = onInterstitialClicked;
    unifiedInterstitialAd.onInterstitialAdWillPresentFullScreenModal = onInterstitialAdWillPresentFullScreenModal;
    unifiedInterstitialAd.onInterstitialAdDidPresentFullScreenModal = onInterstitialAdDidPresentFullScreenModal;
    unifiedInterstitialAd.onInterstitialAdWillDismissFullScreenModal = onInterstitialAdWillDismissFullScreenModal;
    unifiedInterstitialAd.onInterstitialAdDidDismissFullScreenModal = onInterstitialAdDidDismissFullScreenModal;
    unifiedInterstitialAd.onInterstitialAdPlayerStatusChanged = onInterstitialAdPlayerStatusChanged;
    unifiedInterstitialAd.onInterstitialAdViewWillPresentVideoVC = onInterstitialAdViewWillPresentVideoVC;
    unifiedInterstitialAd.onInterstitialAdViewDidPresentVideoVC = onInterstitialAdViewDidPresentVideoVC;
    unifiedInterstitialAd.onInterstitialAdViewWillDismissVideoVC = onInterstitialAdViewWillDismissVideoVC;
    unifiedInterstitialAd.onInterstitialAdViewDidDismissVideoVC = onInterstitialAdViewDidDismissVideoVC;
}

void GDT_UnionPlatform_UnifiedInterstitialAd_SetMinVideoDuration(
    void *unifiedInterstitialAdPtr,
    int minVideoDuration) {
    GDTUnifiedInterstitialAdProxy *unifiedInterstitialAd = (__bridge GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;
    unifiedInterstitialAd.unifiedInterstitialAd.minVideoDuration = minVideoDuration;
}

void GDT_UnionPlatform_UnifiedInterstitialAd_SetMaxVideoDuration(
    void *unifiedInterstitialAdPtr,
    int maxVideoDuration) {
    GDTUnifiedInterstitialAdProxy *unifiedInterstitialAd = (__bridge GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;
    unifiedInterstitialAd.unifiedInterstitialAd.maxVideoDuration = maxVideoDuration;
}

void GDT_UnionPlatform_UnifiedInterstitialAd_SetVideoMuted(
    void *unifiedInterstitialAdPtr,
    bool videoMuted) {
    GDTUnifiedInterstitialAdProxy *unifiedInterstitialAd = (__bridge GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;
    unifiedInterstitialAd.unifiedInterstitialAd.videoMuted = videoMuted;
}

void GDT_UnionPlatform_UnifiedInterstitialAd_SetDetailPageVideoMuted(
    void *unifiedInterstitialAdPtr,
    bool detailPageVideoMuted) {
    GDTUnifiedInterstitialAdProxy *unifiedInterstitialAd = (__bridge GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;
    unifiedInterstitialAd.unifiedInterstitialAd.detailPageVideoMuted = detailPageVideoMuted;
}

void GDT_UnionPlatform_UnifiedInterstitialAd_SetVideoAutoPlayWhenNoWifi(
    void *unifiedInterstitialAdPtr,
    bool videoAutoPlayOnWWAN) {
    GDTUnifiedInterstitialAdProxy *unifiedInterstitialAd = (__bridge GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;
    unifiedInterstitialAd.unifiedInterstitialAd.videoAutoPlayOnWWAN = videoAutoPlayOnWWAN;
}

const char* GDT_UnionPlatform_UnifiedInterstitialAd_GetECPMLevel(void *unifiedInterstitialAdPtr) {
    GDTUnifiedInterstitialAdProxy *unifiedInterstitialAd = (__bridge GDTUnifiedInterstitialAdProxy*)unifiedInterstitialAdPtr;
    return GDTAutonomousStringCopy([[unifiedInterstitialAd.unifiedInterstitialAd eCPMLevel] UTF8String]);
}

#if defined (__cplusplus)
}
#endif

