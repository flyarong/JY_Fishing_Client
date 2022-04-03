namespace Tencent.GDT
{
#if UNITY_ANDROID || (!UNITY_IOS && UNITY_EDITOR)
    using UnityEngine;
    internal abstract class Runnable : AndroidJavaProxy
    {
        internal Runnable() : base("java.lang.Runnable") { }

        public void run()
        {
            Run();
        }

        public abstract void Run();
    }
#endif
}