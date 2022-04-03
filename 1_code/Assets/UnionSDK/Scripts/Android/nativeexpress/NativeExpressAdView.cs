namespace Tencent.GDT
{
#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
    using UnityEngine;
    public sealed class NativeExpressAdView : INativeExpressAdView
    {
        // 原生视频标识
        private const int TYPE_NATIVE_VIDEO = 2;

        private AndroidJavaObject adView;
        private RenderRunnable runnable;
        internal NativeExpressAdView(AndroidJavaObject adView)
        {
            this.adView = adView;
            runnable = new RenderRunnable(adView);
        }

        public void Render()
        {
            Utils.RunInMainThread(runnable);
        }

        public void CloseAd()
        {
            Utils.RemoveFromSuperView(adView);
            adView.Call("destroy");
        }

        public string GetECPMLevel()
        {
            AndroidJavaObject data = adView.Call<AndroidJavaObject>("getBoundData");
            if(data == null)
            {
                return null;
            }
            return data.Call<string>("getECPMLevel");
        }

        public AndroidJavaObject GetAndroidNativeView()
        {
            return adView;
        }

        public void PreloadVideo()
        {
            adView.Call("preloadVideo");
        }

        public bool IsVideoAd()
        {
            AndroidJavaObject data = adView.Call<AndroidJavaObject>("getBoundData");
            if(data == null)
            {
                return false;
            }
            return data.Call<int>("getAdPatternType") == TYPE_NATIVE_VIDEO;
        }

        internal void SetMediaListener(NativeExpressMediaListenerProxy listener)
        {
            adView.Call("setMediaListener", listener);
        }

        private class RenderRunnable : Runnable
        {
            private AndroidJavaObject adView;
            public RenderRunnable(AndroidJavaObject adView)
            {
                this.adView = adView;
            }
            public override void Run()
            {
                adView.Call("render");
            }
        }
    }
#endif
}