namespace Tencent.GDT
{
#if UNITY_ANDROID
    using UnityEngine;

    public sealed class RewardVideoAd : IRewardVideoAd
    {
        /**激励视频**/
        private AndroidJavaObject rewardVideoAd;
        //激励视频声音开关
        private bool volumeOn = false;
        private string posId;
        private RewardVideoAdListenerProxy listenerProxy = new RewardVideoAdListenerProxy();

        public RewardVideoAd(string posId)
        {
            GDTSDKManager.CheckInit();
            this.posId = posId;
        }

        public void SetVideoMuted(bool muted)
        {
            this.volumeOn = !muted;
        }

        public void SetListener(IRewardVideoAdListener listener)
        {
            listenerProxy.listener = listener;
        }

        // 加载激励视频
        public void LoadAd()
        {
            if(!GDTSDKManager.CheckInit())
            {
                return;
            }
            if (this.rewardVideoAd == null)
            {
                // 由于 Android 的静音参数不允许动态设置，故只能延迟初始化
                rewardVideoAd = new AndroidJavaObject("com.qq.e.ads.rewardvideo.RewardVideoAD",
                    Utils.GetActivity(), posId, listenerProxy, volumeOn);
            }
            this.rewardVideoAd.Call("loadAD");
        }

        // 展示激励视频
        public void ShowAD()
        {
            if (CheckNotReady())
            {
                return;
            }
            this.rewardVideoAd.Call("showAD");
        }

        public long GetExpireTimestamp()
        {
            if (CheckNotReady())
            {
                return -1L;
            }
            return this.rewardVideoAd.Call<long>("getExpireTimestamp");
        }

        public string GetECPMLevel()
        {
            if (CheckNotReady())
            {
                return null;
            }
            return rewardVideoAd.Call<string>("getECPMLevel");
        }

        /* 检查是否未准备好 */
        private bool CheckNotReady()
        {
            if(!GDTSDKManager.CheckInit())
            {
                return true;
            }
            if (rewardVideoAd == null)
            {
                Debug.Log("请先加载广告");
                return true;
            }
            return false;
        }
    }
#endif
}