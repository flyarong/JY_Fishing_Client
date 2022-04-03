using UnityEngine;
using Tencent.GDT;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using LuaFramework;
using LitJson;
using System.Threading;

public class YLHIntersititial
{
    private UnifiedInterstitialAd noVideoAd;
    private UnifiedInterstitialAd fullScreenVideoAd;
    private static bool isLoaded = false; // 因为调用 aar 中的方法有一定的耗时，所以，不能简单通过 rewardVideoAd == null 来判断是否能够 ShowAD

    private static YLHIntersititial m_instance;
    private string coid_id;
    public static YLHIntersititial Instance
    {
        get
        {
            if (m_instance == null)
                m_instance = new YLHIntersititial();
            return m_instance;
        }
    }

    //加载非全屏视频/图文插屏广告
    public void LoadNoVideoAd(string json_data, LuaFunction call)
    {
        isLoaded = false;
        JsonData jsonData = JsonMapper.ToObject(json_data);
        coid_id = jsonData["coid_id"].ToString();
        bool isVideoMuted = bool.Parse(jsonData["isVideoMuted"].ToString());
        bool isDetailVideoMuted = bool.Parse(jsonData["isDetailVideoMuted"].ToString());
        int minV = int.Parse(jsonData["minV"].ToString());
        int maxV = int.Parse(jsonData["maxV"].ToString());

        noVideoAd = new UnifiedInterstitialAd(coid_id);
        noVideoAd.SetListener(new UnifiedInterstitialAdListener(coid_id,call));
        noVideoAd.SetVideoMuted(isVideoMuted);
        noVideoAd.SetDetailPageVideoMuted(isDetailVideoMuted);
        noVideoAd.SetMinVideoDuration(minV);
        noVideoAd.SetMaxVideoDuration(maxV);
        noVideoAd.LoadAd();
    }

    //展示非全屏视频/图文插屏广告
    public void ShowNoVideoAd(LuaFunction call)
    {
        if (noVideoAd == null || !isLoaded)
        {
            string msg = "请先加载广告";
            if (!isLoaded) {
                msg = "等待广告加载完成";
            }
            //ToastHelper.ShowToast(msg);
            if(call != null)
                call.Call(coid_id);
            return;
        }
        Debug.unityLogger.Log("UnifiedInterstitialNoVideoAd ecpmlevel=" + noVideoAd.GetECPMLevel());
        noVideoAd.Show();
    }

    //加载全屏视频插屏广告
    public void LoadFullScreenVideoAd(string json_data1, LuaFunction call)
    {
        isLoaded = false;
        JsonData jsonData1 = JsonMapper.ToObject(json_data1);
        coid_id = jsonData1["coid_id"].ToString();
        bool isVideoMuted = bool.Parse(jsonData1["isVideoMuted"].ToString());
        bool isDetailVideoMuted = bool.Parse(jsonData1["isDetailVideoMuted"].ToString());
        int minV = int.Parse(jsonData1["minV"].ToString());
        int maxV = int.Parse(jsonData1["maxV"].ToString());
        fullScreenVideoAd = new UnifiedInterstitialAd(coid_id);
        fullScreenVideoAd.SetListener(new UnifiedInterstitialAdListener(coid_id,call));
        fullScreenVideoAd.SetVideoMuted(isVideoMuted); // 视频是否静音播放
        fullScreenVideoAd.LoadFullScreenAd();
    }

    //展示全屏视频插屏广告
    public void ShowFullScreenVideoAd(LuaFunction call)
    {
        if (fullScreenVideoAd == null || !isLoaded)
        {
            string msg = "请先加载广告";
            if (!isLoaded) {
                msg = "等待广告加载完成";
            }
            //ToastHelper.ShowToast(msg);
            if(call!= null)
                call.Call(coid_id);
            return;
        }
        Debug.unityLogger.Log("UnifiedInterstitialFullScreenVideoAd ecpmlevel=" + fullScreenVideoAd.GetECPMLevel());
        fullScreenVideoAd.ShowFullScreenAd();
    }

    class UnifiedInterstitialAdListener : IUnifiedInterstitialAdListener
    {
        private string _coid_id;
        private LuaFunction _call;
        public UnifiedInterstitialAdListener(string coid_id, LuaFunction call)
         {
            _coid_id = coid_id;
            _call = call;
        }

        /// <summary>
        /// 插屏2.0广告预加载成功回调
        /// </summary>
        public void OnAdLoaded()
        {
            isLoaded = true;
            string msg = "OnAdLoaded";
            // ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg,_call,_coid_id);
        }

        /// <summary>
        /// 加载插屏2.0广告错误
        /// </summary>
        public void OnError(AdError error)
        {
            string msg = "OnError" + error.GetErrorMsg();
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 插屏2.0广告展示时调用
        /// </summary>
        public void OnAdShown()
        {
            string msg = "OnAdShown";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 插屏2.0广告曝光回调
        /// </summary>
        public void OnAdExposured()
        {
            string msg = "OnAdExposured";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 插屏2.0广告点击时回调
        /// </summary>
        public void OnAdClicked()
        {
            string msg = "OnAdClicked";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 离开当前app时回调
        /// </summary>
        public void OnAdLeaveApp()
        {
            string msg = "OnAdLeaveApp";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 插屏2.0广告关闭时回调
        /// </summary>
        public void OnAdClosed()
        {
            string msg = "OnAdClosed";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

#if UNITY_ANDROID || UNITY_EDITOR
        /// <summary>
        /// 视频下载完成，只有 Android 有这个回调
        /// </summary>
        public void OnVideoCached()
        {
            // 视频素材加载完成，在此时调用展示，视频广告不会有进度条。
            string msg = "OnVideoCached";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }
#endif

        /// <summary>
        /// 视频播放 View 初始化完成
        /// </summary>
        public void OnVideoInit()
        {
            string msg = "OnVideoInit";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 视频下载中
        /// </summary>
        public void OnVideoLoading()
        {
            string msg = "OnVideoLoading";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 视频开始播放
        /// </summary>
        public void OnVideoStarted()
        {
            string msg = "OnVideoStarted";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 视频暂停
        /// </summary>
        public void OnVideoPaused()
        {
            string msg = "OnVideoPaused";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 视频播放停止
        /// </summary>
        public void OnVideoCompleted()
        {
            string msg = "OnVideoCompleted";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 视频播放时出现错误
        /// </summary>
        public void OnVideoError()
        {
            string msg = "OnVideoError";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }

        /// <summary>
        /// 进入视频落地页
        /// </summary>
        public void OnVideoDetailPageShown()
        {
            string msg = "OnVideoDetailPageShown";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }
        /// <summary>
        /// 退出视频落地页
        /// </summary>
        public void OnVideoDetailPageClosed()
        {
            string msg = "OnVideoDetailPageClosed";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
        }
    }
}