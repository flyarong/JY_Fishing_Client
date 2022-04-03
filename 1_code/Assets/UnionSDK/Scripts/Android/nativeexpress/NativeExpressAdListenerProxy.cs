namespace Tencent.GDT
{
#if UNITY_ANDROID
    using UnityEngine;
    using System.Collections.Generic;

    internal class NativeExpressAdListenerProxy : AndroidJavaProxy
    {
        internal INativeExpressAdListener listener = null;
        internal NativeExpressMediaListenerProxy mediaListenerProxy;

        internal NativeExpressAdListenerProxy() : base("com.qq.e.ads.nativ.NativeExpressAD$NativeExpressADListener") { }

        public void onNoAD(AndroidJavaObject error)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnError(new AdError(error));
        }
        /** 广告数据加载成功 */
        public void onADLoaded(AndroidJavaObject adList)
        {
            if (listener == null)
            {
                return;
            }
            List<NativeExpressAdView> adViewList = Utils.ConvertJavaListToCSharpList(adList);
            // 这里强制为每一个 NativeExpressAdView 都设置了 MediaListener，不管是否是视频广告
            for (int i = 0; i < adViewList.Count; i++)
            {
                adViewList[i].SetMediaListener(mediaListenerProxy);
            }
            listener.OnAdLoaded(adViewList);
        }

        /** 渲染广告失败 */
        public void onRenderFail(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdViewRenderFailed(new NativeExpressAdView(adView));
        }

        /** 渲染广告成功 */
        public void onRenderSuccess(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdViewRenderSuccess(new NativeExpressAdView(adView));
        }

        /** 广告曝光 */
        public void onADExposure(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdExposured(new NativeExpressAdView(adView));
        }

        /** 当广告点击时调用，重复点击会多次调用 */
        public void onADClicked(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdClicked(new NativeExpressAdView(adView));
        }

        /** 广告被关闭时调用 */
        public void onADClosed(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdClosed(new NativeExpressAdView(adView));
        }

        /** 因为广告点击等原因离开当前app时调用 */
        public void onADLeftApplication(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdLeaveApp(new NativeExpressAdView(adView));
        }

        /** 广告打开详情页时调用 */
        public void onADOpenOverlay(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnDetailPageShown(new NativeExpressAdView(adView));
        }

        /** 广告关闭详情页时调用 */
        public void onADCloseOverlay(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnDetailPageClosed(new NativeExpressAdView(adView));
        }
    }
#endif
}