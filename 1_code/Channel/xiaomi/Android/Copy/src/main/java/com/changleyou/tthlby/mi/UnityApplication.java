package com.changleyou.tthlby.mi;

import android.app.ActivityManager;
import android.app.Application;

import com.bun.miitmdid.core.JLibrary;
import com.wxsdk.my.MiitHelper;
import com.wxsdk.my.SDKController;
import com.xiaomi.gamecenter.sdk.MiCommplatform;
import com.xiaomi.gamecenter.sdk.OnInitProcessListener;
import com.xiaomi.gamecenter.sdk.entry.MiAppInfo;

import android.content.Context;
import android.os.Build;
import android.util.Log;

import java.util.List;

public class UnityApplication extends Application {
    public static MiAppInfo appInfo;
    public static boolean miSplashEnd = false;

    @Override
    protected void attachBaseContext(Context ctx) {
        super.attachBaseContext(ctx);
        try {
            JLibrary.InitEntry(ctx);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    @Override
    public void onCreate() {
        super.onCreate();

        /*UMConfigure.setLogEnabled(true);
        UMConfigure.init(this, "5b8d0566f29d98698d0000c8", "Umeng", UMConfigure.DEVICE_TYPE_PHONE,
                "d400aaf4eb88701fc988134d876fb861");
        PushAgent mPushAgent = PushAgent.getInstance(this);
        mPushAgent.register(new IUmengRegisterCallback() {
            @Override
            public void onSuccess(String s) {
                Log.i("my_token", s);
                SDKController.GetInstance().SavePushDeviceToken(s);
            }

            @Override
            public void onFailure(String s, String s1) {
                Log.i("register failed: ", s + " " + s1);
            }
        });*/

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            new MiitHelper().getDeviceIds(this, new MiitHelper.AppIdsUpdater() {
                @Override
                public void OnIdsAvailed(boolean isSupport, String oaid) {
                    Log.i("oaid", "new get:" + oaid);
                    SDKController.GetInstance().SaveOAID(oaid);
                }
            });
        }

        appInfo = new MiAppInfo();
        appInfo.setAppId("2882303761518631206");
        appInfo.setAppKey("5761863180206");
        MiCommplatform.Init(this, appInfo, new OnInitProcessListener() {
            @Override
            public void finishInitProcess(List<String> loginMethod, int gameConfig) {
                Log.i("Demo", "Init success");
            }

            @Override
            public void onMiSplashEnd() {//小米闪屏页结束回调，小米闪屏可配，无闪屏也会返回此回调，游戏的闪屏应当在收到此回调之后开始。
                miSplashEnd = true;//游戏自己的闪屏处理，可参考SplashActivity的实现
            }
        });
    }

    private boolean isMainProcess(){
        int pid = android.os.Process.myPid();
           ActivityManager activityManager = (ActivityManager)getSystemService(Context.ACTIVITY_SERVICE);
           for (ActivityManager.RunningAppProcessInfo appProcess : activityManager.getRunningAppProcesses()) {
               if (appProcess.pid == pid) {
                   return getApplicationInfo().packageName.equals(appProcess.processName);
               }
           }
           return false;
   }
}
