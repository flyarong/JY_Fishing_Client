namespace Tencent.GDT
{
#if UNITY_ANDROID
    using UnityEngine;

    internal class SplashAdListenerProxy : AndroidJavaProxy
    {
        private SplashAd ad;
        internal ISplashAdListener listener = null;
        private bool hasPresent = false;

        public SplashAdListenerProxy(SplashAd ad) : base("com.qq.e.ads.splash.SplashADListener")
        {
            this.ad = ad;
        }

        void onADDismissed()
        {
            Utils.RemoveAllViewsInViewGroup(ad.container);
            if (listener == null)
            {
                return;
            }
            listener.OnAdClosed();
        }

        void onNoAD(AndroidJavaObject error)
        {
            if (hasPresent)
            {
                Utils.RemoveAllViewsInViewGroup(ad.container);
            }
            hasPresent = false;
            if (listener == null)
            {
                return;
            }
            listener.OnError(new AdError(error));
        }

        void onADPresent()
        {
            hasPresent = true;
            ad.expireTime = 0;
            if (listener == null)
            {
                return;
            }
            listener.OnAdShown();
        }

        void onADClicked()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdClicked();
        }

        void onADTick(long millisUntilFinished)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdTick(millisUntilFinished);
        }

        void onADExposure()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdExposured();
        }

        void onADLoaded(long expireTimestamp)
        {
            hasPresent = false;
            ad.expireTime = expireTimestamp;
            if (listener == null)
            {
                return;
            }
            listener.OnAdLoaded();
        }
    }
#endif
}