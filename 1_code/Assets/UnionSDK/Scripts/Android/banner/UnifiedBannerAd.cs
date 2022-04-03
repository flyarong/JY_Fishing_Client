namespace Tencent.GDT
{
#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
    using UnityEngine;
    public class UnifiedBannerAd : IUnifiedBannerAd
    {
        private AndroidJavaObject ad = null;
        private UnifiedBannerAdListenerProxy listenerProxy = new UnifiedBannerAdListenerProxy();

        public UnifiedBannerAd(string posId, AdSize adSize)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            ad = new AndroidJavaObject("com.qq.e.ads.banner2.UnifiedBannerView", Utils.GetActivity(), posId, listenerProxy);
        }

        public void SetListener(IUnifiedBannerAdListener listener)
        {
            listenerProxy.listener = listener;
        }

        public void LoadAndShowAd()
        {
            if (CheckNotReady())
            {
                return;
            }
            ad.Call("loadAD");
        }

        public void CloseAd()
        {
            if (CheckNotReady())
            {
                return;
            }
            Utils.RemoveFromSuperView(ad);
            ad.Call("destroy");
        }

        public void SetAutoSwitchInterval(int autoSwitchInterval)
        {
            if (CheckNotReady())
            {
                return;
            }
            ad.Call("setRefresh", autoSwitchInterval);
        }

        public AndroidJavaObject GetAndroidNativeView()
        {
            if (CheckNotReady())
            {
                return null;
            }
            return ad;
        }

        /* 检查是否未准备好 */
        private bool CheckNotReady()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return true;
            }
            if (ad == null)
            {
                Debug.Log("请先加载广告");
                return true;
            }
            return false;
        }
    }
#endif
}