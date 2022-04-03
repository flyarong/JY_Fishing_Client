namespace Tencent.GDT
{
#if UNITY_IOS
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;
    using UnityEngine;
    public sealed class UnifiedInterstitialAd : IDisposable, IUnifiedInterstitialAd
    {
        public static int loadContextID = 0;
        private static Dictionary<int, IUnifiedInterstitialAdListener> loadListeners =
                new Dictionary<int, IUnifiedInterstitialAdListener>();

        private delegate void gdt_InterstitialSuccessToLoadAd(int context);
        private delegate void gdt_InterstitialFailToLoadAdWithError(int code, string message, int context);
        private delegate void gdt_InterstitialWillPresentScreen(int context);
        private delegate void gdt_InterstitialFailToPresentWithError(int code, string message, int context);
        private delegate void gdt_InterstitialDidPresentScreen(int context);
        private delegate void gdt_InterstitialDidDismissScreen(int context);
        private delegate void gdt_InterstitialWillLeaveApplication(int context);
        private delegate void gdt_InterstitialWillExposure(int context);
        private delegate void gdt_InterstitialClicked(int context);
        private delegate void gdt_InterstitialAdWillPresentFullScreenModal(int context);
        private delegate void gdt_InterstitialAdDidPresentFullScreenModal(int context);
        private delegate void gdt_InterstitialAdWillDismissFullScreenModal(int context);
        private delegate void gdt_InterstitialAdDidDismissFullScreenModal(int context);
        private delegate void gdt_InterstitialAdPlayerStatusChanged(int context, int playerStatus);
        private delegate void gdt_InterstitialAdViewWillPresentVideoVC(int context);
        private delegate void gdt_InterstitialAdViewDidPresentVideoVC(int context);
        private delegate void gdt_InterstitialAdViewWillDismissVideoVC(int context);
        private delegate void gdt_InterstitialAdViewDidDismissVideoVC(int context);

        private IntPtr unifiedInterstitialAd;
        private bool disposed;

        public UnifiedInterstitialAd(string placementId)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            this.unifiedInterstitialAd = GDT_UnionPlatform_UnifiedInterstitialAd_Init(placementId);
        }

        ~UnifiedInterstitialAd()
        {
            this.Dispose(false);
        }

        public void SetListener(IUnifiedInterstitialAdListener listener)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            loadListeners.Add((int)unifiedInterstitialAd, listener);
        }

        public void LoadAd()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
   
            GDT_UnionPlatform_UnifiedInterstitialAd_LoadAd(
                unifiedInterstitialAd,
                GDT_UnifiedInterstitial_OnInterstitialSuccessToLoadAdMethod,
                GDT_UnifiedInterstitial_OnInterstitialFailToLoadAdWithErrorMethod,
                (int) unifiedInterstitialAd);

            GDT_UnionPlatform_UnifiedInterstitialAd_SetInteractionListener(
            unifiedInterstitialAd,
            GDT_UnifiedInterstitial_OnInterstitialWillPresentScreenMethod,
            GDT_UnifiedInterstitial_OnInterstitialFailToPresentWithErrorMethod,
            GDT_UnifiedInterstitial_OnInterstitialDidPresentScreenMethod,
            GDT_UnifiedInterstitial_OnInterstitialDidDismissScreenMethod,
            GDT_UnifiedInterstitial_OnInterstitialWillLeaveApplicationMethod,
            GDT_UnifiedInterstitial_OnInterstitialWillExposureMethod,
            GDT_UnifiedInterstitial_OnInterstitialClickedMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdWillPresentFullScreenModalMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdDidPresentFullScreenModalMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdWillDismissFullScreenModalMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdDidDismissFullScreenModalMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdPlayerStatusChangedMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdViewWillPresentVideoVCMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdViewDidPresentVideoVCMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdViewWillDismissVideoVCMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdViewDidDismissVideoVCMethod
            );
        }

        public void Show()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            GDT_UnionPlatform_UnifiedInterstitialAd_ShowAd(unifiedInterstitialAd);
        }

        public void LoadFullScreenAd()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }

            GDT_UnionPlatform_UnifiedInterstitialAd_LoadFullScreenAd(
                unifiedInterstitialAd,
                GDT_UnifiedInterstitial_OnInterstitialSuccessToLoadAdMethod,
                GDT_UnifiedInterstitial_OnInterstitialFailToLoadAdWithErrorMethod,
                (int)unifiedInterstitialAd);

            GDT_UnionPlatform_UnifiedInterstitialAd_SetInteractionListener(
            unifiedInterstitialAd,
            GDT_UnifiedInterstitial_OnInterstitialWillPresentScreenMethod,
            GDT_UnifiedInterstitial_OnInterstitialFailToPresentWithErrorMethod,
            GDT_UnifiedInterstitial_OnInterstitialDidPresentScreenMethod,
            GDT_UnifiedInterstitial_OnInterstitialDidDismissScreenMethod,
            GDT_UnifiedInterstitial_OnInterstitialWillLeaveApplicationMethod,
            GDT_UnifiedInterstitial_OnInterstitialWillExposureMethod,
            GDT_UnifiedInterstitial_OnInterstitialClickedMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdWillPresentFullScreenModalMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdDidPresentFullScreenModalMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdWillDismissFullScreenModalMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdDidDismissFullScreenModalMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdPlayerStatusChangedMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdViewWillPresentVideoVCMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdViewDidPresentVideoVCMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdViewWillDismissVideoVCMethod,
            GDT_UnifiedInterstitial_OnInterstitialAdViewDidDismissVideoVCMethod
            );
        }

        public void ShowFullScreenAd()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            GDT_UnionPlatform_UnifiedInterstitialAd_ShowFullScreenAd(unifiedInterstitialAd);
        }

        public void SetMinVideoDuration(int duration)
        {
            GDT_UnionPlatform_UnifiedInterstitialAd_SetMinVideoDuration(unifiedInterstitialAd, duration);
        }

        public void SetMaxVideoDuration(int duration)
        {
            GDT_UnionPlatform_UnifiedInterstitialAd_SetMaxVideoDuration(unifiedInterstitialAd, duration);
        }

        public void SetVideoMuted(bool muted)
        {
            GDT_UnionPlatform_UnifiedInterstitialAd_SetVideoMuted(unifiedInterstitialAd, muted);
        }

        public void SetDetailPageVideoMuted(bool muted)
        {
            GDT_UnionPlatform_UnifiedInterstitialAd_SetDetailPageVideoMuted(unifiedInterstitialAd, muted);
        }

        public void SetVideoAutoPlayWhenNoWifi(bool autoPlay)
        {
            GDT_UnionPlatform_UnifiedInterstitialAd_SetVideoAutoPlayWhenNoWifi(unifiedInterstitialAd, autoPlay);
        }

        public string GetECPMLevel()
        {

            return GDT_UnionPlatform_UnifiedInterstitialAd_GetECPMLevel(unifiedInterstitialAd);
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
            GDT_UnionPlatform_UnifiedInterstitialAd_Dispose(this.unifiedInterstitialAd);
            this.disposed = true;
        }

        [DllImport("__Internal")]
        private static extern IntPtr GDT_UnionPlatform_UnifiedInterstitialAd_Init(
            string placementId);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedInterstitialAd_LoadAd(
            IntPtr unifiedInterstitialAd,
            gdt_InterstitialSuccessToLoadAd onInterstitialSuccessToLoadAd,
            gdt_InterstitialFailToLoadAdWithError onInterstitialFailToLoadAdWithError,
            int context
            );

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedInterstitialAd_LoadFullScreenAd(
            IntPtr unifiedInterstitialAd,
            gdt_InterstitialSuccessToLoadAd onInterstitialSuccessToLoadAd,
            gdt_InterstitialFailToLoadAdWithError onInterstitialFailToLoadAdWithError,
            int context);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedInterstitialAd_SetInteractionListener(
        IntPtr unifiedInterstitialAd,
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
        gdt_InterstitialAdViewDidDismissVideoVC onInterstitialAdViewDidDismissVideoVC
        );

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedInterstitialAd_ShowAd(
        IntPtr unifiledInterstitialAd);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedInterstitialAd_ShowFullScreenAd(
        IntPtr unifiledInterstitialAd);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedInterstitialAd_Dispose(
        IntPtr unifiledInterstitialAd);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedInterstitialAd_SetMinVideoDuration(
        IntPtr unifiedInterstitialAdPtr,
        int minVideoDuration);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedInterstitialAd_SetMaxVideoDuration(
        IntPtr unifiedInterstitialAdPtr,
        int maxVideoDuration);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedInterstitialAd_SetVideoMuted(
        IntPtr unifiedInterstitialAdPtr,
        bool videoMuted);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedInterstitialAd_SetDetailPageVideoMuted(
        IntPtr unifiedInterstitialAdPtr,
        bool detailPageVideoMuted);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_UnifiedInterstitialAd_SetVideoAutoPlayWhenNoWifi(
        IntPtr unifiedInterstitialAdPtr,
        bool videoAutoPlayOnWWAN);

        [DllImport("__Internal")]
        private static extern string GDT_UnionPlatform_UnifiedInterstitialAd_GetECPMLevel(IntPtr unifiedInterstitialAdPtr);

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialSuccessToLoadAd))]
        private static void GDT_UnifiedInterstitial_OnInterstitialSuccessToLoadAdMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdLoaded();
                    Debug.Log("gdt_InterstitialSuccessToLoadAd");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialSuccessToLoadAd Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialFailToLoadAdWithError))]
        private static void GDT_UnifiedInterstitial_OnInterstitialFailToLoadAdWithErrorMethod(int code, string message, int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    loadListeners.Remove(context);
                    listener.OnError(new AdError(code, message));
                    Debug.Log("gdt_InterstitialFailToLoadAdWithError");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialFailToLoadAdWithError Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialWillPresentScreen))]
        private static void GDT_UnifiedInterstitial_OnInterstitialWillPresentScreenMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    Debug.Log("gdt_InterstitialWillPresentScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialWillPresentScreen Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialFailToPresentWithError))]
        private static void GDT_UnifiedInterstitial_OnInterstitialFailToPresentWithErrorMethod(int code, string message, int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnError(new AdError(code, message));
                    Debug.Log("gdt_InterstitialFailToPresentWithError");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialFailToPresentWithError Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialDidPresentScreen))]
        private static void GDT_UnifiedInterstitial_OnInterstitialDidPresentScreenMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdShown();
                    Debug.Log("gdt_InterstitialDidPresentScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialDidPresentScreen Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialDidDismissScreen))]
        private static void GDT_UnifiedInterstitial_OnInterstitialDidDismissScreenMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdClosed();
                    Debug.Log("gdt_InterstitialDidDismissScreen");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialDidDismissScreen Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialWillLeaveApplication))]
        private static void GDT_UnifiedInterstitial_OnInterstitialWillLeaveApplicationMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdLeaveApp();
                    Debug.Log("gdt_InterstitialWillLeaveApplication");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialWillLeaveApplication Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialWillExposure))]
        private static void GDT_UnifiedInterstitial_OnInterstitialWillExposureMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdExposured();
                    Debug.Log("gdt_InterstitialWillExposure");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialWillExposure Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialClicked))]
        private static void GDT_UnifiedInterstitial_OnInterstitialClickedMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdClicked();
                    Debug.Log("gdt_InterstitialClicked");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialClicked Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialAdWillPresentFullScreenModal))]
        private static void GDT_UnifiedInterstitial_OnInterstitialAdWillPresentFullScreenModalMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    Debug.Log("gdt_InterstitialAdWillPresentFullScreenModal");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialAdWillPresentFullScreenModal Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialAdDidPresentFullScreenModal))]
        private static void GDT_UnifiedInterstitial_OnInterstitialAdDidPresentFullScreenModalMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdShown();
                    Debug.Log("gdt_InterstitialAdDidPresentFullScreenModal");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialAdDidPresentFullScreenModal Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialAdWillDismissFullScreenModal))]
        private static void GDT_UnifiedInterstitial_OnInterstitialAdWillDismissFullScreenModalMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    Debug.Log("gdt_InterstitialAdWillDismissFullScreenModal");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialAdWillDismissFullScreenModal Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialAdDidDismissFullScreenModal))]
        private static void GDT_UnifiedInterstitial_OnInterstitialAdDidDismissFullScreenModalMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdClosed();
                    Debug.Log("gdt_InterstitialAdDidDismissFullScreenModal");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialAdDidDismissFullScreenModal Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialAdPlayerStatusChanged))]
        private static void GDT_UnifiedInterstitial_OnInterstitialAdPlayerStatusChangedMethod(int context, int playerStatus)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    if (playerStatus == 0)
                    {
                        listener.OnVideoInit();
                    } else if (playerStatus == 1)
                    {
                        listener.OnVideoLoading();
                    } else if (playerStatus == 2)
                    {
                        listener.OnVideoStarted();
                    } else if (playerStatus == 3)
                    {
                        listener.OnVideoPaused();
                    } else if (playerStatus == 4)
                    {
                        listener.OnVideoCompleted();
                    } else if (playerStatus == 5)
                    {
                        listener.OnVideoError();
                    }
                    Debug.Log("gdt_InterstitialAdPlayerStatusChanged");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialAdPlayerStatusChanged Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialAdViewWillPresentVideoVC))]
        private static void GDT_UnifiedInterstitial_OnInterstitialAdViewWillPresentVideoVCMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    Debug.Log("gdt_InterstitialAdViewWillPresentVideoVC");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialAdViewWillPresentVideoVC Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialAdViewDidPresentVideoVC))]
        private static void GDT_UnifiedInterstitial_OnInterstitialAdViewDidPresentVideoVCMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnVideoDetailPageShown();
                    Debug.Log("gdt_InterstitialAdViewDidPresentVideoVC");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialAdViewDidPresentVideoVC Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialAdViewWillDismissVideoVC))]
        private static void GDT_UnifiedInterstitial_OnInterstitialAdViewWillDismissVideoVCMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    Debug.Log("gdt_InterstitialAdViewWillDismissVideoVC");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialAdViewWillDismissVideoVC Callback trigger failure.");
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_InterstitialAdViewDidDismissVideoVC))]
        private static void GDT_UnifiedInterstitial_OnInterstitialAdViewDidDismissVideoVCMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IUnifiedInterstitialAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnVideoDetailPageClosed();
                    Debug.Log("gdt_InterstitialAdViewDidDismissVideoVC");
                }
                else
                {
                    Debug.LogError(
                        "The gdt_InterstitialAdViewDidDismissVideoVC Callback trigger failure.");
                }
            });
        }
    }
#endif
}
