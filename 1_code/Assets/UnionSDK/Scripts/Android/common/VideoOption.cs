namespace Tencent.GDT
{
#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    public class VideoOption
    {

        internal class AutoPlayPolicy
        {
            public const int WIFI = 0; // WiFi下自动播放，非WiFi手动点击播放；
            public const int ALWAYS = 1; // 总是自动播放，无论什么网络条件
            public const int NEVER = 2; // 从不自动播放，无论什么网络条件
        }

        // 从用户的角度看，视频是否是自动播放的
        // 如设置为从不自动播放，但开发者调用startVideo接口进行播放，在用户看来，仍然是自动播放的
        public static class VideoPlayPolicy
        {
            public const int UNKNOWN = 0;
            public const int AUTO = 1; // 视频播放无需用户交互参与
            public const int MANUAL = 2; // 视频播放需要用户参与交互
        }

        private int autoPlayPolicy = AutoPlayPolicy.ALWAYS;
        private bool autoPlayMuted = true;
        private bool detailPageMuted = false;

        public VideoOption()
        {

        }

        internal void SetAutoPlayPolicy(int policy)
        {
            this.autoPlayPolicy = policy;
        }

        internal void SetAutoPlayMuted(bool muted)
        {
            this.autoPlayMuted = muted;
        }

        internal void SetDetailPageMuted(bool muted)
        {
            this.detailPageMuted = muted;
        }

        public AndroidJavaObject GetVideoOption()
        {
            AndroidJavaObject builder = new AndroidJavaObject("com.qq.e.ads.cfg.VideoOption$Builder");
            builder.Call<AndroidJavaObject>("setAutoPlayPolicy", autoPlayPolicy);
            builder.Call<AndroidJavaObject>("setAutoPlayMuted", autoPlayMuted);
            builder.Call<AndroidJavaObject>("setDetailPageMuted", detailPageMuted);
            return builder.Call<AndroidJavaObject>("build");
        }
    }
#endif
}