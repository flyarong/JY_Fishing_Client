namespace Tencent.GDT
{
#if UNITY_IOS
    using System.Runtime.InteropServices;
    using UnityEngine;
    public class GDTSDKManager
    {
        private static string appId;

        public static bool Init(string appId)
        {
            if(appId == null || appId.Length == 0)
            {
                Debug.Log("GDT SDK 初始化错误，APPID 错误");
                return false;
            }
			GDTSDKManager.appId = appId;
            registerAppId(appId);
            return true;
        }

        internal static bool CheckInit()
        {
            if(appId == null || appId.Length == 0)
            {
                Debug.Log("请先初始化 SDK");
                return false;
            }
            return true;
        }

        [DllImport ("__Internal")]
        private static extern void registerAppId(string appId);
    }
#endif
}
