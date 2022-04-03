using UnityEngine;
using Tencent.GDT;
using LuaInterface;
using LuaFramework;
using LitJson;
using System;
using System.Collections.Generic;

public class YLHRewardVideo
{
    private static YLHRewardVideo m_instance;
    public static YLHRewardVideo Instance
    {
        get
        {
            if (m_instance == null)
                m_instance = new YLHRewardVideo();
            return m_instance;
        }
    }
    /**激励视频**/
#if  UNITY_ANDROID || UNITY_IOS 
    private RewardVideoAd rewardVideoAd;
    private string coid_id;
#endif
    //激励视频声音开关
    private static bool isLoaded = false; // 因为调用 aar 中的方法有一定的耗时，所以，不能简单通过 rewardVideoAd == null 来判断是否能够 ShowAD

    public long GetExpireTimestamp()
    {
    #if  UNITY_ANDROID || UNITY_IOS 

        if (rewardVideoAd == null || !isLoaded)
        {
            string msg = "请先加载广告";    
            if (!isLoaded) {
                msg = "等待广告加载完成";
            }
            return 0;
        }
        return rewardVideoAd.GetExpireTimestamp();
    #else
        return 0l;
    #endif
    }
    // 加载激励视频
    public void LoadRewardVideoAd(string json_data, LuaFunction call)
    {
#if UNITY_ANDROID || UNITY_IOS
        JsonData jsonData = JsonMapper.ToObject(json_data);
        coid_id = jsonData["coid_id"].ToString();
        bool volumeOn = bool.Parse(jsonData["volumeOn"].ToString());

        isLoaded = false;
        rewardVideoAd = new RewardVideoAd(coid_id);
        rewardVideoAd.SetListener(new RewardVideoADListener(coid_id,call));
        rewardVideoAd.SetVideoMuted(!volumeOn);
        this.rewardVideoAd.LoadAd();
        
#endif
    }

    // 展示激励视频
    public void ShowRewardVideoAd(LuaFunction call)
    {
#if UNITY_ANDROID || UNITY_IOS
 
        if (rewardVideoAd == null || !isLoaded)
        {
            string msg = "请先加载广告";    
            if (!isLoaded) {
                msg = "等待广告加载完成";
            }
            Main.LuaCallBack(msg, call, coid_id);
            return;
        }
#endif

#if UNITY_IOS
        this.rewardVideoAd.SetEnableDefaultAudioSessionSetting(false);
#endif

#if UNITY_ANDROID || UNITY_IOS
        this.rewardVideoAd.ShowAD();
#endif
    }

    //激励视频生命周期回调
    private sealed class RewardVideoADListener : IRewardVideoAdListener
    {
        private string _coid_id;
        private LuaFunction _call;
        public RewardVideoADListener (string coid_id, LuaFunction call)
        {
            _coid_id = coid_id;
            _call = call;
        }
        /// <summary>
        /// 广告加载成功，可在此回调后进行广告展示
        /// </summary>
        public void OnAdLoaded()
        {
            isLoaded = true;
            string msg = "OnAdLoaded";
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 激励视频数据下载成功回调，已经下载过的视频会直接回调
        /// </summary>
        public void OnVideoCached()
        {
            string msg = "OnVideoCached";
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 激励视频广告页面展示回调
        /// </summary>
        public void OnAdShown()
        {
            string msg = "OnAdShown";
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 激励视频广告曝光回调
        /// </summary>
        public void OnAdExposured()
        {
            string msg = "OnAdExposured";
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 激励视频广告播放达到激励条件回调，以此回调作为奖励依据
        /// </summary>
        public void OnRewarded()
        {
            string msg = "OnRewarded";
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 激励视频广告信息点击回调
        /// </summary>
        public void OnAdClicked()
        {
            string msg = "OnAdClicked";
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 激励视频广告播放完成回调
        /// </summary>
        public void OnVideoCompleted()
        {
            string msg = "OnVideoCompleted";
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 激励视频广告播放页关闭回调
        /// </summary>
        public void OnAdClosed()
        {
            string msg = "OnAdClosed";
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 激励视频广告各种错误信息回调
        /// </summary>
        public void OnError(AdError error)
        {
            int errorcode = error.GetErrorCode();
            string errormsg = error.GetErrorMsg();
            string msg = "OnError" + errormsg;
            Main.LuaCallBack(msg, _call, _coid_id);
        }
    }
}