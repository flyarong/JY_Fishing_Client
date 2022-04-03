using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Tencent.GDT;
using LuaInterface;
using LuaFramework;
using LitJson;
using System.Threading;


public class YLHBannerAd 
{

    private static YLHBannerAd m_instance;
    public static YLHBannerAd Instance
    {
        get
        {
            if (m_instance == null)
                m_instance = new YLHBannerAd();
            return m_instance;
        }
    }
   
    public UnifiedBannerAd ad;
    public void LoadAndShowBanner(string json_data, LuaFunction call)
    {

        JsonData jsonData = JsonMapper.ToObject(json_data);
        string coid_id = jsonData["coid_id"].ToString();
        int x = (int)jsonData["x"];
        int y = (int)jsonData["y"];
        int autoSwitchInterval = (int)jsonData["autoSwitchInterval"];
     
        Debug.Log("banner_xxxx:"+ coid_id);
        CloseBannerAdView();
        // Android 不能设置 banner 宽高，故 ADSize 参数对 Android 无效，设置任意都行
        ad = new UnifiedBannerAd(coid_id, new AdSize(x, y));
        ad.SetListener(new BannerListener(coid_id, call));
        ad.SetAutoSwitchInterval(autoSwitchInterval);
        ad.LoadAndShowAd();
#if UNITY_ANDROID
        AndroidUtils.ShowView(ad.GetAndroidNativeView(), true);
#elif UNITY_IOS
        IOSUtils.ShowView(ad.GetIOSNativeView());
#endif
    }

    public void CloseBannerAdView()
    {
        if (ad == null)
        {
            return;
        }
        ad.CloseAd();
        Debug.Log("退出广告 CloseBannerAdView");
    }

    private class BannerListener : IUnifiedBannerAdListener
    {
        private string _coid_id;
        private LuaFunction _call;
        public BannerListener(string coid_id, LuaFunction  call)
         {
            _coid_id = coid_id;
            _call = call;
        }
        /// <summary>
        /// 广告数据拉取成功
        /// </summary>
        public void OnAdLoaded( )
        {
            string msg = "OnAdLoaded";
            Main.LuaCallBack(msg, _call, _coid_id);

            //ToastHelper.ShowToast(msg);
            Debug.Log(msg);
        }
        /// <summary>
        /// 广告加载失败
        /// </summary>
        public void OnError(AdError error)
        {
            string msg = "OnError" + error.GetErrorMsg();
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
            Debug.Log(msg);
        }

        /// <summary>
        /// 当广告曝光时发起的回调
        /// </summary>
        public void OnAdExposured()
        {
            string msg = "OnAdExposured";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
            Debug.Log(msg);
        }

        /// <summary>
        /// 当广告点击时发起的回调
        /// </summary>
        public void OnAdClicked()
        {
            string msg = "OnAdClicked";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
            Debug.Log(msg);
        }

        /// <summary>
        /// 由于广告点击离开 APP 时调用
        /// </summary>
        public void OnAdLeaveApp()
        {
            string msg = "OnAdLeaveApp";
            // ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
            //Debug.unityLogger.Log(Constants.tagForLog, msg);
        }

        /// <summary>
        /// banner2.0被用户关闭时调用
        /// </summary>
        public void OnAdClosed()
        {
            string msg = "OnAdClosed";
            // ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
           // Debug.unityLogger.Log(Constants.tagForLog, msg);
            // CloseBannerAdView();  
        }

        /// <summary>
        /// banner2.0广告点击以后弹出全屏广告页完毕
        /// </summary>
        public void OnDetailPageShown()
        {
            string msg = "OnDetailPageShown";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
            Debug.Log(msg);
        }

        /// <summary>
        /// 全屏广告页已经被关闭
        /// </summary>
        public void OnDetailPageClosed()
        {
            string msg = "OnDetailPageClosed";
            //ToastHelper.ShowToast(msg);
            Main.LuaCallBack(msg, _call, _coid_id);
            Debug.Log(msg);
        }
    }
    
    


}
