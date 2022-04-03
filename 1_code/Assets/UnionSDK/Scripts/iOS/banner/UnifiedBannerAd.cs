
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

namespace Tencent.GDT
{
#if UNITY_IOS
    public sealed class UnifiedBannerAd : IUnifiedBannerAd, IDisposable
    {
        private static Dictionary<int, IUnifiedBannerAdListener> loadListeners =
                new Dictionary<int, IUnifiedBannerAdListener>();
        private string placementId;
        private IntPtr unifiedBannerAd;
        private bool disposed;

        private delegate void gdt_BannerSuccessToLoadAd(int context);
        private delegate void gdt_BannerFailToLoadAdWithError(int code, string message, int context);
        private delegate void gdt_BannerDidPresentScreen(int context);
        private delegate void gdt_BannerDidDismissScreen(int context);
        private delegate void gdt_BannerWillLeaveApplication(int context);
        private delegate void gdt_BannerWillExposure(int context);
        private delegate void gdt_BannerClicked(int context);
        private delegate void gdt_BannerWillClose(int context);
        private delegate void gdt_BannerWillPresentScreen(int context);
        private delegate void gdt_BannerWillDismissScreen(int context);

        public UnifiedBannerAd(string placementId, AdSize adSize)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            if (adSize == null)
            {
                Debug.Log("AdSize 不能为空！");
                return;
            }
            this.placementId = placementId;
            unifiedBannerAd = GDT_UnionPlatform_UnifiedBannerAd_Init(this.placementId, adSize.width, adSize.height);
        }

        public void LoadAndShowAd()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            GDT_UnionPlatform_UnifiedBannerAd_RemoveUnifiedBannerAdView();

            GDT_UnionPlatform_UnifiedBannerAd_LoadAndShowAd(
                unifiedBannerAd,
                GDT_UnifiedBanner_OnBannerSuccessToLoadAdMethod,
                GDT_UnifiedBanner_OnBannerFailToLoadAdWithErrorMethod,
                (int)unifiedBannerAd);

            GDT_UnionPlatform_UnifiedBannerAd_SetInteractionListener(
            unifiedBannerAd,
            GDT_UnifiedBanner_OnBannerDidPresentScreenMethod,
            GDT_UnifiedBanner_OnBannerDidDismissScreenMethod,
            GDT_UnifiedBanner_OnBannerWillLeaveApplicationMethod,
            GDT_UnifiedBanner_OnBannerWillExposureMethod,
            GDT_UnifiedBanner_OnBannerClickedMethod,
            GDT_UnifiedBanner_OnBannerDidClosedMethod,
            GDT_UnifiedBanner_OnBannerWillPresentScreenMethod,
            GDT_UnifiedBanner_OnBannerWillDismissScreenMethod);
        }

        ~UnifiedBannerAd()
        {
            this.Dispose(false);
        }

        public void SetListener(IUnifiedBannerAdListener listener)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            loadListeners.Add((int)unifiedBannerAd, listener);
        }
        public void CloseAd()
        {
            GDT_UnionPlatform_UnifiedBannerAd_RemoveAd(this.unifiedBannerAd);
        }

        public IntPtr GetIOSNativeView() 
        {
            return GDT_UnionPlatform_UnifiedBannerAd_GetNativeView(this.unifiedBannerAd);
        }

        public void Dispose()
        {
            this.Dispose(true);
            GC.SuppressFinalize(this);
        }

        public void Dispose(bool disposing)
        {
            if (this.disposed)
            {
                return;
            }
            GDT_UnionPlatform_UnifiedBannerAd_Dispose(unifiedBannerAd);
            this.disposed = true;
        }

        public void SetAutoSwitchInterval(int autoSwitchInterval)
        {
            GDT_UnionPlatform_UnifiedBannerAd_SetAutoSwitchInterval(unifiedBannerAd, autoSwitchInterval);
        }

        [DllImport("__Internal")]
        private static extern IntPtr GDT_UnionPlatform_UnifiedBannerAd_GetNativeView(IntPtr unifiedBannerAdPtr);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedBannerAd_SetAutoSwitchInterval(
            IntPtr unifiedBannerAd,
            int autoSwitchInterval);

        [DllImport("__Internal")]
        private static extern IntPtr GDT_UnionPlatform_UnifiedBannerAd_Init(
           string placementId,
           int width,
           int height);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedBannerAd_LoadAndShowAd(
            IntPtr unifiedBannerAd,
            gdt_BannerSuccessToLoadAd onBannerSuccessToLoadAd,
            gdt_BannerFailToLoadAdWithError onBannerFailToLoadAdWithError,
            int context
            );

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedBannerAd_SetInteractionListener(
        IntPtr unifiedBannerAd,
        gdt_BannerDidPresentScreen bannerDidPresentScreen,
        gdt_BannerDidDismissScreen bannerDidDismissScreen,
        gdt_BannerWillLeaveApplication bannerWillLeaveApplication,
        gdt_BannerWillExposure bannerWillExposure,
        gdt_BannerClicked bannerClicked,
        gdt_BannerWillClose bannerWillClose,
        gdt_BannerWillPresentScreen bannerWillPresentScreen,
        gdt_BannerWillDismissScreen bannerWillDismissScreen
        );

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedBannerAd_RemoveUnifiedBannerAdView();

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedBannerAd_Dispose(
        IntPtr unifiledBannerAd);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedBannerAd_RemoveAd(
        IntPtr unifiledBannerAd);

        [AOT.MonoPInvokeCallback(typeof(gdt_BannerSuccessToLoadAd))]
        private static void GDT_UnifiedBanner_OnBannerSuccessToLoadAdMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedBannerAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdLoaded();
                    Debug.Log("gdt_BannerSuccessToLoadAd");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_BannerSuccessToLoadAd Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_BannerFailToLoadAdWithError))]
        private static void GDT_UnifiedBanner_OnBannerFailToLoadAdWithErrorMethod(int code, string message, int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedBannerAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    loadListeners.Remove(context);
                    listener.OnError(new AdError(code, message));
                    Debug.Log("gdt_BannerFailToLoadAdWithError");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_BannerFailToLoadAdWithError Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_BannerDidPresentScreen))]
        private static void GDT_UnifiedBanner_OnBannerDidPresentScreenMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedBannerAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnDetailPageShown();
                    Debug.Log("gdt_BannerDidPresentScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_BannerDidPresentScreen Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_BannerDidDismissScreen))]
        private static void GDT_UnifiedBanner_OnBannerDidDismissScreenMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedBannerAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnDetailPageClosed();
                    Debug.Log("gdt_BannerDidDismissScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_BannerDidDismissScreen Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_BannerWillLeaveApplication))]
        private static void GDT_UnifiedBanner_OnBannerWillLeaveApplicationMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedBannerAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdLeaveApp();
                    Debug.Log("gdt_BannerWillLeaveApplication");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_BannerWillLeaveApplication Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_BannerWillExposure))]
        private static void GDT_UnifiedBanner_OnBannerWillExposureMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedBannerAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdExposured();
                    Debug.Log("gdt_BannerWillExposure");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_BannerWillExposure Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_BannerClicked))]
        private static void GDT_UnifiedBanner_OnBannerClickedMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedBannerAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdClicked();
                    Debug.Log("gdt_BannerClicked");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_BannerClicked Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_BannerWillClose))]
        private static void GDT_UnifiedBanner_OnBannerDidClosedMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedBannerAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdClosed();
                    Debug.Log("gdt_BannerWillClose");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_BannerWillClose Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_BannerWillDismissScreen))]
        private static void GDT_UnifiedBanner_OnBannerWillDismissScreenMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedBannerAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    Debug.Log("gdt_BannerWillDismissScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_BannerWillDismissScreen Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_BannerWillPresentScreen))]
        private static void GDT_UnifiedBanner_OnBannerWillPresentScreenMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedBannerAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    Debug.Log("gdt_BannerWillPresentScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_BannerWillPresentScreen Callback trigger failure.");
                }
            });
        }

    }
#endif
}
