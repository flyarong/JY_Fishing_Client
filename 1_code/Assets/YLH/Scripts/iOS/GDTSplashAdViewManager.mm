#import <Foundation/Foundation.h>

#if defined (__cplusplus)
extern "C" {
#endif

UIWindow * GDT_UnionPlatform_UnifiedSplashAd_GetContainerWindow() {
    return [UIApplication sharedApplication].keyWindow;
}

#if defined (__cplusplus)
}
#endif