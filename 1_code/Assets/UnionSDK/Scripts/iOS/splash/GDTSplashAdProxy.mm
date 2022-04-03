#import "UnityAppController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GDTSplashAd.h"
#import "GDTSDKConfig.h"

extern const char *GDTAutonomousStringCopy(const char *string);

typedef void(*gdt_splashAdDidLoad)(int context);
typedef void(*gdt_splashAdDidVisible)(int context);
typedef void(*gdt_splashAdDidClick)(int context);
typedef void(*gdt_splashAdDidClose)(int context);
typedef void(*gdt_splashAdDidFailWithError)(int context, int code, const char *message);
typedef void(*gdt_splashAdDidTick)(int context, long long leftTime);
typedef void(*gdt_splashAdDidExpose)(int context);
typedef void(*gtd_splashApplicationDidEnerBackground)(int context);

@interface GDTSplashAdProxy : NSObject

@end

@interface GDTSplashAdProxy () <GDTSplashAdDelegate>

@property (nonatomic, assign) int loadContext;

@property (nonatomic, assign) gdt_splashAdDidLoad onSplashAdDidLoad;
@property (nonatomic, assign) gdt_splashAdDidVisible onSplashAdDidVisible;
@property (nonatomic, assign) gdt_splashAdDidClick onSplashAdDidClick;
@property (nonatomic, assign) gdt_splashAdDidClose onSplashAdDidClose;
@property (nonatomic, assign) gdt_splashAdDidFailWithError onSplashAdDidFailWithError;
@property (nonatomic, assign) gdt_splashAdDidTick onSplashAdDidTick;
@property (nonatomic, assign) gdt_splashAdDidExpose onSplashAdDidExpose;
@property (nonatomic, assign) gtd_splashApplicationDidEnerBackground onApplicationBackground;

@property (nonatomic, strong) GDTSplashAd *splashAd;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, strong) UIView *skipView;
@property (nonatomic, strong) UIView *bottomView;

@end


@implementation GDTSplashAdProxy

/**
 *  开屏广告成功展示
 */
- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
    self.onSplashAdDidVisible(self.loadContext);
}

/**
 *  开屏广告素材加载成功
 */
- (void)splashAdDidLoad:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
    self.onSplashAdDidLoad(self.loadContext);
}

/**
 *  开屏广告展示失败
 */
- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    self.onSplashAdDidFailWithError(self.loadContext, (int)error.code, GDTAutonomousStringCopy([[error localizedDescription] UTF8String]));
}

/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
    self.onApplicationBackground(self.loadContext);
}

/**
 *  开屏广告曝光回调
 */
- (void)splashAdExposured:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
    self.onSplashAdDidExpose(self.loadContext);
}

/**
 *  开屏广告点击回调
 */
- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    
}

/**
 *  开屏广告将要关闭回调
 */
- (void)splashAdWillClosed:(GDTSplashAd *)splashAd {
    
}

/**
 *  开屏广告关闭回调
 */
- (void)splashAdClosed:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
    self.onSplashAdDidClose(self.loadContext);
}

/**
 *  开屏广告点击以后即将弹出全屏广告页
 */
- (void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd {

}

/**
 *  开屏广告点击以后弹出全屏广告页
 */
- (void)splashAdDidPresentFullScreenModal:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
    self.onSplashAdDidClick(self.loadContext);
}

/**
 *  点击以后全屏广告页将要关闭
 */
- (void)splashAdWillDismissFullScreenModal:(GDTSplashAd *)splashAd {
    
}

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd {
    
}

/**
 * 开屏广告剩余时间回调
 */
- (void)splashAdLifeTime:(NSUInteger)time {
    NSLog(@"%s",__FUNCTION__);
    self.onSplashAdDidTick(self.loadContext, time);
}



@end

#if defined (__cplusplus)
extern "C" {
#endif
GDTSplashAdProxy* GDT_UnionPlatform_SplashAd_Init(
    const char *placementId) {
    NSString *placementIDStr = [[NSString alloc] initWithUTF8String:placementId];
    GDTSplashAd *splashAd = [[GDTSplashAd alloc] initWithPlacementId:placementIDStr];
    GDTSplashAdProxy *instance = [[GDTSplashAdProxy alloc] init];
    instance.splashAd = splashAd;
    instance.placementId = placementIDStr;
    splashAd.delegate = instance;
    (__bridge_retained void*)instance;
    return instance;
}
    
void GDT_UnionPlatform_SplashAd_LoadAd(
    void *splashAdPtr,
    gdt_splashAdDidFailWithError onError,
    gdt_splashAdDidLoad onSplashAdDidLoad,
    int context) {
    GDTSplashAdProxy *instance = (__bridge GDTSplashAdProxy*)splashAdPtr;

    instance.onSplashAdDidLoad = onSplashAdDidLoad;
    instance.onSplashAdDidFailWithError = onError;
    instance.loadContext = context;

    [instance.splashAd loadAd];
}

void GDT_UnionPlatform_SplashAd_SetFetchDelay(void *splashAdPtr,
                                              int delay) {
    GDTSplashAdProxy *instance = (__bridge GDTSplashAdProxy*)splashAdPtr;
    instance.splashAd.fetchDelay = delay;
}

void GDT_UnionPlatform_SplashAd_SetSkipView(void *splashAdPtr,
                                            void *skipView) {
    if (!skipView || ![(__bridge id)skipView isKindOfClass:[UIView class]]) {
        NSLog(@"skipView type error");
        return;
    }
    
    UIView *skip = (__bridge UIView *)skipView;
    GDTSplashAdProxy *instance = (__bridge GDTSplashAdProxy*)splashAdPtr;
    instance.skipView = skip;
}

void GDT_UnionPlatform_SplashAd_SetBottomView(void *splashAdPtr,
                                              void *bottomView) {
    if (!bottomView || ![(__bridge id)bottomView isKindOfClass:[UIView class]]) {
        NSLog(@"bottomView type error");
        return;
    }
    
    UIView *bottom = (__bridge UIView *)bottomView;
    GDTSplashAdProxy *instance = (__bridge GDTSplashAdProxy*)splashAdPtr;
    instance.bottomView = bottom;
}

void GDT_UnionPlatform_SplashAd_SetSkipViewCenter(void *splashAdPtr, float x, float y) {
    GDTSplashAdProxy *instance = (__bridge GDTSplashAdProxy*)splashAdPtr;
    [instance.splashAd setSkipButtonCenter:CGPointMake(x, y)];
}
      
void GDT_UnionPlatform_SplashAd_SetAdListener(
    void *splashAdPtr,
    gdt_splashAdDidVisible onAdDidVisible,
    gdt_splashAdDidClick onAdDidClick,
    gdt_splashAdDidClose onAdDidClose,
    gdt_splashAdDidExpose onAdDidExpose,
    gdt_splashAdDidTick onAdDidTick,
    gdt_splashAdDidFailWithError onAdDidFailWithError,
    gtd_splashApplicationDidEnerBackground onApplicationBackground) {
    GDTSplashAdProxy *instance = (__bridge GDTSplashAdProxy*)splashAdPtr;
    instance.onSplashAdDidVisible = onAdDidVisible;
    instance.onSplashAdDidClick = onAdDidClick;
    instance.onSplashAdDidClose = onAdDidClose;
    instance.onSplashAdDidExpose = onAdDidExpose;
    instance.onSplashAdDidTick = onAdDidTick;
    instance.onSplashAdDidFailWithError = onAdDidFailWithError;
    instance.onApplicationBackground = onApplicationBackground;
}

void GDT_UnionPlatform_SplashAd_ShowAd(void *splashAdPtr, void *window) {
    if (!window || ![(__bridge id)window isKindOfClass:[UIWindow class]]) {
        return;
    }
    
    UIWindow *showWindow = (__bridge UIWindow *)window;
    GDTSplashAdProxy *instance = (__bridge GDTSplashAdProxy*)splashAdPtr;
    [instance.splashAd showAdInWindow:showWindow
                       withBottomView:instance.bottomView
                             skipView:instance.skipView];
}

bool GDT_UnionPlatform_SplashAd_IsAdValid(void *splashAdPtr) {
    GDTSplashAdProxy *instance = (__bridge GDTSplashAdProxy*)splashAdPtr;
    return [instance.splashAd isAdValid];
}

const char* GDT_UnionPlatform_SplashAd_ECPMLevel(void *splashAdPtr) {
    GDTSplashAdProxy *instance = (__bridge GDTSplashAdProxy*)splashAdPtr;
    return GDTAutonomousStringCopy([[instance.splashAd eCPMLevel] UTF8String]);
}

void GDT_UnionPlatform_SplashAd_Preload(void *splashAdPtr) {
    GDTSplashAdProxy *instance = (__bridge GDTSplashAdProxy*)splashAdPtr;
    if (!instance.placementId.length) {
        NSLog(@"placementId is not exsit");
        return;
    }
    [GDTSplashAd preloadSplashOrderWithPlacementId:instance.placementId];
}

void GDT_UnionPlatform_SplashAd_Dispose(void *splashAdPtr) {
    (__bridge_transfer GDTSplashAdProxy*)splashAdPtr;
}

#if defined (__cplusplus)
}
#endif
