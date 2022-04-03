namespace Tencent.GDT
{
#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
    using UnityEngine;

    internal class UnifiedBannerAdListenerProxy : AndroidJavaProxy
    {
        internal IUnifiedBannerAdListener listener = null;
        public UnifiedBannerAdListenerProxy() : base("com.qq.e.ads.banner2.UnifiedBannerADListener") { }

        /**
         * 加载广告失败，自动轮播时仅在第一次获取广告失败时回调此方法。
         */
        public void onNoAD(AndroidJavaObject adError)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnError(new AdError(adError));
        }


        /**
         * 加载广告成功
         */
        public void onADReceive()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdLoaded();
        }


        /**
         * 广告曝光
         */
        public void onADExposure()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdExposured();
        }

        /**
         * 广告被关闭时调用 该回调仅在设置了showCloseButton为true时有可能触发
         */
        public void onADClosed()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdClosed();
        }


        /**
         * 当广告点击时调用，重复点击会多次调用。 因此点击量会和平台最终的统计结果有一定差异
         */
        public void onADClicked()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdClicked();
        }

        /** 因为广告点击等原因离开当前app时调用 */
        public void onADLeftApplication()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdLeaveApp();
        }

        /** 广告打开详情页时调用 */
        public void onADOpenOverlay()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnDetailPageShown();
        }

        /** 广告关闭详情页时调用 */
        public void onADCloseOverlay()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnDetailPageClosed();
        }
    }
#endif
}