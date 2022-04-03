namespace Tencent.GDT
{
    public interface IUnifiedBannerAdListener
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
        /// 由于广告点击离开 APP 时调用
        /// </summary>
        void OnAdLeaveApp();

        /// <summary>
        /// banner2.0被用户关闭时调用
        /// </summary>
        void OnAdClosed();

        /// <summary>
        /// banner2.0广告点击以后弹出全屏广告页完毕
        /// </summary>
        void OnDetailPageShown();

        /// <summary>
        /// 全屏广告页已经被关闭
        /// </summary>
        void OnDetailPageClosed();
    }
}