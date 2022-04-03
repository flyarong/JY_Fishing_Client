namespace Tencent.GDT
{
#if UNITY_IOS
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;
    using UnityEngine;

    public sealed class RewardVideoAd : IDisposable, IRewardVideoAd
    {
        private static Dictionary<int, IRewardVideoAdListener> loadListeners = new Dictionary<int, IRewardVideoAdListener>();

        private delegate void gdt_rewardVideoAdDidLoad(int context);
        private delegate void gdt_rewardVideoAdVideoDidLoad(int context);
        private delegate void gdt_rewardVideoAdWillVisible(int context);
        private delegate void gdt_rewardVideoAdDidClicked(int context);
        private delegate void gdt_rewardVideoAdDidClose(int context);
        private delegate void gdt_rewardVideoAdDidPlayFinish(int context);
        private delegate void gdt_rewardVideoAdDidFailWithError(int code, string message, int context);
        private delegate void gdt_rewardVideoAdDidRewardEffective(int contex);
        private delegate void gdt_rewardVideoAdDidExposed(int context);

        private IntPtr rewardVideoAd;
        private bool disposed;

        public RewardVideoAd(string placementId)
        {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }
            this.rewardVideoAd = GDT_UnionPlatform_RewardVideoAd_Init(placementId);
        }

        ~RewardVideoAd()
        {
            this.Dispose(false);
        }

        public void SetVideoMuted(bool muted)
        {
            GDT_UnionPlatform_RewardVideoAd_SetVideoMuted(rewardVideoAd, muted);
        }

        public void SetListener(IRewardVideoAdListener listener)
        {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }
            loadListeners.Add((int) rewardVideoAd, listener);
        }

		public void SetEnableDefaultAudioSessionSetting(bool audioSessionSetting)
		{
            GDT_UnionPlatform_RewardVideoAd_SetEnableDefaultAudioSessionSetting(audioSessionSetting);

        }

        public void LoadAd()
        {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }

            GDT_UnionPlatform_RewardVideoAd_LoadAd(
                rewardVideoAd,
                GDT_RewardVideoAd_OnVideoDidFailWithErrorMethod,
                GDT_RewardVideoAd_OnRewardVideoAdLoadMethod,
                GDT_RewardVideoAd_OnRewardVideoAdVideoDidLoadMethod,
                (int) rewardVideoAd);
            GDT_UnionPlatform_RewardVideoAd_SetRewardVideoAdListener(
                rewardVideoAd,
                GDT_RewardVideoAd_OnAdWillVisibleMethod,
                GDT_RewardVideoAd_OnAdVideoDidClickedMethod,
                GDT_RewardVideoAd_OnAdDidCloseMethod,
                GDT_RewardVideoAd_OnVideoDidPlayFinishMethod,
                GDT_RewardVideoAd_OnVideoDidExposedMethod,
                GDT_RewardVideoAd_OnVideoDidRewardEffectiveMethod,
                GDT_RewardVideoAd_OnVideoDidFailWithErrorMethod);
        }

        public void ShowAD()
        {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }
            GDT_UnionPlatform_RewardVideoAd_ShowRewardVideoAd(rewardVideoAd);
        }

        public long GetExpireTimestamp()
        {           
            return GDT_UnionPlatform_RewardVideoAd_GetExpireTimestamp(rewardVideoAd);
        }

        public string GetECPMLevel()
        {
            return GDT_UnionPlatform_RewardVideoAd_GetECPMLevel(rewardVideoAd);
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
            GDT_UnionPlatform_RewardVideoAd_Dispose(this.rewardVideoAd);
            this.disposed = true;
        }

        [DllImport("__Internal")]
        private static extern IntPtr GDT_UnionPlatform_RewardVideoAd_Init(string placementId);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_RewardVideoAd_LoadAd(
            IntPtr rewardVideoAd,
            gdt_rewardVideoAdDidFailWithError onError,
            gdt_rewardVideoAdDidLoad onRewardVideoAdDidLoad,
            gdt_rewardVideoAdVideoDidLoad onRewardVideoAdVideoDidLoad,
            int context);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_RewardVideoAd_SetRewardVideoAdListener(
            IntPtr rewardVideoAd,
            gdt_rewardVideoAdWillVisible onAdShow,
            gdt_rewardVideoAdDidClicked onAdVideoBarClick,
            gdt_rewardVideoAdDidClose onAdClose,
            gdt_rewardVideoAdDidPlayFinish onVideoComplete,
            gdt_rewardVideoAdDidExposed onVideoDidExposed,
            gdt_rewardVideoAdDidRewardEffective onRewardEffective,
            gdt_rewardVideoAdDidFailWithError onAdDidFailWithError);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_RewardVideoAd_ShowRewardVideoAd(IntPtr rewardVideoAd);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_RewardVideoAd_Dispose(IntPtr rewardVideoAd);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_RewardVideoAd_SetVideoMuted(IntPtr rewardVideoAd, bool videoMuted);

        [DllImport("__Internal")]
        private static extern long GDT_UnionPlatform_RewardVideoAd_GetExpireTimestamp(IntPtr rewardVideoAd);

        [DllImport("__Internal")]
        private static extern string GDT_UnionPlatform_RewardVideoAd_GetECPMLevel(IntPtr rewardVideoAd);

        [DllImport ("__Internal")]
        private static extern void GDT_UnionPlatform_RewardVideoAd_SetEnableDefaultAudioSessionSetting(bool audioSessionSetting);

        [AOT.MonoPInvokeCallback(typeof(gdt_rewardVideoAdDidFailWithError))]
        private static void GDT_RewardVideoAd_OnVideoDidFailWithErrorMethod(int code, string message, int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IRewardVideoAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    loadListeners.Remove(context);
                    listener.OnError(new AdError(code, message));
                    Debug.Log("gdt_rewardVideoAdDidFailWithError");
                }
                else
                {
                    Debug.LogError("The gdt_rewardVideoAdDidFailWithError Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_rewardVideoAdDidLoad))]
        private static void GDT_RewardVideoAd_OnRewardVideoAdLoadMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IRewardVideoAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdLoaded();
                    Debug.Log("gdt_rewardVideoAdDidFailWithError");
                }
                else
                {
                    Debug.LogError("The gdt_rewardVideoAdDidLoad Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_rewardVideoAdVideoDidLoad))]
        private static void GDT_RewardVideoAd_OnRewardVideoAdVideoDidLoadMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IRewardVideoAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnVideoCached();
                    Debug.Log("gdt_rewardVideoAdDidFailWithError");
                }
                else
                {
                    Debug.LogError("The gdt_rewardVideoAdVideoDidLoad Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_rewardVideoAdWillVisible))]
        private static void GDT_RewardVideoAd_OnAdWillVisibleMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IRewardVideoAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdShown();
                    Debug.Log("gdt_rewardVideoAdDidFailWithError");
                }
                else
                {
                    Debug.LogError("The gdt_rewardVideoAdWillVisible Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_rewardVideoAdDidClicked))]
        private static void GDT_RewardVideoAd_OnAdVideoDidClickedMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IRewardVideoAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdClicked();
                    Debug.Log("gdt_rewardVideoAdDidFailWithError");
                }
                else
                {
                    Debug.LogError("The gdt_rewardVideoAdDidClicked Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_rewardVideoAdDidClose))]
        private static void GDT_RewardVideoAd_OnAdDidCloseMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IRewardVideoAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdClosed();
                    Debug.Log("gdt_rewardVideoAdDidFailWithError");
                }
                else
                {
                    Debug.LogError("The gdt_rewardVideoAdDidClose Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_rewardVideoAdDidPlayFinish))]
        private static void GDT_RewardVideoAd_OnVideoDidPlayFinishMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IRewardVideoAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnVideoCompleted();
                    Debug.Log("gdt_rewardVideoAdDidFailWithError");
                }
                else
                {
                    Debug.LogError("The gdt_rewardVideoAdDidPlayFinish Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_rewardVideoAdDidExposed))]
        private static void GDT_RewardVideoAd_OnVideoDidExposedMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IRewardVideoAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnAdExposured();
                    Debug.Log("gdt_rewardVideoAdDidExposed");
                }
                else
                {
                    Debug.LogError("The gdt_rewardVideoAdDidExposed Callback trigger failure." + context);
                }
            });
        }

        [AOT.MonoPInvokeCallback(typeof(gdt_rewardVideoAdDidRewardEffective))]
        private static void GDT_RewardVideoAd_OnVideoDidRewardEffectiveMethod(int context)
        {
            UnityDispatcher.PostTask(() =>
            {
                IRewardVideoAdListener listener;
                if (loadListeners.TryGetValue(context, out listener))
                {
                    listener.OnRewarded();
                    Debug.Log("gdt_rewardVideoAdDidRewardEffective");
                }
                else
                {
                    Debug.LogError("The gdt_rewardVideoAdDidRewardEffective Callback trigger failure." + context);
                }
            });
        }
    }
#endif
}
