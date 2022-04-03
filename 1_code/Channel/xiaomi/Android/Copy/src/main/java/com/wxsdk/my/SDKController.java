package com.wxsdk.my;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;

import com.unity3d.player.UnityPlayer;
import com.changleyou.tthlby.mi.UnityPlayerActivity;
import com.xiaomi.gamecenter.sdk.GameInfoField;
import com.xiaomi.gamecenter.sdk.MiCommplatform;
import com.xiaomi.gamecenter.sdk.MiErrorCode;
import com.xiaomi.gamecenter.sdk.OnLoginProcessListener;
import com.xiaomi.gamecenter.sdk.OnPayProcessListener;
import com.xiaomi.gamecenter.sdk.OnRealNameVerifyProcessListener;
import com.xiaomi.gamecenter.sdk.RoleData;
import com.xiaomi.gamecenter.sdk.entry.MiAccountInfo;
import com.xiaomi.gamecenter.sdk.entry.MiBuyInfo;

import org.json.JSONObject;

import java.io.File;

/**
 * Created by Administrator on 2016/9/6 0006.
 */
public class SDKController {
    private static SDKController _instance;
    private  SDKController(){};

    private boolean m_isLogining = false;
    public boolean isLogining() { return m_isLogining; }
    public void markLogining(boolean value) { m_isLogining = value; }

	private boolean m_isRelogin = false;
    public boolean isRelogin() { return m_isRelogin; }
    public void markRelogin(boolean value) { m_isRelogin = value; }

    private UnityPlayerActivity mainActivity;
    public static SDKController GetInstance(){
        if(_instance == null)
        {
            _instance = new SDKController();
        }
        return _instance;
    }

    private MiitHelper miitHelper;

    private final String WXID = "wxf64ec3fb99c28771";
    public String getWXID() { return WXID; }
    //private IWXAPI api;
    public void RegisterWeChat(Context context) {
        //api = WXAPIFactory.createWXAPI(context, WXID);
       // boolean issuccess =  api.registerApp(WXID);
//        if (issuccess)
//            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] RegisterWeChat OK:" + WXID);
//        else
//            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] RegisterWeChat Fail:" + WXID);
    }

    public void HandleInit(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleInit exception:" + e.getMessage());
        }

        UnityPlayer.UnitySendMessage("SDK_callback", "InitResult", String.format("{result:%d}", result));
    }
    public void HandleLogin(String json_data) {
        int result = 0;
        try {
            // <新增接口>
            // 接口必须在用户选择同意隐私协议
            MiCommplatform.getInstance().onUserAgreed(mainActivity);
            // </新增接口>


            JSONObject jsonObject = new JSONObject(json_data);
            boolean needCertification = jsonObject.getBoolean("needCertification");

            markLogining(true);
            markRelogin(false);
            MiCommplatform.getInstance().miLogin(mainActivity,
                    new OnLoginProcessListener()
                    {
                        @Override
                        public void finishLoginProcess(int code , MiAccountInfo arg1)
                        {
                            HandleLoginResult(needCertification, code, arg1);
                        }
                    } );
          }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleLogin exception:" + e.getMessage());
        }

        if(result != 0)
            SimpleFeedback("LoginResult", result, -1);
    }
    public void HandleLoginOut(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleLoginOut exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "LoginOutResult", String.format("{result:%d}", result));
    }
	public void HandleRelogin(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);
            do {

                markLogining(true);
				markRelogin(true);

                UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] HandleRelogin send req");
            }while(false);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleRelogin exception:" + e.getMessage());
        }

        if(result != 0)
            UnityPlayer.UnitySendMessage("SDK_callback", "ReloginResult", String.format("{result:%d}", result));
    }
    public void HandlePay(String json_data) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(json_data);

            String orderId = jsonObject.getString("orderId");
            String userInfo = jsonObject.getString("userInfo");
            int amount = jsonObject.getInt("amount");

            String balance = jsonObject.getString("balance");
            String vip = jsonObject.getString("vip");
            String level = jsonObject.getString("level");
            String roleId = jsonObject.getString("roleId");
            String roleName = jsonObject.getString("roleName");
            String party = jsonObject.getString("party");
            String serverName = jsonObject.getString("serverName");

            MiBuyInfo miBuyInfo= new MiBuyInfo();
            miBuyInfo.setCpOrderId(orderId);//订单号唯一（不为空）
            miBuyInfo.setCpUserInfo(userInfo); //此参数在用户支付成功后会透传给CP的服务器
            miBuyInfo.setAmount(amount); //必须是大于1的整数，10代表10米币，即10元人民币（不为空）
            //用户信息，网游必须设置、单机游戏或应用可选

            Bundle mBundle = new Bundle();
            mBundle.putString( GameInfoField.GAME_USER_BALANCE, balance );   //用户余额
            mBundle.putString( GameInfoField.GAME_USER_GAMER_VIP, vip );  //vip等级
            mBundle.putString( GameInfoField.GAME_USER_LV, level );           //角色等级
            mBundle.putString( GameInfoField.GAME_USER_PARTY_NAME, party );  //工会，帮派
            mBundle.putString( GameInfoField.GAME_USER_ROLE_NAME, roleName ); //角色名称
            mBundle.putString( GameInfoField.GAME_USER_ROLEID, roleId );    //角色id
            mBundle.putString( GameInfoField.GAME_USER_SERVER_NAME, serverName );  //所在服务器
            miBuyInfo.setExtraInfo( mBundle ); //设置用户信息

            MiCommplatform.getInstance().miUniPay(mainActivity, miBuyInfo,
                    new OnPayProcessListener()
                    {
                        @Override
                        public void finishPayProcess( int code ) {
                            switch( code ) {
                                case MiErrorCode.MI_XIAOMI_PAYMENT_SUCCESS://购买成功
                                    SimpleFeedback("PayResult", 0, code);
                                    break;
                                case MiErrorCode.MI_XIAOMI_PAYMENT_ERROR_PAY_CANCEL://取消购买
                                    SimpleFeedback("PayResult", -5, code);
                                    break;
                                case MiErrorCode.MI_XIAOMI_PAYMENT_ERROR_PAY_FAILURE://购买失败
                                    SimpleFeedback("PayResult", -5, code);
                                    break;
                                case MiErrorCode.MI_XIAOMI_PAYMENT_ERROR_ACTION_EXECUTED://操作正在进行中
                                    SimpleFeedback("PayResult", -5, code);
                                    break;
                                default://购买失败
                                    break;
                            }
                        }
                    });

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandlePay exception:" + e.getMessage());
        }

        if(result != 0)
            SimpleFeedback("PayResult", -5, result);
    }
    public void HandleShare(String json_data) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(json_data);
            int shareType = jsonObject.getInt("type");
            switch (shareType) {
                case SDKController.Type.WeiChatInterfaceType_ShareUrl:
                    result = ShareLinkUrl(jsonObject);
                    break;
                case SDKController.Type.WeiChatInterfaceType_ShareImage:
                    result = ShareImage(jsonObject);
                    break;
                default:
                    result = -6;
                    break;
            }

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleShare exception:" + e.getMessage());
        }

        if(result != 0)
            UnityPlayer.UnitySendMessage("SDK_callback", "ShareResult", String.format("{result:%d}", result));
    }
    public void HandleShowAccountCenter(String json_data) {
        int result = 0;
        try {
            //JSONObject jsonObject = new JSONObject(json_data);

        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleShowAccountCenter exception:" + e.getMessage());
        }

        UnityPlayer.UnitySendMessage("SDK_callback", "ShowAccountCenterResult", String.format("{result:%d}", result));
    }

    public enum U2SDK_MSG {
        REGISTER_LOGIN,
        PAY_RESULT
    }
    public void HandleSendToSDKMessage(String json_data) {
        try {
            JSONObject jsonObject = new JSONObject(json_data);

            U2SDK_MSG msg = U2SDK_MSG.values()[jsonObject.getInt("msg")];
            switch(msg) {
                case REGISTER_LOGIN:
                    String level = jsonObject.getString("level");
                    String roleId = jsonObject.getString("roleId");
                    String roleName = jsonObject.getString("roleName");
                    String serverId = jsonObject.getString("serverId");
                    String serverName = jsonObject.getString("serverName");
                    String zoneId = jsonObject.getString("zoneId");
                    String zoneName = jsonObject.getString("zoneName");

                    RoleData data = new RoleData();
                    data.setLevel(level);
                    data.setRoleId(roleId);
                    data.setRoleName(roleName);
                    data.setServerId(serverId);
                    data.setServerName(serverName);
                    data.setZoneId(zoneId);
                    data.setZoneName(zoneName);
                    MiCommplatform.getInstance().submitRoleData(mainActivity, data);

                    break;
                case PAY_RESULT:
                    int payWay = jsonObject.getInt("payWay");
                    int payNum = jsonObject.getInt("payNum");

                    break;
                default:
                    break;
            }
        }catch(Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleSendToSDKMessage exception:" + e.getMessage() + " <--> " + json_data);
        }
    }

    public void HandleSetupAD(String json_data) {
        int result = 0;
        try {
            JSONObject jsonObject = new JSONObject(json_data);

            String appId = jsonObject.getString("appId");
            String appName = jsonObject.getString("appName");
            boolean isDebug = jsonObject.getBoolean("isDebug");

            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] HandleSetupAD setup ok:" + appId);
        }catch(Exception e) {
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleSetupAD exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "HandleSetupADResult", String.format("{result:%d}", result));
    }

    public void HandleScanFile(String filePath) {
        int result = 0;
        try{
            Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
            scanIntent.setData(Uri.fromFile(new File(filePath)));
        }catch (Exception e){
            result = -1;
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] HandleScanFile exception:" + e.getMessage());
        }
        UnityPlayer.UnitySendMessage("SDK_callback", "HandleScanFileResult", String.format("{result:%d}", result));
    }

    public void onAppCreate(Application application) {
    }
    public void onAppDestroy() {
    }
    public void onActivityCreate(UnityPlayerActivity activity) {
        mainActivity = activity;
        //RegisterWeChat(activity);
    }
    public void onActivityDestroy() {
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
    }

    public void onResume() {
        if(isLogining()) {
            markLogining(false);
            UnityPlayer.UnitySendMessage("SDK_callback", "LoginResult", String.format("{result:%d}", -4));
        }
    }

    public void onPause() {
    }

    public void onStart() {
    }
    public void onStop() {
    }

    public int ShareLinkUrl(JSONObject jsonObject) {
        try {
            String url = jsonObject.getString("url");
            String title = jsonObject.getString("title");
            String description = jsonObject.getString("description");
            String icon = jsonObject.getString("icon");
            boolean isCircleOfFriends = jsonObject.getBoolean("isCircleOfFriends");

//            WXWebpageObject webpage = new WXWebpageObject();
//            webpage.webpageUrl = url;
//            WXMediaMessage msg = new WXMediaMessage(webpage);
//            msg.title = title;
//            msg.description = description;
            Resources re = mainActivity.getResources();
            Bitmap bmp = null;
            if(!icon.isEmpty())
                bmp = BitmapFactory.decodeFile(icon);
            if(bmp == null) {
                bmp = BitmapFactory.decodeResource(re, re.getIdentifier("app_icon", "drawable", mainActivity.getPackageName()));
                UnityPlayer.UnitySendMessage("SDK_callback", "LogError", "[SDK] ShareLinkUrl Load icon Failed:" + icon);
            }
            if(bmp != null) {
                Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 100, 100, true);
                bmp.recycle();
               // msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
            }

//            SendMessageToWX.Req req = new SendMessageToWX.Req();
//            req.transaction = Transaction.ShareUrl;
//            req.message = msg;
//            req.scene = isCircleOfFriends ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
//            if(!api.sendReq(req))
//                return -3;
        }catch (Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] ShareLinkUrl exception:" + e.getMessage());
        }
        return 0;
    }

    public int ShareImage (JSONObject jsonObject) {
        try {
            String imgFile = jsonObject.getString("imgFile");
            boolean isCircleOfFriends = jsonObject.getBoolean("isCircleOfFriends");

            Resources re = mainActivity.getResources();
            Bitmap bmp = BitmapFactory.decodeFile(imgFile);
            if(bmp == null) {
                UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] ShareLinkUrl Load imgFile failed:" + imgFile);
                return -7;
            }

//            WXImageObject imgObj = new WXImageObject(bmp);
//            WXMediaMessage msg = new WXMediaMessage();
//            msg.mediaObject = imgObj;

            // 设置消息的缩略图
            Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, 100, 100, true);
            bmp.recycle();
//            msg.thumbData = Util.bmpToByteArray(thumbBmp, true);
//            SendMessageToWX.Req req = new SendMessageToWX.Req();
//            req.scene = isCircleOfFriends ? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
//            req.transaction = Transaction.ShareImage;
//            req.message = msg;
//            if(!api.sendReq(req))
//                return -3;

            UnityPlayer.UnitySendMessage("SDK_callback", "Log","[SDK] ShareImage Environment path:" + Environment.getExternalStorageDirectory().getAbsolutePath());
        }catch (Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] ShareImage exception:" + e.getMessage());
        }

        return 0;
    }

    public void SimpleFeedback(String callback, int result, int errno) {
        try {
            JSONObject jsonResult = new JSONObject();
            jsonResult.put("result", result);
            jsonResult.put("errno", errno);

            UnityPlayer.UnitySendMessage("SDK_callback", callback, jsonResult.toString());
        } catch (Exception e) {
            UnityPlayer.UnitySendMessage("SDK_callback", "LogError","[SDK] SimpleFeedback " + callback + " exception:" + e.getMessage());
        }
    }
    private void SendLoginResult(MiAccountInfo arg1, int isRealName) {
        //获取用户的登陆后的UID（即用户唯一标识）
        //String uid = arg1.getUid();
        //以下为获取session并校验流程，如果是网络游戏必须校验,(12小时过期)
        //获取用户的登陆的Session（请参考5.3.3流程校验Session有效性）
        //String session = arg1.getSessionId();
        //请开发者完成将uid和session提交给开发者自己服务器进行session验证

        try {
            JSONObject jsonResult = new JSONObject();
            jsonResult.put("result", 0);

            jsonResult.put("uid", arg1.getUid());
            jsonResult.put("session", arg1.getSessionId());
            jsonResult.put("isRealName", isRealName);

            UnityPlayer.UnitySendMessage("SDK_callback", "LoginResult", jsonResult.toString());
        } catch (Exception e) {
            SimpleFeedback("LoginResult", -1, -1);
        }
    }
    private void HandleRealName(MiAccountInfo arg1) {
        MiCommplatform.getInstance().realNameVerify(mainActivity, new OnRealNameVerifyProcessListener() {
            @Override
            public void onSuccess() {
                SendLoginResult(arg1, 1);
            }

            @Override
            public void closeProgress() {
                SimpleFeedback("LoginResult", -5, -10002);
            }

            @Override
            public void onFailure() {
                SimpleFeedback("LoginResult", -5, -10001);
            }
        });
    }
    private void HandleLoginResult(boolean needCertification, int code , MiAccountInfo arg1) {
        markLogining(false);

        switch( code )
        {
            case MiErrorCode.MI_XIAOMI_PAYMENT_SUCCESS:// 登陆成功
                if(needCertification) {
                    HandleRealName(arg1);
                } else {
                    SendLoginResult(arg1, 0);
                }
                break;
            case MiErrorCode.MI_XIAOMI_PAYMENT_ERROR_LOGIN_FAIL:
                // 登陆失败
                SimpleFeedback("LoginResult", -5, MiErrorCode.MI_XIAOMI_PAYMENT_ERROR_LOGIN_FAIL);
                break;
            case MiErrorCode.MI_XIAOMI_PAYMENT_ERROR_CANCEL:
                // 取消登录
                SimpleFeedback("LoginResult", -5, MiErrorCode.MI_XIAOMI_PAYMENT_ERROR_CANCEL);
                break;
            case MiErrorCode.MI_XIAOMI_PAYMENT_ERROR_ACTION_EXECUTED:
                //登录操作正在进行中
                SimpleFeedback("LoginResult", -5, MiErrorCode.MI_XIAOMI_PAYMENT_ERROR_ACTION_EXECUTED);
                break;
            default:
                // 登录失败
                break;
        }
    }

    private String m_pushDeviceToken = "";
    public void SavePushDeviceToken(String s) {
        m_pushDeviceToken = s;
    }
    public String GetPushDeviceToken() {
        return m_pushDeviceToken;
    }

    private String m_oaid = "";
    public void SaveOAID(String value) { m_oaid = value; }
    public String GetOAID() { return m_oaid; }

    public interface Type {
        int WeiChatInterfaceType_IsWeiChatInstalled = 1; //判断是否安装微信
        int WeiChatInterfaceType_RequestLogin = 2; //请求登录
        int WeiChatInterfaceType_ShareUrl = 3; //分享链接
        int WeiChatInterfaceType_ShareText = 4; //分享文本
        int WeiChatInterfaceType_ShareMusic = 5;//分享音乐
        int WeiChatInterfaceType_ShareVideo = 6;//分享视频
        int WeiChatInterfaceType_ShareImage = 7;//分享图片
    }

    public interface Transaction {
        String IsWeiChatInstalled = "isInstalled"; //判断是否安装微信
        String RequestLogin = "login"; //请求登录
        String ShareUrl = "shareUrl"; //分享链接
        String ShareText = "shareText"; //分享文本
        String ShareMusic = "shareMusic";//分享音乐
        String ShareVideo = "shareVideo";//分享视频
        String ShareImage = "shareImage";//分享图片
    }
}

