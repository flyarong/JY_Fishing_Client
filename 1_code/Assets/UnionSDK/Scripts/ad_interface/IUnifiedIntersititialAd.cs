namespace Tencent.GDT
{
    internal interface IUnifiedInterstitialAd
    {
        void SetListener(IUnifiedInterstitialAdListener listener);

        void Show();

        void ShowFullScreenAd();

        void LoadAd();

        void LoadFullScreenAd();

        void SetMinVideoDuration(int duration);

        void SetMaxVideoDuration(int duration);

        void SetVideoMuted(bool muted);

        void SetDetailPageVideoMuted(bool muted);

        void SetVideoAutoPlayWhenNoWifi(bool autoPlay);

        string GetECPMLevel();
    }
}