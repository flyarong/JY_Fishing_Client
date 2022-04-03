namespace Tencent.GDT
{
    using System;
    internal interface ISplashAd
    {
        void SetListener(ISplashAdListener listener);

        void LoadAd();

        /**
         * @param duration 单位毫秒
         */
        void SetFetchDelay(int duration);

        void SetSkipView(object skipView);

#if UNITY_IOS
        void SetBottomView(IntPtr bottomView);
        void SetSkipViewCenter(float x, float y);
#endif

        void Show(object container);

        bool IsValid();

        string GetECPMLevel();

        void Preload();
    }
}