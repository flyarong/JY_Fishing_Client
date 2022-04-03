namespace Tencent.GDT
{
#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
    using UnityEngine;
    internal class UnifiedInterstitialAdListenerProxy : AndroidJavaProxy
    {
        internal IUnifiedInterstitialAdListener listener = null;

        internal UnifiedInterstitialAdListenerProxy() : base("com.qq.e.ads.interstitial2.UnifiedInterstitialADListener") { }

        void onADReceive()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdLoaded();
        }

        void onVideoCached()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoCached();
        }

        void onNoAD(AndroidJavaObject adError)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnError(new AdError(adError));
        }

        void onADOpened()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdShown();
        }

        void onADExposure()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdExposured();
        }

        void onADClicked()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdClicked();
        }

        void onADLeftApplication()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdLeaveApp();
        }

        void onADClosed()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdClosed();
        }

    }
#endif
}