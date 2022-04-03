namespace Tencent.GDT
{
#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
    using UnityEngine;
    using System.Collections.Generic;
    internal class Utils
    {
        // activity 对象，unity 只有一个 activity
        private static AndroidJavaObject activity;
        public static AndroidJavaObject GetActivity()
        {
            if (activity == null)
            {
                var unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
                activity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
            }
            return activity;
        }

        // 主线程 handler
        private static AndroidJavaObject mainHandler;
        public static void RunInMainThread(Runnable runnable)
        {
            if (mainHandler == null)
            {
                AndroidJavaClass classLooper = new AndroidJavaClass("android.os.Looper");
                AndroidJavaObject looper = classLooper.CallStatic<AndroidJavaObject>("getMainLooper");
                mainHandler = new AndroidJavaObject("android.os.Handler", looper);
            }
            mainHandler.Call<bool>("post", runnable);
        }

        public static List<NativeExpressAdView> ConvertJavaListToCSharpList(AndroidJavaObject adList)
        {
            List<NativeExpressAdView> adViewList = new List<NativeExpressAdView>();
            int size = adList.Call<int>("size");
            for (int i = 0; i < size; i++)
            {
                adViewList.Add(new NativeExpressAdView(adList.Call<AndroidJavaObject>("get", i)));
            }
            return adViewList;
        }

        public static long GetSystemClockElapsedRealtime()
        {
            AndroidJavaClass classSystemClock = new AndroidJavaClass("android.os.SystemClock");
            return classSystemClock.CallStatic<long>("elapsedRealtime");
        }

        // ViewGroup.class 对象，为了下面判断 viewparent instanceof ViewGroup
        private static AndroidJavaObject classViewGroup;
        public static void RemoveFromSuperView(AndroidJavaObject view)
        {
            if (view == null)
            {
                return;
            }
            AndroidJavaObject viewParent = view.Call<AndroidJavaObject>("getParent");
            if (viewParent == null)
            {
                return;
            }
            initViewGroupClass();
            if (classViewGroup.Call<bool>("isInstance", viewParent))
            {
                RunInMainThread(new RemoveViewRunnable(viewParent, view));
            }
        }

        public static void RemoveAllViewsInViewGroup(AndroidJavaObject viewGroup)
        {
            if (viewGroup == null)
            {
                return;
            }
            initViewGroupClass();
            if (classViewGroup.Call<bool>("isInstance", viewGroup))
            {
                RunInMainThread(new RemoveViewRunnable(viewGroup, null));
            }
        }

        private static void initViewGroupClass()
        {
            if (classViewGroup == null)
            {
                AndroidJavaClass classClass = new AndroidJavaClass("java.lang.Class");
                classViewGroup = classClass.CallStatic<AndroidJavaObject>("forName", "android.view.ViewGroup");
            }
        }

        private class RemoveViewRunnable : Runnable
        {
            private AndroidJavaObject parent;
            private AndroidJavaObject child;
            public RemoveViewRunnable(AndroidJavaObject parent, AndroidJavaObject child)
            {
                this.parent = parent;
                this.child = child;
            }
            public override void Run()
            {
                if (child == null)
                {
                    parent.Call("removeAllViews");
                }
                else
                {
                    parent.Call("removeView", child);
                }
            }
        }
    }
#endif
}