using UnityEngine;

namespace Tencent.GDT
{
    public class AdSize
    {
        public static readonly int FULL_WIDTH = -1;
        public static readonly int AUTO_HEIGHT = -2;
        public int width;
        public int height;

        public AdSize(int width, int height)
        {
            this.height = height;
            this.width = width;
        }
//#if UNITY_ANDROID
        internal AndroidJavaObject GetAndroidAdSize()
        {
            return new AndroidJavaObject("com.qq.e.ads.nativ.ADSize", width, height); ;
        }
//#endif
        public int GetHeight()
        {
            return height;
        }

        public int GetWidth()
        {
            return width;
        }
    }
}