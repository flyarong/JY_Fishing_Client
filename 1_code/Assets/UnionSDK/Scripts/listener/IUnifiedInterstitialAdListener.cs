namespace Tencent.GDT
{
    public interface IUnifiedInterstitialAdListener
    {
        /// <summary>
        /// 插屏2.0广告预加载成功回调
        /// </summary>
        void OnAdLoaded();

        /// <summary>
        /// 加载插屏2.0广告错误
        /// </summary>
        void OnError(AdError error);

        /// <summary>
        /// 插屏2.0广告展示时调用
        /// </summary>
        void OnAdShown();

        /// <summary>
        /// 插屏2.0广告曝光回调
        /// </summary>
        void OnAdExposured();

        /// <summary>
        /// 插屏2.0广告点击时回调
        /// </summary>
        void OnAdClicked();

        /// <summary>
        /// 离开当前app时回调
        /// </summary>
        void OnAdLeaveApp();

        /// <summary>
        /// 插屏2.0广告关闭时回调
        /// </summary>
        void OnAdClosed();

#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
        /// <summary>
        /// 视频下载完成，只有 Android 有这个回调
        /// </summary>
        void OnVideoCached();
#endif

        /// <summary>
        /// 视频播放 View 初始化完成
        /// </summary>
        void OnVideoInit();

        /// <summary>
        /// 视频下载中
        /// </summary>
        void OnVideoLoading();

        /// <summary>
        /// 视频开始播放
        /// </summary>
        void OnVideoStarted();

        /// <summary>
        /// 视频暂停
        /// </summary>
        void OnVideoPaused();

        /// <summary>
        /// 视频播放停止
        /// </summary>
        void OnVideoCompleted();

        /// <summary>
        /// 视频播放时出现错误
        /// </summary>
        void OnVideoError();

        /// <summary>
        /// 进入视频落地页
        /// </summary>
        void OnVideoDetailPageShown();

        /// <summary>
        /// 退出视频落地页
        /// </summary>
        void OnVideoDetailPageClosed();
    }
}
