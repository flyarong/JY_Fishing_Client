//
//  UnifiedBannerAd.mm
//
//  Created by holdenjing on 2020/4/26.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnityAppController.h"
#import <UIKit/UIKit.h>
#import "GDTUnifiedBannerView.h"

extern const char *GDTAutonomousStringCopy(const char *string);

typedef void(*gdt_BannerSuccessToLoadAd)(int context);
typedef void(*gdt_BannerFailToLoadAdWithError)(int code, const char *message, int context);
typedef void(*gdt_BannerDidPresentScreen)(int context);
typedef void(*gdt_BannerDidDismissScreen)(int context);
typedef void(*gdt_BannerWillLeaveApplication)(int context);
typedef void(*gdt_BannerWillExposure)(int context);
typedef void(*gdt_BannerClicked)(int context);
typedef void(*gdt_BannerWillClose)(int context);
typedef void(*gdt_BannerWillPresentScreen)(int context);
typedef void(*gdt_BannerWillDismissScreen)(int context);

@interface GDTUnifiedBannerAdProxy : NSObject

@end

@interface GDTUnifiedBannerAdProxy () <GDTUnifiedBannerViewDelegate>

@property (nonatomic, assign) int loadContext;

@property (nonatomic, assign) gdt_BannerSuccessToLoadAd onBannerSuccessToLoadAd;
@property (nonatomic, assign) gdt_BannerFailToLoadAdWithError onBannerFailToLoadAdWithError;
@property (nonatomic, assign) gdt_BannerDidPresentScreen onBannerDidPresentScreen;
@property (nonatomic, assign) gdt_BannerDidDismissScreen onBannerDidDismissScreen;
@property (nonatomic, assign) gdt_BannerWillLeaveApplication onBannerWillLeaveApplication;
@property (nonatomic, assign) gdt_BannerWillExposure onBannerWillExposure;
@property (nonatomic, assign) gdt_BannerClicked onBannerClicked;
@property (nonatomic, assign) gdt_BannerWillClose onBannerClose;
@property (nonatomic, assign) gdt_BannerWillPresentScreen onBannerWillPresentScreen;
@property (nonatomic, assign) gdt_BannerWillDismissScreen onBannerWillDismissScreen;

@property (nonatomic, strong) GDTUnifiedBannerView *unifiedBannerAd;

@end

@implementation GDTUnifiedBannerAdProxy

/**
 *  请求广告条数据成功后调用
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBanner
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"unified banner did load");
    self.onBannerSuccessToLoadAd(self.loadContext);
}

/**
 *  请求广告条数据失败后调用
 *  当接收服务器返回的广告数据失败后调用该函数
 */
- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"Banner fail to load, Error : %@",error);
    self.onBannerFailToLoadAdWithError((int)error.code, GDTAutonomousStringCopy([[error localizedDescription] UTF8String]), self.loadContext);
}

/**
 *  banner2.0广告点击以后弹出全屏广告页完毕
 */
- (void)unifiedBannerViewDidPresentFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"%s",__FUNCTION__);
    self.onBannerDidPresentScreen(self.loadContext);
}

/**
 *  全屏广告页已经被关闭
 */
- (void)unifiedBannerViewDidDismissFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"%s",__FUNCTION__);
    self.onBannerDidDismissScreen(self.loadContext);
}

/**
 *  应用进入后台时调用
 *  当点击应用下载或者广告调用系统程序打开，应用将被自动切换到后台
 */
- (void)unifiedBannerViewWillLeaveApplication:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"%s",__FUNCTION__);
    self.onBannerWillLeaveApplication(self.loadContext);
}

/**
 *  banner2.0曝光回调
 */
- (void)unifiedBannerViewWillExpose:(nonnull GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"%s",__FUNCTION__);
    self.onBannerWillExposure(self.loadContext);
}

/**
 *  banner2.0点击回调
 */
- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"%s",__FUNCTION__);
    self.onBannerClicked(self.loadContext);
}

/**
 *  banner2.0被用户关闭时调用
 */
- (void)unifiedBannerViewWillClose:(nonnull GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"%s",__FUNCTION__);
    self.unifiedBannerAd = nil;
    self.onBannerClose(self.loadContext);
}

/**
 *  banner2.0广告点击以后即将弹出全屏广告页
 */
- (void)unifiedBannerViewWillPresentFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"%s",__FUNCTION__);
}

/**
 *  全屏广告页即将被关闭
 */
- (void)unifiedBannerViewWillDismissFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView
{
    NSLog(@"%s",__FUNCTION__);
}


@end


#if defined (__cplusplus)
extern "C" {
#endif

static NSMutableArray<GDTUnifiedBannerView *> *unifiedBannerAdMutArray = [[NSMutableArray alloc] init];

GDTUnifiedBannerAdProxy* GDT_UnionPlatform_UnifiedBannerAd_Init(
    const char* placementId, const int width, const int height) {
    NSString *placementIdStr = [[NSString alloc] initWithUTF8String:placementId];
    CGRect rect = CGRectMake(0, 50, width, height);

    GDTUnifiedBannerView *unifiedBannerAd = [[GDTUnifiedBannerView alloc] initWithFrame:rect placementId:placementIdStr viewController:GetAppController().rootViewController];
    GDTUnifiedBannerAdProxy* instance = [[GDTUnifiedBannerAdProxy alloc] init];
    instance.unifiedBannerAd = unifiedBannerAd;
    unifiedBannerAd.delegate = instance;
    (__bridge_retained void*)instance;
    return instance;
}

void GDT_UnionPlatform_UnifiedBannerAd_LoadAndShowAd(
    void *unifiedBannerAdPtr,
    gdt_BannerSuccessToLoadAd onBannerSuccessToLoadAd,
    gdt_BannerFailToLoadAdWithError onBannerFailToLoadAdWithError,
    int context) {
    GDTUnifiedBannerAdProxy *unifiedBannerAd = (__bridge GDTUnifiedBannerAdProxy*)unifiedBannerAdPtr;
    
    unifiedBannerAd.onBannerSuccessToLoadAd = onBannerSuccessToLoadAd;
    unifiedBannerAd.onBannerFailToLoadAdWithError = onBannerFailToLoadAdWithError;
    unifiedBannerAd.loadContext = context;
    [unifiedBannerAd.unifiedBannerAd loadAdAndShow];
}
 
void GDT_UnionPlatform_UnifiedBannerAd_SetInteractionListener(
    void *unifiedBannerAdPtr,
    gdt_BannerDidPresentScreen onBannerDidPresentScreen,
    gdt_BannerDidDismissScreen onBannerDidDismissScreen,
    gdt_BannerWillLeaveApplication onBannerWillLeaveApplication,
    gdt_BannerWillExposure onBannerWillExposure,
    gdt_BannerClicked onBannerClicked,
    gdt_BannerWillClose onBannerClose,
    gdt_BannerWillPresentScreen onBannerWillPresentScreen,
    gdt_BannerWillDismissScreen onBannerWillDismissScreen) {
    GDTUnifiedBannerAdProxy *unifiedBannerAd = (__bridge GDTUnifiedBannerAdProxy*)unifiedBannerAdPtr;

    unifiedBannerAd.onBannerClicked = onBannerClicked;
    unifiedBannerAd.onBannerDidPresentScreen = onBannerDidPresentScreen;
    unifiedBannerAd.onBannerDidDismissScreen = onBannerDidDismissScreen;
    unifiedBannerAd.onBannerWillExposure = onBannerWillExposure;
    unifiedBannerAd.onBannerWillLeaveApplication = onBannerWillLeaveApplication;
    unifiedBannerAd.onBannerClose = onBannerClose;
    unifiedBannerAd.onBannerWillPresentScreen = onBannerWillPresentScreen;
    unifiedBannerAd.onBannerWillDismissScreen = onBannerWillDismissScreen;
}
    
void GDT_UnionPlatform_UnifiedBannerAd_Dispose(void *unifiedBannerAdPtr) {
    (__bridge_transfer GDTUnifiedBannerAdProxy*)unifiedBannerAdPtr;
}

void GDT_UnionPlatform_UnifiedBannerAd_RemoveUnifiedBannerAdView() {
    for (int i = 0; i < unifiedBannerAdMutArray.count; i++) {
        GDTUnifiedBannerView *unifiedBannerView = (GDTUnifiedBannerView *)unifiedBannerAdMutArray[i];
        [unifiedBannerView removeFromSuperview];
        unifiedBannerView = nil;
    }
    [unifiedBannerAdMutArray removeAllObjects];
}


void GDT_UnionPlatform_UnifiedBannerAd_RemoveAd(void *unifiedBannerAdPtr) {
    GDTUnifiedBannerAdProxy *unifiedBannerAd = (__bridge GDTUnifiedBannerAdProxy*)unifiedBannerAdPtr;
    [unifiedBannerAd.unifiedBannerAd removeFromSuperview];
    unifiedBannerAd.unifiedBannerAd = nil;
    [unifiedBannerAdMutArray removeAllObjects];
}

void GDT_UnionPlatform_UnifiedBannerAd_SetAutoSwitchInterval(
    void *unifiedBannerAdPtr,
    int autoSwitchInterval) {
    GDTUnifiedBannerAdProxy *unifiedBannerAd = (__bridge GDTUnifiedBannerAdProxy*)unifiedBannerAdPtr;
    unifiedBannerAd.unifiedBannerAd.autoSwitchInterval = autoSwitchInterval;
}

UIView * GDT_UnionPlatform_UnifiedBannerAd_GetNativeView(
    void *unifiedBannerAdPtr) {
    GDTUnifiedBannerAdProxy *unifiedBannerAd = (__bridge GDTUnifiedBannerAdProxy*)unifiedBannerAdPtr;
    return unifiedBannerAd.unifiedBannerAd;
}

#if defined (__cplusplus)
}
#endif

