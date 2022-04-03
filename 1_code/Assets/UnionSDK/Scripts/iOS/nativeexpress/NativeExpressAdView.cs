namespace Tencent.GDT
{
#if UNITY_IOS
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;
    using UnityEngine;
    public class NativeExpressAdView : INativeExpressAdView
    {
        private IntPtr nativeExpressdViews;

        private IntPtr nativeExpressdView;

        private int index;

        internal NativeExpressAdView(IntPtr adView)
        {
            this.nativeExpressdView = adView;
        }

        internal NativeExpressAdView(IntPtr adViews, int index)
        {
            this.nativeExpressdViews = adViews;
            this.index = index;
        }

        public void CloseAd()
        {
            GDT_UnionPlatform_NativeExpressAd_CloseNativeExpressAdView(nativeExpressdViews, index);
        }

        public void Render()
        {
            GDT_UnionPlatform_NativeExpressAd_Render(nativeExpressdViews, index);
        }

        public string GetECPMLevel()
        {
            return GDT_UnionPlatform_NativeExpressAd_GetECPMLevel(nativeExpressdViews, index);
        }

        public IntPtr GetIOSNativeView() 
        {
            return GDT_UnionPlatform_NativeExpressAd_GetNativeView(nativeExpressdViews, index);
        }

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_NativeExpressAd_CloseNativeExpressAdView(IntPtr nativeExpressViewAdPtr, int index);

        [DllImport("__Internal")]
        private static extern void GDT_UnionPlatform_NativeExpressAd_Render(IntPtr nativeExpressViewAdPtr, int index);

        [DllImport("__Internal")]
        private static extern string GDT_UnionPlatform_NativeExpressAd_GetECPMLevel(IntPtr nativeExpressViewAdPtr, int index);

        [DllImport("__Internal")]
        private static extern IntPtr GDT_UnionPlatform_NativeExpressAd_GetNativeView(IntPtr nativeExpressViewAdPtr, int index);
    }
#endif
}
