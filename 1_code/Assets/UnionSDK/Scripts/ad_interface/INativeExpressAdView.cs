namespace Tencent.GDT
{
#if UNITY_ANDROID
    using UnityEngine;
#elif UNITY_IOS
    using System;
#endif

    internal interface INativeExpressAdView
    {
        void Render();

        void CloseAd();

        string GetECPMLevel();

#if UNITY_ANDROID
        AndroidJavaObject GetAndroidNativeView();
#elif UNITY_IOS
        IntPtr GetIOSNativeView();
#endif
    }
}