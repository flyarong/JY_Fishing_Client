namespace Tencent.GDT
{
#if UNITY_ANDROID
    using UnityEngine;

    internal class RewardVideoAdListenerProxy : AndroidJavaProxy
    {

        internal IRewardVideoAdListener listener = null;

        public RewardVideoAdListenerProxy() : base("com.qq.e.ads.rewardvideo.RewardVideoADListener") { }
        /**
         * 广告加载成功，可在此回调后进行广告展示
         **/
        public void onADLoad()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdLoaded();
        }

        /**
         * 视频素材缓存成功，可在此回调后进行广告展示
         */
        public void onVideoCached()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoCached();
        }

        /**
         * 激励视频广告页面展示
         */
        public void onADShow()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdShown();
        }

        /**
         * 激励视频广告曝光
         */
        public void onADExpose()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdExposured();
        }

        /**
         * 激励视频触发激励（观看视频大于一定时长或者视频播放完毕）
         */
        public void onReward()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnRewarded();
        }

        /**
         * 激励视频广告被点击
         */
        public void onADClick()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdClicked();
        }

        /**
         * 激励视频播放完毕
         */
        public void onVideoComplete()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnVideoCompleted();
        }

        /**
         * 激励视频广告被关闭
         */
        public void onADClose()
        {
            if (listener == null)
            {
                return;
            }
            listener.OnAdClosed();
        }

        /**
         * 广告流程出错
         */
        public void onError(AndroidJavaObject error)
        {
            if (listener == null)
            {
                return;
            }
            listener.OnError(new AdError(error));
        }

    }
#endif
}