namespace Tencent.GDT
{
    internal interface INativeExpressAd
    {
        void SetListener(INativeExpressAdListener listener);

        void LoadAd(int count);

        void SetMinVideoDuration(int duration);

        void SetMaxVideoDuration(int duration);

        void SetVideoMuted(bool muted);

        void SetDetailPageVideoMuted(bool muted);

        void SetVideoAutoPlayWhenNoWifi(bool autoPlay);
    }
}