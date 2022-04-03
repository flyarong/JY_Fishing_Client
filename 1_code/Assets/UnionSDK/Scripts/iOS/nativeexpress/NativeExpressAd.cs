namespace Tencent.GDT
{
#if UNITY_IOS
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;
    using UnityEngine;
    public sealed class NativeExpressAd : IDisposable, INativeExpressAd
    {
        public static int loadContextID = 0;

        private static Dictionary<int, INativeExpressAdListener> loadListeners =
                new Dictionary<int, INativeExpressAdListener>();

        private delegate void gdt_nativeExpressAdSuccessToLoad(int context, IntPtr views, long arrayCount);
        private delegate void gdt_nativeExpressAdRenderFail(int code, string message, int context, IntPtr view);
        private delegate void gdt_nativeExpressAdFailToLoad(int code, string message, int context);
        private delegate void gdt_nativeExpressAdViewRenderSuccess(int context, IntPtr view);
        private delegate void gdt_nativeExpressAdViewClicked(int context, IntPtr view);
        private delegate void gdt_nativeExpressAdViewClosed(int context, IntPtr view);
        private delegate void gdt_nativeExpressAdViewExposure(int context, IntPtr view);
        private delegate void gdt_nativeExpressAdViewWillPresentScreen(int context, IntPtr view);
        private delegate void gdt_nativeExpressAdViewDidPresentScreen(int context, IntPtr view);
        private delegate void gdt_nativeExpressAdViewWillDismissScreen(int context, IntPtr view);
        private delegate void gdt_nativeExpressAdViewDidDismissScreen(int context, IntPtr view);

        private delegate void gdt_nativeExpressAdViewPlayerStatusChanged(int context, IntPtr view, long playerStatus);
        private delegate void gdt_nativeExpressAdViewWillPresentVideoVC(int context, IntPtr view);
        private delegate void gdt_nativeExpressAdViewDidPresentVideoVC(int context, IntPtr view);
        private delegate void gdt_nativeExpressAdViewWillDismissVideoVC(int context, IntPtr view);
        private delegate void gdt_nativeExpressAdViewDidDismissVideoVC(int context, IntPtr view);

        private delegate void gdt_nativeExpressAdViewApplicationWillEnterBackground(int context, IntPtr view);

        private IntPtr nativeExpressAd;
        private bool disposed;

        public NativeExpressAd(string placementId, AdSize adSize)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            this.nativeExpressAd = GDT_UnionPlatform_NativeExpressAd_Init(placementId, adSize.GetWidth(), adSize.GetHeight());
        }
        public void SetListener(INativeExpressAdListener listener)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            loadListeners.Add((int)this.nativeExpressAd, listener);
        }

        public void LoadAd(int count)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }

            GDT_UnionPlatform_NativeExpressAd_LoadAd(
                nativeExpressAd,
                GDT_NativeExpress_OnNativeExpressAdSuccessToLoadMethod,
                GDT_NativeExpress_OnNativeExpressAdFailToLoadMethod,
                (int)nativeExpressAd,
                count);

            GDT_UnionPlatform_NativeExpressAd_SetNativeExpressAdListener(
                nativeExpressAd,
                GDT_NativeExpress_OnNativeExpressAdRenderFailMethod,
                GDT_NativeExpress_OnNativeExpressAdViewRenderSuccessMethod,
                GDT_NativeExpress_OnNativeExpressAdViewClickedMethod,
                GDT_NativeExpress_OnNativeExpressAdViewClosedMethod,
                GDT_NativeExpress_OnNativeExpressAdViewExposureMethod,
                GDT_NativeExpress_OnNativeExpressAdViewWillPresentScreenMethod,
                GDT_NativeExpress_OnNativeExpressAdViewDidPresentScreenMethod,
                GDT_NativeExpress_OnNativeExpressAdViewWillDissmissScreenMethod,
                GDT_NativeExpress_OnNativeExpressAdViewDidDissmissScreenMethod,
                GDT_NativeExpress_OnNativeExpressAdViewplayerStatusChangedMethod,
                GDT_NativeExpress_OnNativeExpressAdViewWillPresentVideoVCMethod,
                GDT_NativeExpress_OnNativeExpressAdViewDidPresentVideoVCMethod,
                GDT_NativeExpress_OnNativeExpressAdViewWillDismissVideoVCMethod,
                GDT_NativeExpress_OnNativeExpressAdViewDidDismissVideoVCMethod,
                GDT_NativeExpress_OnNativeExpressAdViewApplicationWillEnterBackgroundMethod
                );
        }

        public void SetMinVideoDuration(int duration)
        {
            GDT_UnionPlatform_NativeExpressAd_SetMinVideoDuration(nativeExpressAd, duration);
        }

        public void SetMaxVideoDuration(int duration)
        {
            GDT_UnionPlatform_NativeExpressAd_SetMaxVideoDuration(nativeExpressAd, duration);
        }

        public void SetVideoMuted(bool muted)
        {
            GDT_UnionPlatform_NativeExpressAd_SetVideoMuted(nativeExpressAd, muted);
        }

        public void SetDetailPageVideoMuted(bool muted)
        {
            GDT_UnionPlatform_NativeExpressAd_SetDetailPageVideoMuted(nativeExpressAd, muted);
        }

        public void SetVideoAutoPlayWhenNoWifi(bool autoPlay)
        {
            GDT_UnionPlatform_NativeExpressAd_SetVideoAutoPlayWhenNoWifi(nativeExpressAd, autoPlay);
        }

        ~NativeExpressAd()
        {
            this.Dispose(false);
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
            GDT_UnionPlatform_NativeExpressAd_Dispose(this.nativeExpressAd);
            this.disposed = true;
        }

        [DllImport("__Internal")]
        private static extern IntPtr GDT_UnionPlatform_NativeExpressAd_Init(
            string placementId,
            float width,
            float height);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_NativeExpressAd_LoadAd(
            IntPtr nativeExpressAdPtr,
            gdt_nativeExpressAdSuccessToLoad onNativeExpressAdSuccessToLoad,
            gdt_nativeExpressAdFailToLoad onNativeExpressAdFailToLoad,
            int context,
            int loadCount);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_NativeExpressAd_SetNativeExpressAdListener(
            IntPtr nativeExpressAdPtr,
            gdt_nativeExpressAdRenderFail onNativeExpressAdRenderFail,
            gdt_nativeExpressAdViewRenderSuccess onNativeExpressAdViewRenderSuccess,
            gdt_nativeExpressAdViewClicked onNativeExpressAdViewClicked,
            gdt_nativeExpressAdViewClosed onNativeExpressAdViewClosed,
            gdt_nativeExpressAdViewExposure onNativeExpressAdViewExposure,
            gdt_nativeExpressAdViewWillPresentScreen onNativeExpressAdViewWillPresentScreen,
            gdt_nativeExpressAdViewDidPresentScreen onNativeExpressAdViewDidPresentScreen,
            gdt_nativeExpressAdViewWillDismissScreen onNativeExpressAdViewWillDissmissScreen,
            gdt_nativeExpressAdViewDidDismissScreen onNativeExpressAdViewDidDissmissScreen,
            gdt_nativeExpressAdViewPlayerStatusChanged onNativeExpressAdViewplayerStatusChanged,
            gdt_nativeExpressAdViewWillPresentVideoVC onNativeExpressAdViewWillPresentVideoVC,
            gdt_nativeExpressAdViewDidPresentVideoVC onNativeExpressAdViewDidPresentVideoVC,
            gdt_nativeExpressAdViewWillDismissVideoVC onNativeExpressAdViewWillDismissVideoVC,
            gdt_nativeExpressAdViewDidDismissVideoVC onNativeExpressAdViewDidDismissVideoVC,
            gdt_nativeExpressAdViewApplicationWillEnterBackground onNativeExpressAdViewApplicationWillEnterBackground);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_NativeExpressAd_Dispose(
            IntPtr nativeExpressAdPtr);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_NativeExpressAd_SetMinVideoDuration(
            IntPtr nativeExpressAdPtr,
            int minVideoDuration);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_NativeExpressAd_SetMaxVideoDuration(
            IntPtr nativeExpressAdPtr,
            int maxVideoDuration);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_NativeExpressAd_SetVideoMuted(
            IntPtr nativeExpressAdPtr,
            bool videoMuted);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_NativeExpressAd_SetDetailPageVideoMuted(
            IntPtr nativeExpressAdPtr,
            bool detailPageVideoMuted);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_NativeExpressAd_SetVideoAutoPlayWhenNoWifi(
            IntPtr nativeExpressAdPtr,
            bool videoAutoPlayOnWWAN);

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewApplicationWillEnterBackground))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewApplicationWillEnterBackgroundMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdLeaveApp(new NativeExpressAdView(view));
                    Debug.Log("gdt_nativeExpressAdViewApplicationWillEnterBackground");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewApplicationWillEnterBackground Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdSuccessToLoad))]
        private static void GDT_NativeExpress_OnNativeExpressAdSuccessToLoadMethod(int context, IntPtr views, long arrayCount)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    List<NativeExpressAdView> adViewList = new List<NativeExpressAdView>();
                    for (int i = 0; i < arrayCount; i++)
                    {
                        adViewList.Add(new NativeExpressAdView(views, i));
                    }                 
                    listener.OnAdLoaded(adViewList);
                    Debug.Log("gdt_InterstitialSuccessToLoadAd");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdSuccessToLoad Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdRenderFail))]
        private static void GDT_NativeExpress_OnNativeExpressAdRenderFailMethod(int code, string message, int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    loadListeners.Remove(context);
                    listener.OnAdViewRenderFailed(new NativeExpressAdView(view));
                    Debug.Log("gdt_nativeExpressAdRenderFail");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdRenderFail Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdFailToLoad))]
        private static void GDT_NativeExpress_OnNativeExpressAdFailToLoadMethod(int code, string message, int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    loadListeners.Remove(context);
                    listener.OnError(new AdError(code, message));
                    Debug.Log("gdt_nativeExpressAdFailToLoad");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdFailToLoad Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewRenderSuccess))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewRenderSuccessMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdViewRenderSuccess(new NativeExpressAdView(view));
                    Debug.Log("gdt_nativeExpressAdViewRenderSuccess");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewRenderSuccess Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewClicked))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewClickedMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdClicked(new NativeExpressAdView(view));
                    Debug.Log("gdt_nativeExpressAdViewClicked");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewClicked Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewClosed))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewClosedMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdClosed(new NativeExpressAdView(view));
                    Debug.Log("gdt_nativeExpressAdViewClosed");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewClosed Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewExposure))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewExposureMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdExposured(new NativeExpressAdView(view));
                    Debug.Log("gdt_nativeExpressAdViewExposure");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewExposure Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewWillPresentScreen))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewWillPresentScreenMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    Debug.Log("gdt_nativeExpressAdViewWillPresentScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewWillPresentScreen Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewDidPresentScreen))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewDidPresentScreenMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnDetailPageShown(new NativeExpressAdView(view));
                    Debug.Log("gdt_nativeExpressAdViewDidPresentScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewDidPresentScreen Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewWillDismissScreen))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewWillDissmissScreenMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    Debug.Log("gdt_nativeExpressAdViewWillDismissScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewWillDismissScreen Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewDidDismissScreen))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewDidDissmissScreenMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnDetailPageClosed(new NativeExpressAdView(view));
                    Debug.Log("gdt_nativeExpressAdViewDidDissmissScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewDidDismissScreen Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewPlayerStatusChanged))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewplayerStatusChangedMethod(int context, IntPtr view, long playerStatus)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    if (playerStatus == 0)
                    {
                        listener.OnVideoInit(new NativeExpressAdView(view));
                    }
                    else if (playerStatus == 1)
                    {
                        listener.OnVideoLoading(new NativeExpressAdView(view));
                    }
                    else if (playerStatus == 2)
                    {
                        listener.OnVideoStarted(new NativeExpressAdView(view));
                    }
                    else if (playerStatus == 3)
                    {
                        listener.OnVideoPaused(new NativeExpressAdView(view));
                    }
                    else if (playerStatus == 4)
                    {
                        listener.OnVideoCompleted(new NativeExpressAdView(view));
                    }
                    else if (playerStatus == 5)
                    {
                        listener.OnVideoError(new NativeExpressAdView(view), new AdError());
                    }
                    Debug.Log("gdt_nativeExpressAdViewplayerStatusChanged");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewPlayerStatusChanged Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewWillPresentVideoVC))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewWillPresentVideoVCMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    Debug.Log("gdt_nativeExpressAdViewWillPresentVideoVC");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewWillPresentVideoVC Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewDidPresentVideoVC))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewDidPresentVideoVCMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnVideoDetailPageShown(new NativeExpressAdView(view));
                    Debug.Log("gdt_nativeExpressAdViewDidDissmissScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewDidPresentVideoVC Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewWillDismissVideoVC))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewWillDismissVideoVCMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {

                    Debug.Log("gdt_nativeExpressAdViewWillDismissVideoVC");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewWillDismissVideoVC Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_nativeExpressAdViewDidDismissVideoVC))]
        private static void GDT_NativeExpress_OnNativeExpressAdViewDidDismissVideoVCMethod(int context, IntPtr view)
        {
            UnityDispatcher.PostTask(() =>
            {
                INativeExpressAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnVideoDetailPageClosed(new NativeExpressAdView(view));
                    Debug.Log("gdt_nativeExpressAdViewDidDismissVideoVC");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_nativeExpressAdViewDidDismissVideoVC Callback trigger failure.");
                }
            });
        }
    }
#endif
}
