namespace Tencent.GDT
{
    using UnityEngine;
    public class AdError
    {
        int code;
        string msg;

        /* 构造方法为 internal 访问权限，仅供 SDK 内部使用，这个方法后期加上 Android 条件编译 */
        internal AdError(AndroidJavaObject proxy)
        {
            this.code = proxy.Call<int>("getErrorCode");
            this.msg = proxy.Call<string>("getErrorMsg");
        }

        internal AdError(int errCode, string msg)
        {
            this.code = errCode;
            this.msg = msg;
        }

        internal AdError()
        {

        }

        public int GetErrorCode()
        {
            return code;
        }

        public string GetErrorMsg()
        {
            return msg;
        }
    }
}