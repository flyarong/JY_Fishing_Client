namespace Tencent.GDT
{
    using System.Collections.Generic;
    public interface INativeExpressAdListener
    {
        /// <summary>
        /// 拉取原生模板广告成功
        /// </summary>
        void OnAdLoaded(List<NativeExpressAdView> adList);

        /// <summary>
        /// 拉取原生模板广告失败
        /// </summary>
        void OnError(AdError error);

        /// <summary>
        /// 原生模板广告渲染成功
        /// </summary>
        void OnAdViewRenderSuccess(NativeExpressAdView adView);

        /// <summary>
        /// 原生模板广告渲染失败
        /// </summary>
        void OnAdViewRenderFailed(NativeExpressAdView adView);

        /// <summary>
        /// 原生模板广告曝光回调
        /// </summary>
        void OnAdExposured(NativeExpressAdView adView);

        /// <summary>
        /// 原生模板广告点击回调
        /// </summary>
        void OnAdClicked(NativeExpressAdView adView);

        /// <summary>
        /// 因为广告点击等原因离开当前 app 时调用
        /// </summary>
        void OnAdLeaveApp(NativeExpressAdView adView);

        /// <summary>
        /// 原生模板广告被关闭
        /// </summary>
        void OnAdClosed(NativeExpressAdView adView);

        /// <summary>
        /// 点击原生模板广告,弹出全屏广告页
        /// </summary>
        void OnDetailPageShown(NativeExpressAdView adView);

        /// <summary>
        /// 全屏广告页已经关闭
        /// </summary>
        void OnDetailPageClosed(NativeExpressAdView adView);

        /// <summary>
        /// 原生视频模板详情页已经展示
        /// </summary>
        void OnVideoDetailPageShown(NativeExpressAdView adView);

        /// <summary>
        /// 原生视频模板详情页已经消失
        /// </summary>
        void OnVideoDetailPageClosed(NativeExpressAdView adView);

#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
        /// <summary>
        /// 视频下载完成，只有 Android 有这个回调
        /// </summary>
        void OnVideoCached(NativeExpressAdView adView);
#endif

        /// <summary>
        /// 视频播放 View 初始化完成
        /// </summary>
        void OnVideoInit(NativeExpressAdView adView);

        /// <summary>
        /// 视频下载中
        /// </summary>
        void OnVideoLoading(NativeExpressAdView adView);

        /// <summary>
        /// 视频开始播放
        /// </summary>
        void OnVideoStarted(NativeExpressAdView adView);

        /// <summary>
        /// 视频暂停
        /// </summary>
        void OnVideoPaused(NativeExpressAdView adView);

        /// <summary>
        /// 视频播放停止
        /// </summary>
        void OnVideoCompleted(NativeExpressAdView adView);

        /// <summary>
        /// 视频播放时出现错误
        /// </summary>
        void OnVideoError(NativeExpressAdView adView, AdError error);
    }
}