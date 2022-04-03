namespace Tencent.GDT
{
    internal interface IRewardVideoAd
    {
        void SetVideoMuted(bool muted);

        void SetListener(IRewardVideoAdListener listener);

        // 加载激励视频
        void LoadAd();

        // 展示激励视频
        void ShowAD();

        long GetExpireTimestamp();

        string GetECPMLevel();
    }
}