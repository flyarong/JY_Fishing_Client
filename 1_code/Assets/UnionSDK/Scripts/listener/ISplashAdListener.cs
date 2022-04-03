namespace Tencent.GDT
{
    public interface ISplashAdListener
    {
        /// <summary>
        /// 广告数据拉取成功
        /// </summary>
        void OnAdLoaded();

        /// <summary>
        /// 广告加载失败
        /// </summary>
        void OnError(AdError error);

        /// <summary>
        /// 当广告曝光时发起的回调
        /// </summary>
        void OnAdExposured();

        /// <summary>
        /// 当广告点击时发起的回调
        /// </summary>
        void OnAdClicked();

        /// <summary>
        /// 当广告被展示
        /// </summary>
        void OnAdShown();

        /// <summary>
        /// 当广告关闭时调用
        /// </summary>
        void OnAdClosed();

        /// <summary>
        /// 广告倒计时
        /// leftTime 单位 毫秒
        /// </summary>
        void OnAdTick(long leftTime);

#if UNITY_IOS
        /// <summary>
        /// 进入后台
        /// </summary>
        void OnApplicationBackground();
#endif
    }
}