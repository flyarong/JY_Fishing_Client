namespace Tencent.GDT
{
#if UNITY_ANDROID
    using UnityEngine;
#elif UNITY_IOS
    using System;
#endif

    internal interface IUnifiedBannerAd
    {
        void SetAutoSwitchInterval(int autoSwitchInterval);

        void SetListener(IUnifiedBannerAdListener listener);

        void LoadAndShowAd();

        void CloseAd();

#if UNITY_ANDROID
        AndroidJavaObject GetAndroidNativeView();
#elif UNITY_IOS
        IntPtr GetIOSNativeView();
#endif
    }
}