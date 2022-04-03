using UnityEngine;
using LuaFramework;
public class AndroidUtils
{
    private static AndroidJavaObject activity;
    public static void ShowView(AndroidJavaObject view, bool isWrapContent)
    {
        AndroidJavaObject adViewManager = new AndroidJavaClass("com.qq.e.union.demo.UnionAdViewManager").CallStatic<AndroidJavaObject>("getInstance");
        adViewManager.Call("showAdView", GetActivity(), view, isWrapContent);
    }

    public static AndroidJavaObject NewAdContainer()
    {
        AndroidJavaObject adViewManager = new AndroidJavaClass("com.qq.e.union.demo.UnionAdViewManager").CallStatic<AndroidJavaObject>("getInstance");
        return adViewManager.Call<AndroidJavaObject>("newFrameLayout", GetActivity());
    }

    private static AndroidJavaObject GetActivity()
    {
        if (activity == null)
        {
            activity = SDKInterface.Instance.GetJavaObj();
            //var unityPlayer = new AndroidJavaClass(
            //"com.unity3d.player.UnityPlayer");
            //activity = unityPlayer.GetStatic<AndroidJavaObject>(
            //    "currentActivity");
        }
        return activity;
    }
}