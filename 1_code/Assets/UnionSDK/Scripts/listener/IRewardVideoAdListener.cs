using UnityEngine;

namespace Tencent.GDT
{
    public interface IRewardVideoAdListener
    {
        /// <summary>
        /// 广告加载成功，可在此回调后进行广告展示
        /// </summary>
        void OnAdLoaded();

        /// <summary>
        /// 激励视频数据下载成功回调，已经下载过的视频会直接回调
        /// </summary>
        void OnVideoCached();

        /// <summary>
        /// 激励视频广告页面展示回调
        /// </summary>
        void OnAdShown();

        /// <summary>
        /// 激励视频广告曝光回调
        /// </summary>
        void OnAdExposured();

        /// <summary>
        /// 激励视频广告播放达到激励条件回调，以此回调作为奖励依据
        /// </summary>
        void OnRewarded();

        /// <summary>
        /// 激励视频广告信息点击回调
        /// </summary>
        void OnAdClicked();

        /// <summary>
        /// 激励视频广告播放完成回调
        /// </summary>
        void OnVideoCompleted();

        /// <summary>
        /// 激励视频广告播放页关闭回调
        /// </summary>
        void OnAdClosed();

        /// <summary>
        /// 激励视频广告各种错误信息回调
        /// </summary>
        void OnError(AdError error);
    }
}