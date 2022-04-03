namespace Tencent.GDT
{
#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
    using UnityEngine;
    internal class NativeExpressMediaListenerProxy : AndroidJavaProxy
    {
        internal INativeExpressAdListener listener = null;
        internal NativeExpressMediaListenerProxy() : base("com.qq.e.ads.nativ.NativeExpressMediaListener") { }

        public void onVideoInit(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoInit(new NativeExpressAdView(adView));
        }

        /**
         * 当视频开始下载时调用
         *
         * @param adView
         */
        public void onVideoLoading(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoLoading(new NativeExpressAdView(adView));
        }

        /**
         * 当视频下载成功时回调
         */
        public void onVideoCached(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoCached(new NativeExpressAdView(adView));
        }

        /**
         * 当视频已经就绪时回调
         *
         * @param adView
         * @param videoDuration 视频的长度
         */
        public void onVideoReady(AndroidJavaObject adView, long videoDuration)
        {

        }

        /**
         * 当视频开始播放时回调
         *
         * @param adView
         */
        public void onVideoStart(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoStarted(new NativeExpressAdView(adView));
        }

        /**
         * 当视频暂停时回调
         *
         * @param adView
         */
        public void onVideoPause(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoPaused(new NativeExpressAdView(adView));
        }

        /**
         * 当视频播放结束时回调
         *
         * @param adView
         */
        public void onVideoComplete(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoCompleted(new NativeExpressAdView(adView));
        }

        /**
         * 当视频发生错误时回调
         *
         * @see {@link AdError}
         * @param adView
         * @param error
         */
        public void onVideoError(AndroidJavaObject adView, AndroidJavaObject error)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoError(new NativeExpressAdView(adView), new AdError(error));
        }

        /**
         * 当视频页面打开时回调
         *
         * @param adView
         */
        public void onVideoPageOpen(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoDetailPageShown(new NativeExpressAdView(adView));
        }

        /**
         * 当视频页面关闭时回调
         *
         * @param adView
         */
        public void onVideoPageClose(AndroidJavaObject adView)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoDetailPageClosed(new NativeExpressAdView(adView));
        }
    }
#endif
}