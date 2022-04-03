using System;
using System.Runtime.InteropServices;

public class IOSUtils
{
    public static void ShowView(IntPtr view)
    {
        GDT_UnionPlatform_Ad_ShowAdView(view);
    }

    [DllImport("__Internal")]
    private static extern void GDT_UnionPlatform_Ad_ShowAdView(IntPtr adView);
}