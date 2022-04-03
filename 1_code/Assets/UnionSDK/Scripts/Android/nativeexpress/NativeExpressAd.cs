namespace Tencent.GDT
{
#if UNITY_ANDROID
    using UnityEngine;
    public sealed class NativeExpressAd : INativeExpressAd
    {
        private AndroidJavaObject adProxy;
        private NativeExpressAdListenerProxy listenerProxy = new NativeExpressAdListenerProxy();
        private NativeExpressMediaListenerProxy mediaListenerProxy = new NativeExpressMediaListenerProxy();
        private VideoOption videoOption = new VideoOption();

        public NativeExpressAd(string posId, AdSize adSize)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            listenerProxy.mediaListenerProxy = mediaListenerProxy;
            adProxy = new AndroidJavaObject("com.qq.e.ads.nativ.NativeExpressAD", Utils.GetActivity(), adSize.GetAndroidAdSize(), posId, listenerProxy);
        }
        public void SetListener(INativeExpressAdListener listener)
        {
            listenerProxy.listener = listener;
            mediaListenerProxy.listener = listener;
        }

        public void LoadAd(int count)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            adProxy.Call("setVideoOption", videoOption.GetVideoOption());
            adProxy.Call("loadAD", count);
        }


        public void SetMinVideoDuration(int duration)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            this.adProxy.Call("setMinVideoDuration", duration);
        }

        public void SetMaxVideoDuration(int duration)
        {
            if (!GDTSDKManager.CheckInit())
            {
                return;
            }
            this.adProxy.Call("setMaxVideoDuration", duration);
        }

        public void SetVideoMuted(bool muted)
        {
            videoOption.SetAutoPlayMuted(muted);
        }

        public void SetDetailPageVideoMuted(bool muted)
        {
            videoOption.SetDetailPageMuted(muted);
        }

        public void SetVideoAutoPlayWhenNoWifi(bool autoPlay)
        {
            videoOption.SetAutoPlayPolicy(autoPlay ? VideoOption.AutoPlayPolicy.ALWAYS : VideoOption.AutoPlayPolicy.WIFI);
        }
    }
#endif
}