namespace Tencent.GDT
{
#if UNITY_ANDROID
    using UnityEngine;

    public sealed class SplashAd : ISplashAd
    {
        private AndroidJavaObject splashAd;
        internal AndroidJavaObject container;
        private string posId;
        private int fetchDelay;
        private AndroidJavaObject skipView;
        private SplashAdListenerProxy listenerProxy;
        internal long expireTime;

        public SplashAd(string posId)
        {
            GDTSDKManager.CheckInit();
            this.posId = posId;
            this.listenerProxy = new SplashAdListenerProxy(this);
        }

        private void init()
        {
            if (splashAd == null)
            {
                splashAd = new AndroidJavaObject("com.qq.e.ads.splash.SplashAD", Utils.GetActivity(), skipView, posId, listenerProxy, fetchDelay);
            }
        }

        public void SetListener(ISplashAdListener listener)
        {
            listenerProxy.listener = listener;
        }

        public void LoadAd()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            // 由于 Android 的 fetchDelay 和 skipView 不允许动态设置，故只能延迟初始化
            init();
            this.splashAd.Call("fetchAdOnly");
        }

        public void Preload()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            // 由于 Android 的 fetchDelay 和 skipView 不允许动态设置，故只能延迟初始化
            init();
            splashAd.Call("preLoad");
        }

        /**
         * @param duration 单位毫秒
         */
        public void SetFetchDelay(int duration)
        {
            this.fetchDelay = duration;
        }

        public void SetSkipView(object skipView)
        {
            this.skipView = (AndroidJavaObject)skipView;
        }

        public void Show(object container)
        {
            AndroidJavaObject splashContainer = (AndroidJavaObject)container;
            if (CheckNotReady())
            {
                return;
            }
            this.splashAd.Call("showAd", splashContainer);
            this.container = splashContainer;
        }

        public bool IsValid()
        {
            if (CheckNotReady() || expireTime <= 0)
            {
                return false;
            }
            long nowTime = Utils.GetSystemClockElapsedRealtime();
            return nowTime < expireTime;
        }

        public string GetECPMLevel()
        {
            if (CheckNotReady())
            {
                return null;
            }
            return splashAd.Call<string>("getECPMLevel");
        }

        /* 检查是否未准备好 */
        private bool CheckNotReady()
        {
            if (!GDTSDKManager.CheckInit())
            {
                return true;
            }
            if (splashAd == null)
            {
                Debug.Log("请先加载广告");
                return true;
            }
            return false;
        }
    }
#endif
}