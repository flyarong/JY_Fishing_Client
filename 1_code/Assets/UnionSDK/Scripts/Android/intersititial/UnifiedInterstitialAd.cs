namespace Tencent.GDT
{
#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
    using UnityEngine;
    public sealed class UnifiedInterstitialAd : IUnifiedInterstitialAd
    {
        AndroidJavaObject adProxy;
        UnifiedInterstitialAdListenerProxy adListenerProxy = new UnifiedInterstitialAdListenerProxy();
        UnifiedInterstitialMediaListenerProxy adMediaListenerProxy = new UnifiedInterstitialMediaListenerProxy();

        VideoOption videoOption = new VideoOption();

        AndroidJavaObject activity;

        public UnifiedInterstitialAd(string posId)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            activity = Utils.GetActivity();
            this.adProxy = new AndroidJavaObject("com.qq.e.ads.interstitial2.UnifiedInterstitialAD", activity, posId, adListenerProxy);
            this.adProxy.Call("setMediaListener", adMediaListenerProxy);
        }

        public void SetListener(IUnifiedInterstitialAdListener listener)
        {
            adListenerProxy.listener = listener;
            adMediaListenerProxy.listener = listener;
        }

        public void Show()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            Utils.RunInMainThread(new ShowRunnable(this.adProxy));
        }

        public void ShowFullScreenAd()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            this.adProxy.Call("showFullScreenAD", activity);
        }

        public void LoadAd()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            SetVideoOption();
            this.adProxy.Call("loadAD");
        }

        public void LoadFullScreenAd()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            SetVideoOption();
            this.adProxy.Call("loadFullScreenAD");
        }

        public void SetMinVideoDuration(int duration)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            this.adProxy.Call("setMinVideoDuration", duration);
        }

        public void SetMaxVideoDuration(int duration)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            this.adProxy.Call("setMaxVideoDuration", duration);
        }

        public void SetVideoMuted(bool muted)
        {
            videoOption.SetAutoPlayMuted(muted);
        }

        public void SetDetailPageVideoMuted(bool muted)
        {
            videoOption.SetDetailPageMuted(muted);
        }

        public void SetVideoAutoPlayWhenNoWifi(bool autoPlay)
        {
            videoOption.SetAutoPlayPolicy(autoPlay ? VideoOption.AutoPlayPolicy.ALWAYS : VideoOption.AutoPlayPolicy.WIFI);
        }

        private void SetVideoOption()
        {
            this.adProxy.Call("setVideoOption", videoOption.GetVideoOption());
        }

        public string GetECPMLevel()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return null;
            }
            return this.adProxy.Call<string>("getECPMLevel");
        }

        private class ShowRunnable : Runnable
        {
            private AndroidJavaObject adProxy;

            public ShowRunnable(AndroidJavaObject adProxy)
            {
                this.adProxy = adProxy;
            }

            public override void Run()
            {
                this.adProxy.Call("show");
            }
        }
    }
#endif
}