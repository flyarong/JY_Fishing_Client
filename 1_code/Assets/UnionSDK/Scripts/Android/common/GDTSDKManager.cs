namespace Tencent.GDT
{
#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
    using UnityEngine;
    public class GDTSDKManager
    {
        private static string appId;
        private static bool hasInit = false;

        public static bool Init(string appId)
        {
            AndroidJavaObject gdtAdManager = new AndroidJavaClass("com.qq.e.comm.managers.GDTADManager").CallStatic<AndroidJavaObject>("getInstance");
            hasInit = gdtAdManager.Call<bool>("initWith", Utils.GetActivity(), appId);
            return hasInit;
        }

        internal static bool CheckInit()
        {
            if(!hasInit)
            {
                Debug.unityLogger.Log("GDT_UNITY_LOG", "请先初始化 SDK ！");
            }
            return hasInit;
        }
    }
#endif    
}