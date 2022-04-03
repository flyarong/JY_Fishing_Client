//
//  NativeExpressAd.mm
//
//  Created by holdenjing on 2020/5/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UnityAppController.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import <sys/utsname.h>

extern const char *GDTAutonomousStringCopy(const char *string);

typedef void(*gdt_nativeExpressAdSuccessToLoad)(int context, void *views, long long arrayCount);
typedef void(*gdt_nativeExpressAdRenderFail)(int code, const char *message, int context, void *view);
typedef void(*gdt_nativeExpressAdFailToLoad)(int code, const char* message, int context);
typedef void(*gdt_nativeExpressAdViewRenderSuccess)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewClicked)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewClosed)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewExposure)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewWillPresentScreen)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewDidPresentScreen)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewWillDismissScreen)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewDidDismissScreen)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewPlayerStatusChanged)(int context, void *view, long long playerStatus);
typedef void(*gdt_nativeExpressAdViewWillPresentVideoVC)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewDidPresentVideoVC)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewWillDismissVideoVC)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewDidDismissVideoVC)(int context, void *view);
typedef void(*gdt_nativeExpressAdViewApplicationWillEnterBackground)(int context, void *view);

@interface GDTNativeExpressAdProxy : NSObject

@end

@interface GDTNativeExpressAdProxy () <GDTNativeExpressAdDelegete>

@property (nonatomic, assign) int loadContext;

@property (nonatomic, assign) gdt_nativeExpressAdSuccessToLoad onNativeExpressAdSuccessToLoad;
@property (nonatomic, assign) gdt_nativeExpressAdRenderFail onNativeExpressAdRenderFail;
@property (nonatomic, assign) gdt_nativeExpressAdFailToLoad onNativeExpressAdFailToLoad;
@property (nonatomic, assign) gdt_nativeExpressAdViewRenderSuccess onNativeExpressAdViewRenderSuccess;
@property (nonatomic, assign) gdt_nativeExpressAdViewClicked onNativeExpressAdViewClicked;
@property (nonatomic, assign) gdt_nativeExpressAdViewClosed onNativeExpressAdViewClosed;
@property (nonatomic, assign) gdt_nativeExpressAdViewExposure onNativeExpressAdViewExposure;
@property (nonatomic, assign) gdt_nativeExpressAdViewWillPresentScreen onNativeExpressAdViewWillPresentScreen;
@property (nonatomic, assign) gdt_nativeExpressAdViewDidPresentScreen onNativeExpressAdViewDidPresentScreen;
@property (nonatomic, assign) gdt_nativeExpressAdViewWillDismissScreen onNativeExpressAdViewWillDismissScreen;
@property (nonatomic, assign) gdt_nativeExpressAdViewDidDismissScreen onNativeExpressAdViewDidDismissScreen;
@property (nonatomic, assign) gdt_nativeExpressAdViewPlayerStatusChanged onNativeExpressAdViewPlayerStatusChanged;
@property (nonatomic, assign) gdt_nativeExpressAdViewWillPresentVideoVC onNativeExpressAdViewWillPresentVideoVC;
@property (nonatomic, assign) gdt_nativeExpressAdViewDidPresentVideoVC onNativeExpressAdViewDidPresentVideoVC;
@property (nonatomic, assign) gdt_nativeExpressAdViewWillDismissVideoVC onNativeExpressAdViewWillDismissVideoVC;
@property (nonatomic, assign) gdt_nativeExpressAdViewDidDismissVideoVC onNativeExpressAdViewDidDismissVideoVC;
@property (nonatomic, assign) gdt_nativeExpressAdViewApplicationWillEnterBackground onNativeExpressAdViewApplicationWillEnterBackground;

@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;
@property (nonatomic, strong) NSMutableArray *expressAdViews;
@property (nonatomic, strong) GDTNativeExpressAdView *nativeExpressAdView;

@end

@implementation GDTNativeExpressAdProxy

/**
 * 详解:当点击应用下载或者广告调用系统程序打开时调用
 */
- (void)nativeExpressAdViewApplicationWillEnterBackground:(GDTNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"%s",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewApplicationWillEnterBackground(self.loadContext, (__bridge void*)view);
}

/**
 * 拉取原生模板广告成功
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views
{
    NSLog(@"%s",__FUNCTION__);
    self.expressAdViews = [NSMutableArray arrayWithArray:views];
    void *p = (__bridge void *)self.expressAdViews;
    self.onNativeExpressAdSuccessToLoad(self.loadContext, p, [self.expressAdViews count]);
}

/**
 * 原生模板广告渲染失败
 */
- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdRenderFail(1, "NativeExpressAdRenderFail", self.loadContext, (__bridge void*)view);
}

/**
 * 拉取原生模板广告失败
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"Express Ad Load Fail : %@",error);
    self.onNativeExpressAdFailToLoad((int)error.code, GDTAutonomousStringCopy([[error localizedDescription] UTF8String]), self.loadContext);
}

/**
 * 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
 */
- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    self.nativeExpressAdView = nativeExpressAdView;
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewRenderSuccess(self.loadContext, (__bridge void*)view);
    nativeExpressAdView.alpha = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

/**
 * 原生模板广告点击回调
 */
- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewClicked(self.loadContext, (__bridge void*)view);
}

/**
 * 原生模板广告被关闭
 */
- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    [self.expressAdViews removeObject:nativeExpressAdView];
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewClosed(self.loadContext, (__bridge void*)view);
    [nativeExpressAdView removeFromSuperview];
    nativeExpressAdView = nil;
}

/**
 * 原生模板广告曝光回调
 */
- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewExposure(self.loadContext, (__bridge void*)view);
    nativeExpressAdView.alpha = 1;
    [self setNativeExpressViewFrameWithOrientation];
}

/**
 * 点击原生模板广告以后即将弹出全屏广告页
 */
- (void)nativeExpressAdViewWillPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewWillPresentScreen(self.loadContext, (__bridge void*)view);
}

/**
 * 点击原生模板广告以后弹出全屏广告页
 */
- (void)nativeExpressAdViewDidPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewDidPresentScreen(self.loadContext, (__bridge void*)view);
}

/**
 * 全屏广告页将要关闭
 */
- (void)nativeExpressAdViewWillDismissScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewWillDismissScreen(self.loadContext, (__bridge void*)view);
}

/**
 * 全屏广告页关闭
 */
- (void)nativeExpressAdViewDidDismissScreen:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"%s",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewDidDismissScreen(self.loadContext, (__bridge void*)view);
}

/**
 * 原生模板视频广告 player 播放状态更新回调
 */
- (void)nativeExpressAdView:(GDTNativeExpressAdView *)nativeExpressAdView playerStatusChanged:(GDTMediaPlayerStatus)status
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"view:%@ duration:%@ playtime:%@ status:%@ isVideoAd:%@", nativeExpressAdView,@([nativeExpressAdView videoDuration]), @([nativeExpressAdView videoPlayTime]), @(status), @(nativeExpressAdView.isVideoAd));
    id view = nativeExpressAdView;
    long long playStatus = status;
    self.onNativeExpressAdViewPlayerStatusChanged(self.loadContext, (__bridge void*)view, playStatus);
}

/**
 * 原生视频模板详情页 WillPresent 回调
 */
- (void)nativeExpressAdViewWillPresentVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewWillPresentVideoVC(self.loadContext, (__bridge void*)view);
}

/**
 * 原生视频模板详情页 DidPresent 回调
 */
- (void)nativeExpressAdViewDidPresentVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewDidPresentVideoVC(self.loadContext, (__bridge void*)view);
}

/**
 * 原生视频模板详情页 WillDismiss 回调
 */
- (void)nativeExpressAdViewWillDismissVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewWillDismissVideoVC(self.loadContext, (__bridge void*)view);
}

/**
 * 原生视频模板详情页 DidDismiss 回调
 */
- (void)nativeExpressAdViewDidDismissVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
    id view = nativeExpressAdView;
    self.onNativeExpressAdViewDidDismissVideoVC(self.loadContext, (__bridge void*)view);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientationChange:(NSNotification *)notification {
    [self setNativeExpressViewFrameWithOrientation];
}

- (void)setNativeExpressViewFrameWithOrientation {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    float rectWidth = (GetAppController().rootViewController.view.frame.size.width - self.nativeExpressAdView.bounds.size.width) / 2;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        self.nativeExpressAdView.frame = CGRectMake(rectWidth, 0, self.nativeExpressAdView.bounds.size.width, self.nativeExpressAdView.bounds.size.height);
    } else if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationFaceUp) {
        float originY = 0;
        float deviceWidth = GetAppController().rootViewController.view.frame.size.width;
        if (deviceWidth <= 350) {
            originY = GetAppController().rootViewController.view.frame.size.height*1/3;
        } else {
            originY = GetAppController().rootViewController.view.frame.size.height*7/18;
        }
        self.nativeExpressAdView.frame = CGRectMake(rectWidth, originY, self.nativeExpressAdView.bounds.size.width, self.nativeExpressAdView.bounds.size.height);
    }
}

@end


#if defined (__cplusplus)
extern "C" {
#endif
 
static NSMutableArray<GDTNativeExpressAdView *> *nativeExpressAdMutArray = nil;

GDTNativeExpressAdProxy* GDT_UnionPlatform_NativeExpressAd_Init(
    const char *placementId,
    float width,
    float height) {
    if (!nativeExpressAdMutArray) {
        nativeExpressAdMutArray = [[NSMutableArray alloc] init];
    }
    NSString *placementIDStr = [[NSString alloc] initWithUTF8String:placementId];
    GDTNativeExpressAd *nativeExpressAd = [[GDTNativeExpressAd alloc] initWithPlacementId:placementIDStr adSize:CGSizeMake(width, height)];
    GDTNativeExpressAdProxy *instance = [[GDTNativeExpressAdProxy alloc] init];
    instance.nativeExpressAd = nativeExpressAd;
    nativeExpressAd.delegate = instance;
    (__bridge_retained void*)instance;
    return instance;
    }
   
void GDT_UnionPlatform_NativeExpressAd_LoadAd(
    void *nativeExpressAdPtr,
    gdt_nativeExpressAdSuccessToLoad onNativeExpressAdSuccessToLoad,
    gdt_nativeExpressAdFailToLoad onNativeExpressAdFailToLoad,
    int context,
    int loadCount) {
    GDTNativeExpressAdProxy *instance = (__bridge GDTNativeExpressAdProxy*)nativeExpressAdPtr;
    instance.onNativeExpressAdSuccessToLoad = onNativeExpressAdSuccessToLoad;
    instance.onNativeExpressAdFailToLoad = onNativeExpressAdFailToLoad;
    instance.loadContext = context;
    [instance.nativeExpressAd loadAd:(NSInteger)loadCount];
}


void GDT_UnionPlatform_NativeExpressAd_SetNativeExpressAdListener(
    void *nativeExpressAdPtr,
    gdt_nativeExpressAdRenderFail onNativeExpressAdRenderFail,
    gdt_nativeExpressAdViewRenderSuccess onNativeExpressAdViewRenderSuccess,
    gdt_nativeExpressAdViewClicked onNativeExpressAdViewClicked,
    gdt_nativeExpressAdViewClosed onNativeExpressAdViewClosed,
    gdt_nativeExpressAdViewExposure onNativeExpressAdViewExposure,
    gdt_nativeExpressAdViewWillPresentScreen onNativeExpressAdViewWillPresentScreen,
    gdt_nativeExpressAdViewDidPresentScreen onNativeExpressAdViewDidPresentScreen,
    gdt_nativeExpressAdViewWillDismissScreen onNativeExpressAdViewWillDismissScreen,
    gdt_nativeExpressAdViewDidDismissScreen onNativeExpressAdViewDidDismissScreen,
    gdt_nativeExpressAdViewPlayerStatusChanged onNativeExpressAdViewPlayerStatusChanged,
    gdt_nativeExpressAdViewWillPresentVideoVC onNativeExpressAdViewWillPresentVideoVC,
    gdt_nativeExpressAdViewDidPresentVideoVC onNativeExpressAdViewDidPresentVideoVC,
    gdt_nativeExpressAdViewWillDismissVideoVC onNativeExpressAdViewWillDismissVideoVC,
    gdt_nativeExpressAdViewDidDismissVideoVC onNativeExpressAdViewDidDismissVideoVC,
    gdt_nativeExpressAdViewApplicationWillEnterBackground onNativeExpressAdViewApplicationWillEnterBackground) {
    GDTNativeExpressAdProxy *nativeExpressAd = (__bridge GDTNativeExpressAdProxy*)nativeExpressAdPtr;
    nativeExpressAd.onNativeExpressAdRenderFail = onNativeExpressAdRenderFail;
    nativeExpressAd.onNativeExpressAdViewRenderSuccess = onNativeExpressAdViewRenderSuccess;
    nativeExpressAd.onNativeExpressAdViewClicked = onNativeExpressAdViewClicked;
    nativeExpressAd.onNativeExpressAdViewClosed = onNativeExpressAdViewClosed;
    nativeExpressAd.onNativeExpressAdViewExposure = onNativeExpressAdViewExposure;
    nativeExpressAd.onNativeExpressAdViewWillPresentScreen = onNativeExpressAdViewWillPresentScreen;
    nativeExpressAd.onNativeExpressAdViewDidPresentScreen = onNativeExpressAdViewDidPresentScreen;
    nativeExpressAd.onNativeExpressAdViewWillDismissScreen = onNativeExpressAdViewWillDismissScreen;
    nativeExpressAd.onNativeExpressAdViewDidDismissScreen = onNativeExpressAdViewDidDismissScreen;
    nativeExpressAd.onNativeExpressAdViewPlayerStatusChanged = onNativeExpressAdViewPlayerStatusChanged;
    nativeExpressAd.onNativeExpressAdViewWillPresentVideoVC = onNativeExpressAdViewWillPresentVideoVC;
    nativeExpressAd.onNativeExpressAdViewDidPresentVideoVC = onNativeExpressAdViewDidPresentVideoVC;
    nativeExpressAd.onNativeExpressAdViewWillDismissVideoVC = onNativeExpressAdViewWillDismissVideoVC;
    nativeExpressAd.onNativeExpressAdViewDidDismissVideoVC = onNativeExpressAdViewDidDismissVideoVC;
    nativeExpressAd.onNativeExpressAdViewApplicationWillEnterBackground = onNativeExpressAdViewApplicationWillEnterBackground;
}

void GDT_UnionPlatform_NativeExpressAd_Dispose(void *nativeExpressAdPtr) {
    (__bridge_transfer GDTNativeExpressAdProxy*)nativeExpressAdPtr;
}

void GDT_UnionPlatform_NativeExpressAd_Render(void *nativeExpressViewAdPtr, int index) {
    id obj = (__bridge id)nativeExpressViewAdPtr;
    NSArray<GDTNativeExpressAdView *> *viewArray = [[NSArray alloc] init];
    if ([obj isKindOfClass:[NSArray class]]) {
        viewArray = obj;
    }
    if (viewArray.count > index) {
        GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)viewArray[index];
        expressView.controller = GetAppController().rootViewController;
        [expressView render];
        NSLog(@"eCPMLevel:%@", [expressView eCPMLevel]);
    }
}

void GDT_UnionPlatform_NativeExpressAd_CloseNativeExpressAdView(
    void *nativeExpressViewAdPtr, int index) {
    id nativeExpressViews = (__bridge id)nativeExpressViewAdPtr;
    NSArray *array = nil;
    if ([nativeExpressViews isKindOfClass:[NSArray class]]) {
        array = nativeExpressViews;
    }
    NSArray<GDTNativeExpressAdView *> *viewArray = array;
    if (viewArray.count > index) {
        GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)viewArray[index];
        [expressView removeFromSuperview];
        expressView = nil;
        [nativeExpressAdMutArray removeAllObjects];
    }
}
    
void GDT_UnionPlatform_NativeExpressAd_SetMinVideoDuration(
    void *nativeExpressAdPtr,
    int minVideoDuration) {
    GDTNativeExpressAdProxy *nativeExpressAd = (__bridge GDTNativeExpressAdProxy*)nativeExpressAdPtr;
    nativeExpressAd.nativeExpressAd.minVideoDuration = minVideoDuration;
}

void GDT_UnionPlatform_NativeExpressAd_SetMaxVideoDuration(
    void *nativeExpressAdPtr,
    int maxVideoDuration) {
    GDTNativeExpressAdProxy *nativeExpressAd = (__bridge GDTNativeExpressAdProxy*)nativeExpressAdPtr;
    nativeExpressAd.nativeExpressAd.maxVideoDuration = maxVideoDuration;
}

void GDT_UnionPlatform_NativeExpressAd_SetVideoMuted(
    void *nativeExpressAdPtr,
    bool videoMuted) {
    GDTNativeExpressAdProxy *nativeExpressAd = (__bridge GDTNativeExpressAdProxy*)nativeExpressAdPtr;
    nativeExpressAd.nativeExpressAd.videoMuted = videoMuted;
}

void GDT_UnionPlatform_NativeExpressAd_SetDetailPageVideoMuted(
    void *nativeExpressAdPtr,
    bool detailPageVideoMuted) {
    GDTNativeExpressAdProxy *nativeExpressAd = (__bridge GDTNativeExpressAdProxy*)nativeExpressAdPtr;
    nativeExpressAd.nativeExpressAd.detailPageVideoMuted = detailPageVideoMuted;
}

void GDT_UnionPlatform_NativeExpressAd_SetVideoAutoPlayWhenNoWifi(
    void *nativeExpressAdPtr,
    bool videoAutoPlayOnWWAN) {
    GDTNativeExpressAdProxy *nativeExpressAd = (__bridge GDTNativeExpressAdProxy*)nativeExpressAdPtr;
    nativeExpressAd.nativeExpressAd.videoAutoPlayOnWWAN = videoAutoPlayOnWWAN;
}

const char* GDT_UnionPlatform_NativeExpressAd_GetECPMLevel(void *nativeExpressViewAdPtr, int index) {
    id nativeExpressViews = (__bridge id)nativeExpressViewAdPtr;
    NSArray *array = nil;
    if ([nativeExpressViews isKindOfClass:[NSArray class]]) {
        array = nativeExpressViews;
    }
    NSArray<GDTNativeExpressAdView *> *viewArray = array;
    if (viewArray.count > index) {
        GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)viewArray[index];
        return GDTAutonomousStringCopy([[expressView eCPMLevel] UTF8String]);
    }
    return nil;
}

UIView * GDT_UnionPlatform_NativeExpressAd_GetNativeView(void *nativeExpressViewAdPtr, int index) {
    id nativeExpressViews = (__bridge id)nativeExpressViewAdPtr;
    NSArray *array = nil;
    if ([nativeExpressViews isKindOfClass:[NSArray class]]) {
        array = nativeExpressViews;
    }
    NSArray<GDTNativeExpressAdView *> *viewArray = array;
    if (viewArray.count > index) {
        GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)viewArray[index];
        return expressView;
    }
    return nil;
}

#if defined (__cplusplus)
}
#endif

