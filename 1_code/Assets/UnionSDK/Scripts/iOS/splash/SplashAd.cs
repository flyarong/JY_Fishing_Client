namespace Tencent.GDT
{
#if UNITY_IOS
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;
    using UnityEngine;

    public sealed class SplashAd : IDisposable, ISplashAd
    {
        private static Dictionary<int, ISplashAdListener> loadListeners = new Dictionary<int, ISplashAdListener>();

        private delegate void gdt_splashAdDidLoad(int context);
        private delegate void gdt_splashAdDidVisible(int context);
        private delegate void gdt_splashAdDidClick(int context);
        private delegate void gdt_splashAdDidClose(int context);
        private delegate void gdt_splashAdDidFailWithError(int context, int code, string message);
        private delegate void gdt_splashAdDidTick(int context, long leftTime);
        private delegate void gdt_splashAdDidExpose(int context);
        private delegate void gtd_splashApplicationDidEnerBackground(int context);

        private IntPtr splashAd;
        private bool disposed;

        public SplashAd(string placementId)
        {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }
            this.splashAd = GDT_UnionPlatform_SplashAd_Init(placementId);
        }

        ~SplashAd()
        {
            this.Dispose(false);
        }

        public void SetListener(ISplashAdListener listener)
        {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }
            loadListeners.Add((int)splashAd, listener);
        }

        public void LoadAd()
        {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }

            GDT_UnionPlatform_SplashAd_LoadAd(
                splashAd,
                GDT_SplashAd_OnFailWithErrorMethod,
                GDT_SplashAd_OnSplashAdLoadMethod,
                (int)splashAd);
            GDT_UnionPlatform_SplashAd_SetAdListener(
                splashAd,
                GDT_Splash_OnAdDidVisibleMethod,
                GDT_SplashAd_OnAdDidClickMethod,
                GDT_SplashAd_OnAdDidCloseMethod,
                GDT_SplashAd_OnExposedMethod,
                GDT_SplashAd_OnTickMethod,
                GDT_SplashAd_OnFailWithErrorMethod,
                GDT_SplashAd_OnApplicationBackgroundMethod);
        }

        public void SetFetchDelay(int duration) {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }
            GDT_UnionPlatform_SplashAd_SetFetchDelay(splashAd, duration / 1000);
        }

        public void SetSkipView(object skipView) {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }
            try
            {
                IntPtr skip = (IntPtr)skipView;
                if (skip != null)
                {
                    GDT_UnionPlatform_SplashAd_SetSkipView(splashAd, skip);
                }
            }
            catch
            {
                Debug.Log("skipview type error");
            }
        }

        public void SetBottomView(IntPtr bottomView) {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }
            GDT_UnionPlatform_SplashAd_SetBottomView(splashAd, bottomView);
        }

        public void SetSkipViewCenter(float x, float y) {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }
            GDT_UnionPlatform_SplashAd_SetSkipViewCenter(splashAd, x, y);
        }

        public void Show(object container) {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }
            try
            {
                IntPtr window = (IntPtr)container;
                if (window != null)
                {
                    GDT_UnionPlatform_SplashAd_ShowAd(splashAd, window);
                }
            }
            catch
            {
                Debug.Log("container type error");
            }
        }

        public bool IsValid()
        {
            return GDT_UnionPlatform_SplashAd_IsAdValid(splashAd);
        }

        public string GetECPMLevel()
        {
            return GDT_UnionPlatform_SplashAd_ECPMLevel(splashAd);
        }

        public void Preload()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            GDT_UnionPlatform_SplashAd_Preload(splashAd);
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
            GDT_UnionPlatform_SplashAd_Dispose(this.splashAd);
            this.disposed = true;
        }

        [DllImport("__Internal")]
        private static extern IntPtr GDT_UnionPlatform_SplashAd_Init(string placementId);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_SplashAd_LoadAd(
            IntPtr splashAdPtr,
            gdt_splashAdDidFailWithError onError,
            gdt_splashAdDidLoad onSplashAdDidLoad,
            int context);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_SplashAd_SetAdListener(
            IntPtr splashAdPtr,
            gdt_splashAdDidVisible onAdShown,
            gdt_splashAdDidClick onAdClicked,
            gdt_splashAdDidClose onAdClosed,
            gdt_splashAdDidExpose onExposed,
            gdt_splashAdDidTick onTicked,
            gdt_splashAdDidFailWithError onAdDidFailWithError,
            gtd_splashApplicationDidEnerBackground onApplicationBackground);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_SplashAd_SetFetchDelay(IntPtr splashAdPtr,
            int delay);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_SplashAd_SetSkipView(IntPtr splashAdPtr,
            IntPtr skipView);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_SplashAd_SetBottomView(IntPtr splashAdPtr,
            IntPtr bottomView);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_SplashAd_SetSkipViewCenter(IntPtr splashAdPtr, float x, float y);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_SplashAd_ShowAd(IntPtr splashAdPtr, IntPtr window);

        [DllImport("__Internal")]
        private static extern string GDT_UnionPlatform_SplashAd_ECPMLevel(IntPtr splashAdPtr);

        [DllImport("__Internal")]
        private static extern bool GDT_UnionPlatform_SplashAd_IsAdValid(IntPtr splashAdPtr);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_SplashAd_Preload(IntPtr splashAdPtr);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_SplashAd_Dispose(IntPtr splashAd);

        [AOT.MonoPInvokeCallback(typeof(gdt_splashAdDidFailWithError))]
        private static void GDT_SplashAd_OnFailWithErrorMethod(int context, int code, string message)
        {
            UnityDispatcher.PostTask(() =>
            {
                ISplashAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    loadListeners.Remove(context);
                    listener.OnError(new AdError(code, message));
                    Debug.Log("gdt_splashAdDidFailWithError");
                }
                else
                {
                    Debug.LogError("The gdt_splashAdDidFailWithError Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_splashAdDidLoad))]
        private static void GDT_SplashAd_OnSplashAdLoadMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                ISplashAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdLoaded();
                    Debug.Log("gdt_splashAdDidLoad");
                }
                else
                {
                    Debug.LogError("The gdt_splashAdDidLoad Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_splashAdDidVisible))]
        private static void GDT_Splash_OnAdDidVisibleMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                ISplashAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdShown();
                    Debug.Log("gdt_splashAdDidVisible");
                }
                else
                {
                    Debug.LogError("The gdt_splashAdDidVisible Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_splashAdDidClick))]
        private static void GDT_SplashAd_OnAdDidClickMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                ISplashAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdClicked();
                    Debug.Log("gdt_splashAdDidClick");
                }
                else
                {
                    Debug.LogError("The gdt_splashAdDidClick Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_splashAdDidClose))]
        private static void GDT_SplashAd_OnAdDidCloseMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                ISplashAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdClosed();
                    Debug.Log("gdt_splashAdDidClose");
                }
                else
                {
                    Debug.LogError("The gdt_splashAdDidClose Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_splashAdDidExpose))]
        private static void GDT_SplashAd_OnExposedMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                ISplashAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdExposured();
                    Debug.Log("gdt_splashAdDidExpose");
                }
                else
                {
                    Debug.LogError("The gdt_splashAdDidExpose Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_splashAdDidTick))]
        private static void GDT_SplashAd_OnTickMethod(int context, long leftTime)
        {
            UnityDispatcher.PostTask(() =>
            {
                ISplashAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    long milliLeftTime = leftTime * 1000;
                    listener.OnAdTick(milliLeftTime);
                    Debug.Log("gdt_splashAdDidtick: " + milliLeftTime);
                }
                else
                {
                    Debug.LogError("The gdt_splashAdDidTick Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gtd_splashApplicationDidEnerBackground))]
        private static void GDT_SplashAd_OnApplicationBackgroundMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                ISplashAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnApplicationBackground();
                    Debug.Log("gtd_splashApplicationDidEnerBackground");
                }
                else
                {
                    Debug.LogError("The gtd_splashApplicationDidEnerBackground Callback trigger failure." + context);
                }
            });
        }
    }
#endif
}