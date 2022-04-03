namespace Tencent.GDT
{
#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
    using UnityEngine;
    internal class UnifiedInterstitialMediaListenerProxy : AndroidJavaProxy
    {
        internal IUnifiedInterstitialAdListener listener = null;

        internal UnifiedInterstitialMediaListenerProxy() : base("com.qq.e.ads.interstitial2.UnifiedInterstitialMediaListener") { }

        void onVideoInit()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoInit();
        }

        void onVideoLoading()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoLoading();
        }

        void onVideoReady(long videoDuration)
        {
            // 暂不支持
        }

        void onVideoStart()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoStarted();
        }

        void onVideoPause()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoPaused();
        }

        void onVideoComplete()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoCompleted();
        }

        void onVideoError(AndroidJavaObject error)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoError();
        }

        void onVideoPageOpen()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoDetailPageShown();
        }

        void onVideoPageClose()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoDetailPageClosed();
        }
    }
#endif
}