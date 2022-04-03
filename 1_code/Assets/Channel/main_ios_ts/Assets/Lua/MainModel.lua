local basefunc = require "Game.Common.basefunc"

MainModel = {}

local this

--当前位置 nil代表无位置 - 服务器标记所在的位置
local Location

--我所在的位置-客户端所在的位置
local myLocation

--我正在游戏中的位置
local GamingLocation

--在某个游戏大厅
local gameHallLocation

--是否开启公益位置
local isPublicWelfareLocation

--是否登录了
local IsLoged

local RoomCardInfo

--是否连接服务器
local IsConnectedServer

--网络延迟
local ping

--[[自动登录状态
    第一次到登录页面
    0-ok 要自动登录
    1-other 不要自动登录
]]
local AutoLoginState

--[[个人数据

    UserInfo = {
        name,           --玩家名字，在登录时随user_id一起接收
        user_id,        --玩家唯一标识符，服务器逻辑产生
        login_id,       --登录ID，玩家输入的帐号信息
        head_image,     --玩家头像链接，用于获取玩家微信头像

        diamond $ : integer  		#-- 钻石
        shop_ticket $ : integer 	#-- 抵用券
        cash $ : integer  			#-- 现金
        vip $ : integer  			#-- vip
        million_fuhuo_ticket $ : integer  #--复活卡
        match_ticket $ : integer 	#-- 比赛券
        hammer $ : integer  		#-- 锤子
        bomb $ : integer  			#-- 炸弹
        kiss $ : integer  			#-- 亲吻
        egg $ : integer  			#-- 鸡蛋
        brick $ : integer  			#-- 砖头
        praise $ : integer  		#-- 赞
        
        channel_type,   --渠道

    }

]]
local UserInfo


--[[登陆信息
    login_id
    channel_type
    device_id
    device_os
]]
local LoginInfo

--GPS
local CityName --城市
local Latitude --纬度
local Longitude--经度

---------------------------------------------------私有数据----------------------------------------------------------

--update handle
local UpdateTimer
local UPDATE_INTERVAL = 0.5

--心跳丢失数量
local HeartBeatLostNum = 0

--重连状态  0-无  1-重连中  2-重连后正在登录
local reConnectServerState = 0
--重连次数
local reConnectServerCount = 0


local RC_INTERVAL = 3
local reConnectDt = 0
local reConnectFailedCurTime = 0
local reConnectFailedTime = 6

local reLoginOverTimeCbk
local reLoginStartTime
local reLoginMaxTime = 5

--心跳
local HB_INTERVAL = 1
local heartbeatDt = 0
local sendClock = 0
local heartBeatLostCurTime = 0
local heartBeatLostMaxTime = 12


local serverSceneNameMap=
{
    -- 匹配场 游戏类型名称
    -- 注意不要和场景名称混淆
    ["freestyle_game_nor_ddz_nor"] = "game_DdzFree",
    ["freestyle_game_nor_ddz_lz"] = "game_DdzLaizi",
    ["freestyle_game_nor_ddz_er"] = "game_DdzFreeER",
    ["freestyle_game_nor_mj_xzdd"] = "game_Mj3D",
    ["freestyle_game_nor_mj_xzdd_er_7"] = "game_MjXzER3D",
    ["freestyle_game_nor_gobang_nor"] = "game_Gobang",
    ["freestyle_game_nor_ddz_boom"] = "game_DdzFreeBomb",
    ["freestyle_game_nor_pdk_nor"] = "game_DdzPDK",
    ["freestyle_game_nor_lhd_nor"] = "game_LHD",
    
    ["tyddz_freestyle_game"] = "game_DdzTy",    
    ["normal_mjxl_freestyle_game"] = "game_MjXl3D",

    --冠名赛
    ["naming_match_game_nor_ddz_nor"] = "game_DdzMatchNaming",

    ["normal_match_game_nor_ddz_nor"] = "game_DdzMatch",
    ["normal_match_game_ddz_nor_xsyd"] = "game_DdzMatch",
    ["normal_match_game_nor_mj_xzdd"] = "game_MjXzMatch3D",
    ["normal_match_game_nor_mj_xzdd_er_7"] = "game_MjXzMatchER3D",
    ["ddz_minilon_game"] = "game_DdzMillion",
    ["cityMatchGame"] = "game_CityMatch",
    ["normal_match_game_nor_ddz_er"] = "game_DdzMatchER",
    ["normal_match_game_nor_pdk_nor"] = "game_DdzPDKMatch",

    -- 房卡场
    ["friendgame_nor_mj_xzdd"] = "game_MjXzFK3D",
    ["friendgame_nor_ddz_nor"] = "game_DdzFK",
    ["friendgame_nor_ddz_lz"] = "game_DdzFK",

    ["fishing_game"] = "game_Fishing",
    ["fishing_match_game"] = "game_FishingMatch",
    ["fishing_3d_game"] = "game_Fishing3D",

    -- 本地虚拟的服务器位置
    ["freestyle_game_nor_ddz_nor_tf"] = "game_DdzFreeTF",
    --消消乐
    ["xiaoxiaole_game"] = "game_Eliminate",
    --水浒消消乐
    ["xiaoxiaole_shuihu_game"]="game_EliminateSH",
    --财神消消乐
    ["xiaoxiaole_caishen_game"]="game_EliminateCS",
    --抢红包
    ["qhb_game_nor_qhb_nor"] = "game_QHB",
    -- 弹弹乐
    ["tantanle_game"] = "game_TTL",
-- 自建房 斗地主
    ["zijianfang_nor_ddz_nor"] = "game_DdzZJF",
    ["zijianfang_nor_ddz_lz"] = "game_DdzLaiziZJF",
    ["zijianfang_nor_ddz_er"] = "game_DdzERZJF",
    ["zijianfang_nor_ddz_boom"] = "game_DdzBombZJF",
    ["zijianfang_nor_mj_xzdd_er_7"] = "game_Mj3dERZJF",
    ["zijianfang_nor_mj_xzdd"] = "game_Mj3dXZDDZJF",

    ["fishing_qys_match_game"] = "game_FishingMatchQYS",

}

-- 服务器上的游戏标记
MainModel.ServerToClientScene = 
{
    ["nor_ddz_nor"] = "game_DdzFree",
    ["nor_ddz_lz"] = "game_DdzLaizi",
    ["nor_ddz_er"] = "game_DdzFreeER",
    ["nor_mj_xzdd"] = "game_Mj3D",
    ["nor_mj_xzdd_er_7"] = "game_MjXzER3D",
    ["nor_gobang_nor"] = "game_Gobang",
    ["nor_ddz_boom"] = "game_DdzFreeBomb",
    ["xiaoxiaole_game"] = "game_Eliminate",
    ["xiaoxiaole_shuihu_game"]="game_EliminateSH",
    ["xiaoxiaole_caishen_game"]="game_EliminateCS",
    ["nor_pdk_nor"] = "game_DdzPDK",
    ["nor_pdk_match"] = "game_DdzPDKMatch",
    ["nor_lhd_nor"] = "game_LHD",
    ["nor_qhb_nor"] = "game_QHB",
    ["tantanle_game"] = "game_TTL",
    ["zijianfang_nor_ddz_nor"] = "game_DdzZJF",
    ["zijianfang_nor_ddz_lz"] = "game_DdzLaiziZJF",
    ["zijianfang_nor_ddz_er"] = "game_DdzERZJF",
    ["zijianfang_nor_ddz_boom"] = "game_DdzBombZJF",
    ["zijianfang_nor_mj_xzdd_er_7"] = "game_Mj3dERZJF",
    ["zijianfang_nor_mj_xzdd"] = "game_Mj3dXZDDZJF",
    ["fishing_qys_match_game"] = "game_FishingMatchQYS",
}
-- 客户端上的游戏标记
MainModel.ClientToServerScene = 
{
    ["game_DdzFree"] = "nor_ddz_nor",
    ["game_DdzLaizi"] = "nor_ddz_lz",
    ["game_DdzFreeER"] = "nor_ddz_er",
    ["game_Mj3D"] = "nor_mj_xzdd",
    ["game_MjXzER3D"] = "nor_mj_xzdd_er_7",
    ["game_DdzFreeTF"] = "nor_ddz_nor",
    ["game_Gobang"] = "nor_gobang_nor",
    ["game_DdzFreeBomb"] = "nor_ddz_boom",
    ["game_Eliminate"] = "xiaoxiaole_game",
    ["game_EliminateSH"]="xiaoxiaole_shuihu_game",
    ["game_EliminateCS"]="xiaoxiaole_caishen_game",
    ["game_DdzPDK"] = "nor_pdk_nor",
    ["game_DdzPDKMatch"] = "nor_pdk_match",
    ["game_LHD"] = "nor_lhd_nor",
    ["game_QHB"] = "nor_qhb_nor",
    ["game_TTL"] = "tantanle_game",
    ["game_DdzZJF"] = "zijianfang_nor_ddz_nor",
    ["game_DdzLaiziZJF"] = "zijianfang_nor_ddz_lz",
    ["game_DdzERZJF"] = "zijianfang_nor_ddz_er",
    ["game_DdzBombZJF"] = "zijianfang_nor_ddz_boom",
    ["game_Mj3dERZJF"] ="zijianfang_nor_mj_xzdd_er_7",
	["game_Mj3dXZDDZJF"] = "zijianfang_nor_mj_xzdd",
    ["game_FishingMatchQYS"] = "fishing_qys_match_game",
}
-- 服务器的位置，有可能需要调整，比如天府斗地主
local function getServerLocation(location, gameid)
    if location == "freestyle_game_nor_ddz_nor" and (gameid >= 21 and gameid <=24) then
        return "freestyle_game_nor_ddz_nor_tf"
    else
        return location
    end
end

function MainModel.GetServerToClientScene(parm)
    dump(parm, "<color=red>GetServerToClientScene</color>")
    if type(parm) == "table" then
        local gt
        if MainModel.ClientToServerScene[parm.game_type] then
            gt = parm.game_type
        else
            gt = MainModel.ServerToClientScene[parm.game_type]
        end

        if gt == "game_DdzFree" and (parm.game_id >= 21 and parm.game_id <=24) then
            return "game_DdzFreeTF"
        end
        return gt
    else
        return MainModel.ServerToClientScene[parm]
    end
end
---------------------------------------------------私有数据----------------------------------------------------------

function MainModel.getServerToClient(location)
    
    if location then
        return serverSceneNameMap[location]
    end

end




local lister
local function AddLister()
    lister={}
    lister["login_response"] = this.OnLogin
    lister["query_asset_response"] = this.on_query_asset
    lister["query_all_gift_bag_status_response"] = this.on_query_all_gift_bag_status
    lister["query_system_variant_data_response"] = this.query_system_variant_data

    lister["will_kick_reason"] = this.will_kick_reason
    lister["notify_asset_change_msg"] = this.OnNotifyAssetChangeMsg
    lister["ConnecteServerSucceed"] = this.OnConnecteServerSucceed
    lister["ServerConnectException"] = this.OnServerConnectException
    lister["ServerConnectDisconnect"] = this.OnServerConnectDisconnect
    lister["notify_pay_order_msg"] = this.OnNotifyPayOrderMsg
    lister["ping"] = this.OnPing
	lister["callup_service_center"] = this.OnCallupServiceCenter
    --百万大奖赛奖杯
    lister["notify_million_cup_msg"] = this.notify_million_cup_msg
    lister["confirm_million_cup_response"] = this.on_confirm_million_cup_response

    -- 礼包商品
    lister["query_gift_bag_num_response"] = this.on_query_gift_bag_num_response
    lister["goldpig2_task_remain_change_msg"] = this.on_goldpig2_task_remain_change_msg
    lister["gift_bag_status_change_msg"] = this.on_gift_bag_status_change_msg

    lister["plyj_finish_response"] = this.plyj_finish_response
    --vip下载ip列表
    lister["vip_addr_list"] = this.on_svr_vip_passage
    lister["OnLoginResponse"] = this.on_LoginResponse
    lister["ExitScene"] = this.OnExitScene
    lister["register_by_introducer_response"] = this.register_by_introducer_response
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

function MainModel.on_confirm_million_cup_response(_,data)
    Event.Brocast("main_model_confirm_million_cup_response",data.result)
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

function MainModel.Init ()

    this = MainModel
    -- 初始化加密字段
    PROTO_TOKEN = nil

    AddLister()

    -- 音效开关弃用 永远为true 改用SetLocalSoundOnOff GetLocalSoundOnOff
    -- soundMgr.IsSoundOn = true
    Screen.sleepTimeout = -1

    this.IsLoged = false
    this.IsConnectedServer = false
    this.AutoLoginState = 0

    local deivesInfo = Util.getDeviceInfo()
    this.LoginInfo = 
    {
        device_id = deivesInfo[0],
        device_os = deivesInfo[1],
    }
    if gameRuntimePlatform == "Android" or gameRuntimePlatform == "Ios" then
       this.LoginInfo.device_id = sdkMgr:GetDeviceID()
    end
    dump(this.LoginInfo.device_id, "[Debug] device_id: ")
    dump(gameMgr:getMarketChannel(), "[Debug] market_channel: ")
    dump(gameMgr:getMarketPlatform(), "[Debug] platform: ")

    UpdateTimer = Timer.New(this.Update, UPDATE_INTERVAL, -1, nil, true)
    UpdateTimer:Start()
    --ios订单处理
    IosPayManager.Init()
	--android订单处理
	AndroidPayManager.Init()

    gameWeb:CloseURL("_shop_")


    --[[if gameRuntimePlatform == "Ios" then
        local deviceMode = deivesInfo[2] or ""
        local systemVersion = deivesInfo[1] or ""
        print(string.format("[WEB]: %s, %s, %s", deivesInfo[0], systemVersion, deviceMode))
        local WEB_DEVICE_FILTERS = {
            "iPhone7,1", "iPhone7,2", "iPhone8,1"
        }
        local WEB_SYSTEM_FILTERS = {
		"9.1", "9.3"
        }
        local function adaptDevice(device)
	    for _, df in pairs(WEB_DEVICE_FILTERS) do
                if string.find(device, df) then
                    return true
                end
            end
            return false
        end
        local function adaptSystem(system)
            for _, sf in pairs(WEB_SYSTEM_FILTERS) do
                if string.find(system, sf) then
                    return true
                end
            end
            return false
        end

        if adaptDevice(deviceMode) and adaptSystem(systemVersion) then
            gameWeb:EnableWKWebView(false)
            print("[WEB] disable WK:" .. deviceMode .. ", " .. systemVersion)
        end
    elseif gameRuntimePlatform == "Android" then
    	local deviceMode = deivesInfo[2] or ""
        local systemVersion = deivesInfo[1] or ""
        print(string.format("[WEB]: %s, %s, %s", deivesInfo[0], systemVersion, deviceMode))
	local WEB_DEVICE_FILTERS = {
        }
        local WEB_SYSTEM_FILTERS = {
		"5.1"
        }
        local function adaptDevice(device)
	    for _, df in pairs(WEB_DEVICE_FILTERS) do
                if string.find(device, df) then
                    return true
                end
            end
            return true
        end
        local function adaptSystem(system)
            for _, sf in pairs(WEB_SYSTEM_FILTERS) do
                if string.find(system, sf) then
                    return true
                end
            end
            return false
        end

        if adaptDevice(deviceMode) and adaptSystem(systemVersion) then
            gameWeb:EnableWKWebView(false)
            print("[WEB] disable WK:" .. deviceMode .. ", " .. systemVersion)
        end
    end]]--

    return this
end


-- 检查是否要自动登录
function MainModel.GetIsAutoLogin()
    if this.AutoLoginState== 0 then
    	if LoginModel.loginData.lastLoginChannel and LoginModel.loginData.lastLoginChannel ~= "youke" then
		return true
	end
    end
    return false
end


--[[登录返回的消息
    result $ : integer # 0 succed ,or error id 
    user_id $ : string # 登录成功返回用户 id （系统唯一 id）
    login_id $ : string # 登录id 快速登录使用 客户端应当保存
    name $ : string     # 玩家名字
    head_image $ : string # 玩家头像连接 可能为空串
    match_ticket $ : integer    #-- 比赛券
    shop_gold $ : integer   #-- 
    room_card $ : integer   #-- 房卡
    cash $ : integer    #-- 现金
    sex $ : integer     # 性别 1男 0女 或者 nil
    introducer $ : string # 简介
    location $ : string #当前玩家所在位置
]]

function MainModel.OnLogin (_,data )
    dump(data, "<color=red>登录数据</color>")

    if data.result == 0 then
        heartBeatLostCurTime = 0
        local instance_id = this.instance_id or 0
	   if instance_id ~= 0 and instance_id ~= data.instance_id then
    		HintPanel.Create(1, "更新完毕，请重启游戏", function ()
    			--UnityEngine.Application.Quit()
			gameMgr:QuitAll()
    		end)
		return
	end
    this.instance_id = data.instance_id
    
    this.UserInfo = data
    this.UserInfo.shop_gold_sum = 0
    this.UserInfo.jing_bi = 0
    this.UserInfo.player_asset = nil
    this.UserInfo.GiftShopStatus = {}

    this.RecentlyOpenBagTime = "RecentlyOpenBagTime" .. this.UserInfo.user_id
    this.RecentlyGetNewItemTime = "RecentlyGetNewItemTime" .. this.UserInfo.user_id
    this.RecentlyOpenBagTimeFishing = "RecentlyOpenBagTimeFishing" .. this.UserInfo.user_id
    this.RecentlyGetNewItemTimeFishing = "RecentlyGetNewItemTimeFishing" .. this.UserInfo.user_id
    this.FreeRapidBeginKey = "FreeRapidBeginKey" .. this.UserInfo.user_id

    this.LocalSoundOnOffKey = "LocalSoundOnOffKey" .. this.UserInfo.user_id
    this.CreateRoomCardParm = "CreateRoomCardParm" .. this.UserInfo.user_id
    this.FreeDHRedHintKey = "FreeDHRedHintKey" .. this.UserInfo.user_id
    MainModel.SetBindPhone(this.UserInfo.bind_phone)--电话号码绑定
    this.IsLoged = true
    this.LoginInfo.login_id=data.login_id
    this.LoginInfo.channel_type=data.channel_type
    this.LoginInfo.is_test = data.is_test
    if data.refresh_token then
    	this.LoginInfo.channel_args = "{\"refresh_token\":\""..data.refresh_token.."\"}"
    end
    local channelTbl = LoginModel.GetChannelLuaTable(data.channel_type)
    if channelTbl then
    	this.LoginInfo.openid = channelTbl.openid
    end

    this.Location = getServerLocation(data.location, data.game_id)
    this.game_id = data.game_id
    
    if not this.UserInfo.name then
        this.UserInfo.name = ""
    end
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Money)

	local player_level = this.UserInfo.player_level or 0
	if player_level > 0 then
		gestureMgr:TryAddGesture("GestureCircle")
	end
    else
        this.IsLoged = false
    end

    reLoginOverTimeCbk = nil

    --重连登录完成
    if reConnectServerState == 2 then

        --重置各种网络相关状态
        reConnectFailedCurTime = 0
        reConnectDt = 0
        reConnectServerState = 0
        reConnectServerCount = 0

        heartbeatDt = 0

        sendClock = 0
        heartBeatLostCurTime = 0

        print("<color=blue> ReConnecte Succeed </color>")

        FullSceneJH.RemoveAll()
        --重连后登录完成
        if data.result == 0 then
            this.UserInfo.ToolMap = {}
            this.query_asset_index = 1

            this.UserInfo.is_login = 1
            this.login_query_map = {query_asset = 1, query_all_gift_bag_status = 1,query_system_variant_data=1}
            if this.is_on_query_asset then
                this.reset_query_asset = true
            else
                this.is_on_query_asset = true
                Network.SendRequest("query_asset", {index = this.query_asset_index})
            end
            Network.SendRequest("query_all_gift_bag_status", nil)
            Network.SendRequest("query_system_variant_data")
            FullSceneJH.Create("正在登陆", "login")
        else
            Event.Brocast("ReConnecteServerResponse",data.result)
        end
    else
        FullSceneJH.RemoveAll()
        --正常的登陆完成
        if data.result == 0 then
            this.UserInfo.ToolMap = {}
            this.query_asset_index = 1

            this.UserInfo.is_login = 2
            this.login_query_map = {query_asset = 1, query_all_gift_bag_status = 1,query_system_variant_data=1}
            if this.is_on_query_asset then
                this.reset_query_asset = true
            else
                this.is_on_query_asset = true
                Network.SendRequest("query_asset", {index = this.query_asset_index})
            end
            Network.SendRequest("query_all_gift_bag_status", nil)
            Network.SendRequest("query_system_variant_data")
            FullSceneJH.Create("正在登陆", "login")
            LoginLogic.SetGoodIP(AppConst.SocketAddress)
        else
            Event.Brocast("Ext_OnLoginResponse", data.result)
        end
    end
end

function MainModel.on_query_asset(_, data)
    dump(data, "<color=red>on_query_asset</color>")
    if not table_is_null(data.player_asset) then
        for k,v in ipairs(data.player_asset) do
            if not v.attribute or v.asset_type == "jipaiqi" then
                if v.asset_type == "jipaiqi" then
                    this.UserInfo[v.asset_type] = tonumber(v.attribute[1].value)
                else
                    this.UserInfo[v.asset_type] = tonumber(v.asset_value)
                end
            else
                local vv = {}
                this.UserInfo.ToolMap[v.asset_value] = vv
                vv.id = v.asset_value
                vv.asset_type = v.asset_type
                for k1,v1 in pairs(v.attribute) do
                    if tonumber(v1.value) then
                        vv[v1.name] = tonumber(v1.value)
                    else
                        vv[v1.name] = v1.value
                    end
                end
            end
        end
    end

    if this.reset_query_asset then
        this.UserInfo.ToolMap = {}
        this.query_asset_index = 1
        this.reset_query_asset = false

        Network.SendRequest("query_asset", {index = this.query_asset_index})
        return
    end

    MainModel.check_asset_change_no(data.no)

    if not data.player_asset or (#data.player_asset < 100 and #data.player_asset >= 0) then
        this.is_on_query_asset = false
        Event.Brocast("AssetChange", {data={}})
        MainModel.finish_login_query("query_asset")
    else
        this.query_asset_index = this.query_asset_index + 1
        Network.SendRequest("query_asset", {index = this.query_asset_index})
    end
end
function MainModel.on_query_all_gift_bag_status(_,data)
    dump(data, "<color=red>on_query_all_gift_bag_status</color>")
    for k,v in ipairs(data.gift_bag_data) do
        this.UserInfo.GiftShopStatus[v.gift_bag_id]={}
        this.UserInfo.GiftShopStatus[v.gift_bag_id].status = v.status
    end
    MainModel.finish_login_query("query_all_gift_bag_status")
end
function MainModel.query_system_variant_data(_,data)
    MainModel.finish_login_query("query_system_variant_data")
    Event.Brocast("model_query_system_variant_data", "query_system_variant_data", data)
end
function MainModel.finish_login_query(key)
    this.login_query_map[key] = nil

    if not this.login_query_map or not next(this.login_query_map) then
        MainModel.finish_login_flow()
    end
end
-- 完成登录流程
function MainModel.finish_login_flow()
    FullSceneJH.RemoveByTag("login")

    if this.UserInfo.is_login then
        if this.UserInfo.is_login == 1 then
            Event.Brocast("ReConnecteServerResponse", 0)
        elseif this.UserInfo.is_login == 2 then
            Event.Brocast("Ext_OnLoginResponse", 0)
        end
    end

    this.UserInfo.is_login = 0    
    Event.Brocast("main_model_query_all_gift_bag_status")    
end

------------------------ping------------------
function MainModel.OnPing(ping)
    LuaHelper.OnPing(ping)
end

function MainModel.OnCallupServiceCenter(phoneNumber)
	print("OnCallupServiceCenter:" .. phoneNumber)
	if gameMgr:getMarketChannel() == "hw_wqp" then
		UniClipboard.SetText(phoneNumber)
		LittleTips.Create("已复制客服电话:" .. phoneNumber)
	else
		sdkMgr:CallUp(phoneNumber)
	end
end

-----------------------------------------被踢下线-------------------------------------------
function MainModel.will_kick_reason(proto_name,data)

    if data.reason == "logout" then
        --由于后台很久了，服务器已经把代理杀了 将会自动重连登陆
        print("<color=red> server wait over time  </color>")

    elseif data.reason == "relogin" then
        MainModel.IsLoged = false
        --有人用我的login_id在其他地方登陆
        print("<color=red> other is logining </color>")

        HintPanel.Create(1,"您的账号已经在其他设备登陆",function ()
            local ct = MainModel.LoginInfo.channel_type
            LoginModel.ClearChannelData(ct)
            LoginModel.ClearLastLoginData()

            MainLogic.Exit()
            networkMgr:Init()
            Network.Start()
            MainLogic.Init()
            
        end)

    else

        print("<color=red> error </color>")
        dump(data,proto_name)

    end

end

-----------------------------------------百万大奖赛奖杯------------------
function MainModel.notify_million_cup_msg (proto_name,data)
    this.UserInfo.million_cup_status = data.million_cup_status
    if this.UserInfo.million_cup_status then
        Event.Brocast("on_notify_million_cup_msg")
    end
end
-----------------------------------------资产改变-------------------------------------------
-----------------------------------------资产改变-------------------------------------------
function MainModel.IsShowAward(a_type)
    if not a_type then
        return
    end
    if TIPS_ASSET_CHANGE_TYPE[a_type] then
        return true
    end
    if string.sub(a_type, 1, 5) == "task_" then
        return true
    end
    if string.sub(a_type, 1, 13) == "buy_gift_bag_" then
        return true
    end
    if string.sub(a_type, 1, 9) == "everyday_" then
        return true
    end
    return false
end

function MainModel.OnNotifyAssetChangeMsg(proto_name,data)
    dump(data, "<color=white>资产改变改变</color>")

    this.UserInfo = this.UserInfo or {}
    this.UserInfo.ToolMap = this.UserInfo.ToolMap or {}

    --改变的资产处理
    local change_assets = {}
    --改变的资产 获得的
    local change_assets_get = {}
    if data.change_asset then
        local item
        for k,v in pairs(data.change_asset) do
            if v.asset_type == "jing_bi" and tonumber(v.asset_value) < 0 then
                DSM.Consume(data)
            end
        
            local is_add_bag = false
            if basefunc.is_object_asset(v.asset_type) then
                if not v.attribute then
                    this.UserInfo.ToolMap[v.asset_value] = nil
                else
                    local vv = {}
                    this.UserInfo.ToolMap[v.asset_value] = vv
                    vv.id = v.asset_value
                    vv.asset_type = v.asset_type
                    for k1,v1 in ipairs(v.attribute) do
                        if tonumber(v1.value) then
                            vv[v1.name] = tonumber(v1.value)
                        else
                            vv[v1.name] = v1.value
                        end
                    end
                    change_assets[#change_assets + 1] = {asset_type = v.asset_type, value = 1}
                    change_assets_get[#change_assets_get + 1] = {asset_type = v.asset_type, value = 1}
                    is_add_bag = true
                end
            else
                if tonumber(v.asset_value) then
                    if v.asset_type == "jipaiqi" then -- 记牌器特殊逻辑
                        local num = tonumber(v.asset_value)
                        if not this.UserInfo[v.asset_type] then
                            this.UserInfo[v.asset_type] = os.time()
                        end
                        this.UserInfo[v.asset_type] = this.UserInfo[v.asset_type] + num * 86400

                        change_assets[#change_assets + 1] = {asset_type = v.asset_type, value = num}
                        if num > 0 then
                            change_assets_get[#change_assets_get + 1] = {asset_type = v.asset_type, value = num}
                            is_add_bag = true
                        end                        
                    else
                        local num = tonumber(v.asset_value)
                        if not this.UserInfo[v.asset_type] then
                            this.UserInfo[v.asset_type] = 0
                        end
                        this.UserInfo[v.asset_type] = this.UserInfo[v.asset_type] + num

                        change_assets[#change_assets + 1] = {asset_type = v.asset_type, value = num}
                        if num > 0 then
                            change_assets_get[#change_assets_get + 1] = {asset_type = v.asset_type, value = num}
                            is_add_bag = true
                        end
                    end
                else
                    dump(v, "<color=red>非限时道具asset_value不能转成number</color>")
                end 
            end

            if is_add_bag and _G["GameItemModel"] then
                MainModel.SetNewItemTime(v.asset_type)
                item = GameItemModel.GetItemToKey(v.asset_type)
                if item and item.is_show_bag and item.is_show_bag == 1 then
                    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Bag)
                end
                if v.asset_type == "cash" then
                    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Money)
                end
            end
        end
    end

    if data.type == "pay_exchange_expression_57" then
        local _zt = MainModel.GetShopingConfig(GOODS_TYPE.item,1,"expression_57")
        local zt = {}
        zt.asset_type = _zt.type
        zt.value = _zt.num
        table.insert( change_assets_get, zt)
    end

    Event.Brocast("AssetChange", {data = change_assets_get, change_type = data.type})
    if MainModel.IsShowAward(data.type) and #change_assets_get > 0 then
        Event.Brocast("AssetGet",{data = change_assets_get, change_type = data.type})
    end

    if data.type == "buy_gift_bag_30" then
        MainModel.SetItemStatus(32, 1)
    elseif data.type == "buy_gift_bag_32" then
        MainModel.SetItemStatus(32, 0)
        MainModel.SetItemStatus(33, 1)
    elseif data.type == "fishing_task_chou_jiang" then
        Event.Brocast("asset_get_fishing_task_chou_jiang",{data = change_assets_get, change_type = data.type})
    elseif data.type == "buyu_spend_lottery_task_award" then
        Event.Brocast("buyu_spend_lottery_task_award",{data = change_assets_get, change_type = data.type})
    elseif data.type == "shoping" then
    	local plyj_status = MainModel.UserInfo.plyj_status or 0
    	if plyj_status == 0 and gameRuntimePlatform == "Ios" then
            -- ProductRatingPanel.Create() --屏蔽苹果评论
    	end
    end

    MainModel.check_asset_change_no(data.no)
end
function MainModel.check_asset_change_no(no)
    if no and this.UserInfo.asset_change_no then
        local no = this.UserInfo.asset_change_no + 1
        if no > 65000 then
            no = 1
        end
        if no ~= no then
            this.UserInfo.asset_change_no = nil
            if this.is_on_query_asset then
                this.reset_query_asset = true
            else
                this.is_on_query_asset = true
                this.UserInfo.ToolMap = {}
                this.query_asset_index = 1

                Network.SendRequest("query_asset", {index = this.query_asset_index}, "请求背包数据")
            end
        end
    end
    this.UserInfo.asset_change_no = no
end

function MainModel.GetHBValue()
    if MainModel.UserInfo.shop_gold_sum then
        return MainModel.UserInfo.shop_gold_sum
    else
        return 0
    end
end

-- 获取区域
function MainModel.GetAreaID()
    MainModel.UserInfo.AreaID = 1-- 成都
    return MainModel.UserInfo.AreaID
end
-- 设置区域
function MainModel.SetAreaID(area)
    MainModel.UserInfo.AreaID = area
    Event.Brocast("update_player_area_id")
end

-- 返回收货地址
function MainModel.GetAddress()
    if MainModel.UserInfo.shipping_address and MainModel.UserInfo.shipping_address.address then
        return StringHelper.Split(MainModel.UserInfo.shipping_address.address, "#")
    end
end

-- 返回收货地址
function MainModel.CacheShop()
    local pp = GameObject.Find("WebView__shop_")
    if IsEquals(pp) then
        return
    end
    local shop_url
    Network.SendRequest(
        "create_shoping_token",
        {geturl = shop_url and "n" or "y"},
        function(_data)
            if _data.result == 0 then
                shop_url = _data.url or shop_url

                local url = string.gsub(shop_url, "@token@", _data.token)
                print("gameWeb:OnShopClick() : ", url)
                gameWeb:OnShopClick(url, true)

                local webObj = GameObject.Find("WebView__shop_")
                if IsEquals(webObj) then
                    print("<color=red>EEEEEEEEEEEEEEEEEEEEE</color>")
                    dump(webObj)
                    GameObject.DontDestroyOnLoad(webObj)
                end
            else
                print("<color=red>result = " .. _data.result .. "</color>")
            end
        end
    )
end
-- 是否需要绑定
function MainModel.IsNeedBindPhone()
    local is_not_bind = (not MainModel.UserInfo.phoneData) or (not MainModel.UserInfo.phoneData.phone_no)
    return is_not_bind
end
function MainModel.OpenDH(parm)
	if true then
		GameManager.GotoUI({gotoui = "shop_bay",goto_scene_parm = "item"})
		return
	end
    if GameGlobalOnOff.InternalTest then
        HintPanel.Create(1, "测试期间，暂不开放")
        return
    end

    local can_do = false
    local is_not_bind= (not MainModel.UserInfo.phoneData) or (not MainModel.UserInfo.phoneData.phone_no)
    if MainModel.GetHBValue() >= 1 then 
		if GameGlobalOnOff.BindingPhone and is_not_bind then
			local b = HintPanel.Create(1,"为了您的账号安全,请进行手机绑定，绑定后可进行商城兑换",function ()
				AwardBindingPhonePanel.Create()
			end)
			b:SetButtonText(nil,"前往绑定")
		else
			can_do = true
		end 
	else
        can_do = true
    end
    if  can_do then
        Network.SendRequest("create_shoping_token", {geturl=shop_url and "n" or "y"},function(_data)
            if _data.result == 0 then
                if MainModel.GetHBValue() >= 10 then
                    PlayerPrefs.SetString("HallDHHintTime" .. MainModel.UserInfo.user_id, os.time())
                end
                shop_url = _data.url or shop_url

                local url = string.gsub(shop_url,"@token@",_data.token)
                if parm then
                    url = url .. parm
                end
                dump(url, "<color=white> <<<<<<<< OpenDH >>>>>>>> </color>")
                if parm then
                    gameWeb:OnShopClickLoadURL(url)
                else
                    gameWeb:OnShopClickLoadURL(url)
                end
            end
        end )
    end
end
-- 客服反馈
function MainModel.OpenKFFK()
    local url = string.format("http://kfapp.game3396.com/jyhd/hlby/#/userfeedback?playerid=%s", MainModel.UserInfo.user_id)
    if MainModel.GetServerName() == SERVER_TYPE.CS then
        url = string.format("http://testkfapp.game3396.com/jyhd/hlby/#/userfeedback?playerid=%s", MainModel.UserInfo.user_id)
    end
    dump(url, "<color=red>客服反馈URL</color>")
    gameWeb:OnShopClickLoadURL(url)
end

function MainModel.GetShopingConfigTge(_type)
    if not _type then
        return shoping_config.tge
    end

    if shoping_config.tge then
        for k,v in pairs(shoping_config.tge) do
            if _type == v.type then
                return v
            end
        end
    end

    return nil
end

function MainModel.GetShopingConfig(_type, id, _item_type)
    if not _type then
        return shoping_config
    elseif not id then
        if shoping_config then
            return shoping_config[_type]
        end
    end

    if shoping_config and shoping_config[_type] then
        for i,v in ipairs(shoping_config[_type]) do
            if _type ~= GOODS_TYPE.item then
                if id == v.id then
                    return v
                end
            else
                if id == v.id and _item_type == v.type then
                    return v
                end
            end
        end
    end
    return nil
end

-- 查询礼包商品显示与否
function MainModel.GetGiftShopShowByID(id)
    if not id then
        return false
    end
    -- 不存在 或者存在但是on_off=0
    local config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
    if not config or config.on_off == 0 then
        return false
    end
    if not MainModel.UserInfo or not MainModel.UserInfo.GiftShopStatus then return false end
    local status
    if not MainModel.UserInfo.GiftShopStatus[id] then
        status = 0
    else
        status = MainModel.UserInfo.GiftShopStatus[id].status
    end
    local b1 = MathExtend.isTimeValidity(config.start_time, config.end_time)
    if b1 then
        if config.buy_limt == 0 then
            if status == 0 then
                return false
            else
                return true
            end
        elseif config.buy_limt == 1 then
            return true
        else
            return true
        end
    else
        return false
    end
end

-- 查询礼包商品状态
function MainModel.GetGiftShopStatusByID(id)
    if not id then
        return 0
    end
    -- 不存在 或者存在但是on_off=0
    if not MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id) or MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id).on_off == 0 then
        return 0
    end
    if not MainModel.UserInfo or not MainModel.UserInfo.GiftShopStatus or not MainModel.UserInfo.GiftShopStatus[id] then
        return 0
    else
        return MainModel.UserInfo.GiftShopStatus[id].status
    end
end

function MainModel.FinishGiftShopByID(id)
    if not MainModel.UserInfo.GiftShopStatus[id] then
        MainModel.UserInfo.GiftShopStatus[id] = {}
    end
    MainModel.UserInfo.GiftShopStatus[id].status = 0
    Event.Brocast("finish_gift_shop_shopid_"..id)
    Event.Brocast("finish_gift_shop", id)
    -- Network.SendRequest("query_all_gift_bag_status", nil, "请求礼包数据")
end

-- 查询礼包商品数量
function MainModel.GetGiftShopNumByID(id)
    if not MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id) then
        if not MainModel.UserInfo.GiftShopStatus[id] then
            MainModel.UserInfo.GiftShopStatus[id] = {}
        end
        MainModel.UserInfo.GiftShopStatus[id].count = 0
        Event.Brocast("model_query_gift_bag_num_shopid_"..id, {shopid=id, count=0})        
    end

    Network.SendRequest("query_gift_bag_num", {gift_bag_id=id})
end

function MainModel.on_query_gift_bag_num_response(_,data)
    dump(data, "<color=red>on_query_gift_bag_num_response</color>")
    if data.result==1008 then 
        print("<color=red> 获取礼包数量返回码 1008<color>")
            return 
    end 
    if not data.result or data.result ~= 0 then
        return
    end
    if not MainModel.UserInfo.GiftShopStatus[data.gift_bag_id] then
        MainModel.UserInfo.GiftShopStatus[data.gift_bag_id] = {}
    end
    MainModel.UserInfo.GiftShopStatus[data.gift_bag_id].count = data.num
    Event.Brocast("model_query_gift_bag_num_shopid_"..data.gift_bag_id, {shopid=data.gift_bag_id, count=data.num})    
end

--查询常规礼包状态 v.Lua：礼包对应的脚本,里面必须实现Create方法
function MainModel.GetConventionalGift()
    local gift_cfg = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag)
    local cg_gift = {}
    for k,v in pairs(gift_cfg) do
        if v.on_off and v.on_off == 1 and v.is_cg and v.is_cg == 1 and v.start_time and os.time() >= v.start_time and v.end_time and os.time() <= v.end_time then
            table.insert( cg_gift,v)
        end
    end
    if table_is_null(cg_gift) then
        return
    end
    table.sort(
        cg_gift,
        function(a, b)
            if a.cg_order == b.cg_order then
                return a.id < b.id
            else
                return a.cg_order < b.cg_order
            end
        end
    )
    local gift_data = {}
    for i,v in ipairs(cg_gift) do
        local state = MainModel.GetGiftShopStatusByID(v.id)
        if state then
            table.insert(gift_data,{state = state,config = v})
        end
    end
    return gift_data
end

-----------------------------------------资产改变-------------------------------------------
-----------------------------------------资产改变-------------------------------------------


-----------------------------------------支付-------------------------------------------
-----------------------------------------支付-------------------------------------------
function MainModel.OnNotifyPayOrderMsg(proto_name,msg)
    Event.Brocast("ReceivePayOrderMsg",msg)
    if msg.result == 0 then
        MainModel.FinishGiftShopByID(msg.goods_id)
    end
end
-----------------------------------------支付-------------------------------------------
-----------------------------------------支付-------------------------------------------


-----------------------------------------重连-------------------------------------------
-----------------------------------------重连-------------------------------------------

--重连服务器
local function reConnectServer()
    
    if not this.IsConnectedServer and reConnectServerState==0 then

        reConnectServerState = 1

        print("<color=red>重连 MainModel</color>")
        --立刻发起第一次重连
        networkMgr:SendConnect()
        reConnectServerCount = reConnectServerCount + 1

    end

end

--持续进行发送重连请求
local function sendReConnectRequest(dt)

    if reConnectServerState == 1 then

        --进行重连失败处理
        if reConnectFailedCurTime >= reConnectFailedTime then
            reConnectFailedCurTime = 0
            reConnectDt = 0
            reConnectServerState = 0
            reConnectServerCount = 0
            this.IsLoged = false
            this.IsConnectedServer = false
            
            FullSceneJH.RemoveByTag(1011)

            --重连后失败，应该跳转到登陆场景
            HintPanel.Create(1,"您连接服务器失败，需要重新登录",function ()
                MainLogic.GotoScene( "game_Login" )
            end)
            print("<color=red> reConnectFailed </color>")
        end

        reConnectDt = reConnectDt + dt
        if reConnectDt > RC_INTERVAL then
            reConnectDt = 0
            reConnectFailedCurTime = reConnectFailedCurTime + 1

            if not this.IsConnectedServer then
                networkMgr:SendConnect()
                reConnectServerCount = reConnectServerCount + 1
                print("<color=red> SendConnect ***----- </color>")
            end

        end

    end

end


--服务器连接异常
function MainModel.OnServerConnectException ()

    --只有登录之后才管这些事情
    if this.IsLoged then

        FullSceneJH.Create("正在重连服务器...",1011)

        Event.Brocast("DisconnectServerConnect")

        reConnectServer()

        print("<color=red> OnServerConnectException ***----- </color>")
    end

end

--服务器连接断开
function MainModel.OnServerConnectDisconnect ()

    --只有登录之后才管这些事情
    if this.IsLoged then

        FullSceneJH.Create("正在重连服务器...",1011)

        Event.Brocast("DisconnectServerConnect")
        
        reConnectServer()

        print("<color=red> OnServerConnectDisconnect ***----- </color>")
    end

end


--服务器重连成功
function MainModel.OnConnecteServerSucceed ()

    --判断是否是重连的链接成功
    if reConnectServerState == 1 then

        this.is_on_query_asset = false
        reConnectServerState = 2 -- 重连成功 开始进行登录
        reConnectServerCount = 0
        reConnectDt = 0
    
    PROTO_TOKEN = nil
        MainLogic.reLogin()

        --添加一个超时回调
        reLoginStartTime = os.time()
        reLoginOverTimeCbk = function ()
            -- 直接回复登录错误
            Event.Brocast("login_response","login_response",{result=-1})
        end

        print("<color=blue> ReConnecteServerSucceed  start login ***----- </color>")

    end

end


-----------------------------------------重连-------------------------------------------
-----------------------------------------重连-------------------------------------------






-----------------------------------------心跳-------------------------------------------
-----------------------------------------心跳-------------------------------------------


local function heartbeat(dt)

    --正常的链接状态才进行心跳
    if reConnectServerState ~= 0 then
        return
    end

    --上一个发送成功后并且间隔1s以上才发送新的心跳包

    heartbeatDt = heartbeatDt + dt
    heartBeatLostCurTime = heartBeatLostCurTime + dt
    if heartbeatDt > HB_INTERVAL then
        Network.SendRequest("heartbeat",nil,function ()
            HeartBeatLostNum = HeartBeatLostNum - 1
            this.ping = math.ceil((os.clock()-sendClock)*500)
            Event.Brocast("ping",this.ping)
            heartBeatLostCurTime = 0
            -- print("<color=red>ping:"..this.ping.."</color>")
        end)
        HeartBeatLostNum = HeartBeatLostNum + 1
        
        heartbeatDt = 0
        sendClock = os.clock()
    end

    if heartBeatLostCurTime > heartBeatLostMaxTime then
        --丢失过多  触发网络异常
        print("<color=red> heartBeatLostMaxTime to ServerConnectException </color>")
        heartbeatDt = 0
        sendClock = 0
        heartBeatLostCurTime = 0

        Network.DestroyConnect()
    end

end



-----------------------------------------心跳-------------------------------------------
-----------------------------------------心跳-------------------------------------------




-----------------------------------------前后台-------------------------------------------
-----------------------------------------前后台-------------------------------------------

function MainModel.OnForeGround ()
    -- print("MainModel.OnForeGround*********---------------")
    Event.Brocast("EnterForeGround")

    --重置心跳 数据
    heartbeatDt = 0
    sendClock = 0
    HeartBeatLostNum = 0
    heartBeatLostCurTime = 0

    --
    print("------------------------deeplink OnForeGround------------------------")
    local deeplink = sdkMgr:GetDeeplink()
    if not deeplink or deeplink == "" then
        print("<color=red>deeplink is null</color>")
    else
        print("<color=red>deeplink = " .. deeplink .. "</color>")
	    MainLogic.HandleOpenURL(deeplink)
    end
end


function MainModel.OnBackGround ()
    -- print("MainModel.OnBackGround*********---------------")
    Event.Brocast("EnterBackGround")

end


-----------------------------------------前后台-------------------------------------------
-----------------------------------------前后台-------------------------------------------

function MainModel.WeChat(shareLink, call)
    if gameRuntimePlatform == "Ios" or gameRuntimePlatform == "Android" then
        sdkMgr:WeChat(shareLink, function (str)
            if call then
                call(str)
            end
        end)
    else
        if call then
            call("OK")
        end
    end
end

function MainModel.GetShareUrl(call,parm)
    if false and MainModel.UserInfo.shareURL then
        if call then
            call(MainModel.UserInfo.shareURL)
        end
    else
        local _parm = nil
        if parm and next(parm) then
            --category：1 默认 2 新人组队挑战活动 3月16日
            _parm = {share_source = parm.share_type,category = parm.category or 1}
        end
        dump(_parm,"<color=red>---分享数据的参数---</color>")
        Network.SendRequest("get_share_url", _parm, "", function(_data)
            dump(_data, "<color=yellow>分享数据>>>>>>>>>>>>>>>>>>></color>")
            if AppDefine.IsEDITOR() then
                _data.result = 0
                _data.share_url = "www.baidu.com"
            end
            MainModel.UserInfo.shareURL = _data
            if call then
                call(MainModel.UserInfo.shareURL)
            end
        end)
    end
end

-- 分享的状态 万元赛砍价
function MainModel.GetShareStatusARG(call)
    if MainModel.UserInfo.shareARGtatus then
        if call then
            call()
        end
    else
        Network.SendRequest("query_everyday_shared_award", {type="wys_shared"}, function (_data)
            if _data.status then
                MainModel.UserInfo.shareARGtatus = _data.status
                MainModel.UserInfo.shareARGvalue = _data.arg
            else
                MainModel.UserInfo.shareARGtatus = 0
                MainModel.UserInfo.shareARGvalue = _data.arg
            end
            Event.Brocast("UpdateARGShareRedHint")
            if call then
                call()
            end
        end)
    end
end

-- 分享的状态 朋友圈
function MainModel.GetShareStatusPYQ(call)
    if MainModel.UserInfo.sharePYQStatus then
        if call then
            call(MainModel.UserInfo.sharePYQStatus)
        end
    else
        Network.SendRequest("query_everyday_shared_award", {type="shared_timeline"}, function (_data)  
            if _data.status then
                MainModel.UserInfo.sharePYQStatus = _data.status
            else
                MainModel.UserInfo.sharePYQStatus = 0
            end
            Event.Brocast("UpdateHallShareRedHint")
            if call then
                call(MainModel.UserInfo.sharePYQStatus)
            end
        end)
    end
end
-- 分享的状态 好友
function MainModel.GetShareStatusHY(call)
    if MainModel.UserInfo.shareHYStatus then
        if call then
            call(MainModel.UserInfo.shareHYStatus)
        end
    else
        Network.SendRequest("query_everyday_shared_award", {type="shared_friend"}, function (_data)  
            if _data.status then
                MainModel.UserInfo.shareHYStatus = _data.status
            else
                MainModel.UserInfo.shareHYStatus = 0
            end
            Event.Brocast("UpdateHallShareRedHint")
            if call then
                call(MainModel.UserInfo.shareHYStatus)
            end
        end)
    end
end

-- 炫耀的状态
function MainModel.GetFlauntStatus(call)
    if MainModel.UserInfo.flauntStatus then
        if call then
            call(MainModel.UserInfo.flauntStatus)
        end
    else
        Network.SendRequest("query_everyday_shared_award", {type="flaunt"}, function (_data)
            if _data.status then
                MainModel.UserInfo.flauntStatus = _data.status
            else
                MainModel.UserInfo.flauntStatus = 0
            end
            if call then
                call(MainModel.UserInfo.flauntStatus)
            end
        end)
    end
end

-- 城市杯门票的状态
function MainModel.GetCityStatus(call)
    if MainModel.UserInfo.cityStatus then
        if call then
            call(MainModel.UserInfo.cityStatus)
        end
    else
        Network.SendRequest("query_everyday_shared_award", {type="city"}, function (_data)  
            if _data.status then
                MainModel.UserInfo.cityStatus = _data.status
            else
                MainModel.UserInfo.cityStatus = 0
            end
            if call then
                call(MainModel.UserInfo.cityStatus)
            end
        end)
    end
end

-- 分享的状态 千元赛分享拿门票
function MainModel.GetShareStatusQYS(call)
    -- 不缓存这个的分享状态
    if false and MainModel.UserInfo.shareQYSstatus then
        if call then
            call()
        end
    else
        Network.SendRequest("query_everyday_shared_award", {type="qys_shared"}, function (_data)
            if _data.status then
                MainModel.UserInfo.shareQYSstatus = _data.status
            else
                MainModel.UserInfo.shareQYSstatus = 0
            end
            Event.Brocast("UpdateQYSShareRedHint")
            if call then
                call()
            end
        end)
    end
end
-- 发送分享完成
function MainModel.SendShareFinish(type)
    if type == "flaunt" then
        Network.SendRequest("shared_finish", {type="flaunt"}, "")
        MainModel.UserInfo.flauntStatus = 0
    elseif type == "shared_pyq" then
        Network.SendRequest("shared_finish", {type="shared_timeline"}, "")
        MainModel.UserInfo.sharePYQStatus = 0
        Event.Brocast("UpdateHallShareRedHint")
    elseif type == "shared_hy" then
        Network.SendRequest("shared_finish", {type="shared_friend"}, "")
        MainModel.UserInfo.shareHYStatus = 0
        Event.Brocast("UpdateHallShareRedHint")
    elseif type == "city" then
        Network.SendRequest("shared_finish", {type="city"}, "")
        MainModel.UserInfo.cityStatus = 0
    elseif type == "shared_match" then
        dump(MainModel.UserInfo, "<color=blue>SendShareFinish shared_match</color>")
        if MainModel.UserInfo.shared_matchStatus then
            if MainModel.UserInfo.shared_matchStatus == 0 then return end
            Network.SendRequest("shared_finish", {type="shared_match"}, "",function ( data )
                dump(data, "<color=blue>shared_finish</color>")
            end)
            MainModel.UserInfo.shared_matchStatus = MainModel.UserInfo.shared_matchStatus - 1
        end
    elseif type == "one_yuan_match" then
        Network.SendRequest("shared_finish", {type="one_yuan_match"}, "",function ( data )
            dump(data, "<color=blue>shared_finish</color>")
            Event.Brocast("one_yuan_match_share_finsh")
        end)
        --测试数据
        -- Event.Brocast("one_yuan_match_share_finsh")
    elseif type == "shared_qys" then
        Network.SendRequest("shared_finish", {type="qys_shared"}, "")
        MainModel.UserInfo.qysStatus = 0
    elseif type == "cdm_shared" then
        Network.SendRequest("shared_finish", {type="cdm_shared"}, "")
    else
        print("<color=red>NMG 发送分享完成 = " .. type .. "</color>")
    end
end

-- 获取实名认证状态
function MainModel.GetVerifyStatus(call)
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_real_name_verify", is_on_hint = true}, "CheckCondition")
    if (a and b) or not GameGlobalOnOff.Certification or MainModel.UserInfo.verifyData then
        if call then
            call()
        end
    else
        Network.SendRequest("query_real_name_authentication", nil, function (_data)
            MainModel.SetVerifyStatus(_data.status)
            if call then
                call()
            end
        end)
    end
end
function MainModel.SetVerifyStatus(status)
    if not MainModel.UserInfo.verifyData then
        MainModel.UserInfo.verifyData = {}
    end
    MainModel.UserInfo.verifyData.status = status

    Event.Brocast("UpdateHallHeroRedHint")

    Event.Brocast("MainModelUpdateVerify")
end
-- 获取手机绑定
function MainModel.GetBindPhone(call)
    if not GameGlobalOnOff.BindingPhone then
        if call then call() end
	       return
    end

    if MainModel.UserInfo.phoneData then
        if call then
            call()
        end
    else
        Network.SendRequest("query_bind_phone", nil, function (_data)
            MainModel.SetBindPhone(_data.phone_no)
            if call then
                call()
            end
        end)
    end
end
function MainModel.SetBindPhone(phone)
    if not MainModel.UserInfo.phoneData then
        MainModel.UserInfo.phoneData = {}
    end
    MainModel.UserInfo.phoneData.phone_no = phone
    Event.Brocast("UpdateHallHeroRedHint")
end

function MainModel.GetBindZFB(call)
    if MainModel.UserInfo.zfbData then
        if call then
            call()
        end
    else
        Network.SendRequest("get_alipay_data", nil, function (_data)
            if _data.result == 0 then
                MainModel.SetBindZFB({name = _data.name, account = _data.account})
            end
            if call then
                call()
            end
        end)
    end
end

function MainModel.SetBindZFB(zfb_data)
    MainModel.UserInfo.zfbData = zfb_data
end

function MainModel.SetNewItemTime(assetType)
    if not GameItemModel then return end
    local cfg = GameItemModel.GetItemToKey(assetType)
    if cfg and cfg.is_show_bag and cfg.is_show_bag == 1 then
        PlayerPrefs.SetString(this.RecentlyGetNewItemTime, os.time())
        Event.Brocast("UpdateHallBagRedHint")
        if GameItemModel.GetItemType(cfg) == GameItemModel.ItemType.act or GameItemModel.GetItemType(cfg) == GameItemModel.ItemType.skill then
            PlayerPrefs.SetString(this.RecentlyGetNewItemTimeFishing, os.time())
            Event.Brocast("UpdateFishingBagRedHint")
        end
    end
end

-- 设置音效开关
function MainModel.SetLocalSoundOnOff(b)
    PlayerPrefs.SetInt(this.LocalSoundOnOffKey, b)
end
-- 获取音效开关
function MainModel.GetLocalSoundOnOff()
    return PlayerPrefs.GetInt(this.LocalSoundOnOffKey, 1)
end

-- 获取游戏位置类型
function MainModel.GetLocalType(sceneName)
    local sceneName = sceneName or MainModel.myLocation
    if sceneName then
        local kk = string.sub(sceneName, 1, 7)
        if kk == "game_Mj" or kk == "game_MJ" then
            return "mj"
        elseif kk == "game_Dd" then
            return "ddz"
        else
            return "hall"
        end
    else
        return "nil"
    end
end


function MainModel.Update ()

    --登录后之后才会有这些操作
    if this.IsLoged then

        heartbeat(UPDATE_INTERVAL)

        sendReConnectRequest(UPDATE_INTERVAL)

    end

    if reLoginOverTimeCbk then
        if reLoginStartTime + reLoginMaxTime < os.time() then
            reLoginOverTimeCbk()
            reLoginOverTimeCbk = nil
        end
    end

    if MainModel.UserInfo and MainModel.UserInfo.first_login_time and MainModel.UserInfo.ui_config_id and MainModel.UserInfo.ui_config_id == 2 then
        local c_t = os.time()
        if c_t > tonumber(MainModel.UserInfo.first_login_time) + 7 * 86400 then
            MainModel.UserInfo.ui_config_id = 1
            Event.Brocast("player_new_change_to_old")
        end
    end
end

function MainModel.Exit ()
    if this then
        UpdateTimer:Stop()

        RemoveLister()

        reConnectServerState = 0
        reConnectServerCount = 0
        reConnectDt = 0

        HeartBeatLostNum = 0
        heartbeatDt = 0

        this.Location = nil
        this.IsLoged = nil
        this.UserInfo = nil
        this.LoginInfo = nil
        this.RoomCardInfo = nil
        this = nil

        IosPayManager.Exit()
		AndroidPayManager.Exit()
    end
    
end

function MainModel.OnGestureCircle()
	Event.Brocast("GMPanel")
end

MainModel.CityMatchState = {
    CMS_Null = "没有比赛",
    CMS_Wait = "等待开始",
    CMS_MatchStage_One = "海选赛",
    CMS_MatchStage_Wait1 = "海选赛过渡复赛",
    CMS_MatchStage_Two_Singup = "复赛报名",
    CMS_MatchStage_Two = "复赛",
    CMS_MatchStage_Wait2 = "复赛过渡决赛",
    CMS_MatchStage_Three = "决赛",
    CMS_MatchStage_End = "比赛结束"
}

function MainModel.RequestCityMatchStateData(func1,func2)
    local data = {
        state = MainModel.CityMatchState.CMS_Null,
        time = -1
    }
    Network.SendRequest(
        "citymg_get_match_status",
        {},
        "正在请求城市杯数据",
		function(_data)
			dump(_data, "<color=green>城市杯数据：</color>")
			if _data.result == 0 then
                if _data.stage == "hx" then
                    if _data.status == "wait" then
                        data.state = MainModel.CityMatchState.CMS_Wait
                    elseif _data.status == "gaming" then
                        data.state = MainModel.CityMatchState.CMS_MatchStage_One
                    end
                elseif _data.stage == "fs" then
                    if _data.status == "wait" then
                        data.state = MainModel.CityMatchState.CMS_MatchStage_Wait1
                    elseif _data.status == "signuping" then
                        data.state = MainModel.CityMatchState.CMS_MatchStage_Two_Singup
                    elseif _data.status == "gaming" then
                        data.state = MainModel.CityMatchState.CMS_MatchStage_Two
                    end
                elseif _data.stage == "js" then
                    if _data.status == "wait" then
                        data.state = MainModel.CityMatchState.CMS_MatchStage_Wait2
                    elseif _data.status == "gaming" then
                        data.state = MainModel.CityMatchState.CMS_MatchStage_Three
                    elseif _data.status == "over" then
                        data.state = MainModel.CityMatchState.CMS_MatchStage_End
                    end
                else
                    data.state = MainModel.CityMatchState.CMS_Null
				end
				data.time = _data.time
                dump(data, "<color=green>城市杯处理后的数据：</color>")
                if func1 then func1(data) end
            else
                 --测试代码
                -- GameManager.GotoSceneID(14, data)
                HintPanel.ErrorMsg(_data.result)
            end
            if func2 then func2(data) end
            return data
        end
    )
end

function MainModel.GetItemCount(type)
    local n = 0
    if type and this.UserInfo and this.UserInfo[type] then
        n = this.UserInfo[type]
    end
    return n
end

function MainModel.GetItemStatus(type, id, itemType)
    local cfg = MainModel.GetShopingConfig(type, id, itemType)
    if not (MainModel.UserInfo.GiftShopStatus[id] and cfg) then
        log("<color=red>--->>>Make sure item exist in config file! ID:" .. id .. "</color>")
        return -1
    else
        return MainModel.UserInfo.GiftShopStatus[id].status
    end
end

function MainModel.on_goldpig2_task_remain_change_msg(pName, data)
    dump(data, "<color=yellow>MainModel.on_goldpig2_task_remain_change_msg:</color>")
    if data.task_remain then
        GameManager.GotoUI({key = "gift_golden_pig",goto_scene_parm = "panel2",task_remain = data.task_remain})
    end
end

function MainModel.SetItemStatus(id, status)
    if MainModel.UserInfo.GiftShopStatus[id] then
        MainModel.UserInfo.GiftShopStatus[id].status = status
    end
end

function MainModel.on_gift_bag_status_change_msg(pName, data)
    dump(data, "<color=yellow>on_gift_bag_status_change_msg</color>")
    if not this.UserInfo or not this.UserInfo.GiftShopStatus then
        return
    end
    local id = data.gift_bag_id
    if not this.UserInfo.GiftShopStatus[id] then
        this.UserInfo.GiftShopStatus[id] = {}
    end
    this.UserInfo.GiftShopStatus[id].status = data.status
    Event.Brocast("main_change_gift_bag_data_msg", id)
end

function MainModel.plyj_finish_response(_, data)
	dump(data, "<color=yellow>plyj_finish_response</color>")
	if data.result == 0 then
		this.UserInfo.plyj_status = 1
	else
		HintPanel.ErrorMsg(data.result)
	end
end
function MainModel.on_svr_vip_passage(_, data)
	print("-------------------------------------------------------------------------------------")
	dump(data, "<color=yellow>on_svr_vip_passage</color>")
	local content = data.vip_addr_data or ""
	File.WriteAllText(gameMgr:getLocalPath("svr_vip_passage.txt"), content)
end
function MainModel.CheckPushNotification()
    local PNState = sdkMgr:GetCanPushNotification()
    log("<color=yellow>--->>>Push notification state:" .. PNState .. "</color>")
    if PNState == 1 then
        HintPanel.Create(2, "您当前未开启游戏比赛消息。\n开启比赛消息后，千元赛开赛前能收到比赛通知，防止错过比赛实际。", function()
            sdkMgr:GotoSetScene("PUSH")
        end)
    end
end

-- 获取玩家类型
function MainModel.GetNewPlayer()
    if not MainModel.UserInfo then
        return PLAYER_TYPE.PT_New
    end
    if not MainModel.UserInfo.first_login_time then
        if not MainModel.UserInfo.ui_config_id then
            return PLAYER_TYPE.PT_New
        else
            if MainModel.UserInfo.ui_config_id == 1 then
                return PLAYER_TYPE.PT_Old
            else
                return PLAYER_TYPE.PT_New
            end
        end
    end
    local c_t = os.time()
    if c_t <= tonumber(MainModel.UserInfo.first_login_time) + 7 * 86400 then
        return PLAYER_TYPE.PT_New
    else
        return PLAYER_TYPE.PT_Old
    end
end
function MainModel.GetMarketChannel()
    if MainModel.UserInfo and MainModel.UserInfo.market_channel then
        return MainModel.UserInfo.market_channel
    end
    return "normal"
end

function MainModel.FirstLoginTime()
    if MainModel.UserInfo and MainModel.UserInfo.first_login_time then
        return tonumber(MainModel.UserInfo.first_login_time)
    end
    return os.time()
end

function MainModel.on_LoginResponse(result)
    if result ~= 0 then return end
    --sysJJJmanager获取数据
    --MainModel.get_subsidy_num()
end

function MainModel.get_subsidy_num()
    Network.SendRequest("query_broke_subsidy_num",nil,"",function(data)
        dump(data,"<color=red>分享救济金数据</color>")
        MainModel.UserInfo.shareCount = data.num or 0
        MainModel.UserInfo.shareAllNum = data.all_num or 0
    end)
    Network.SendRequest("query_free_broke_subsidy_num",nil,"",function(data)
        dump(data,"<color=red>免费救济金数据</color>")
        MainModel.UserInfo.freeSubsidyNum = data.num or 0
        MainModel.UserInfo.freeSubsidyAllNum = data.all_num or 0
    end)
end

--是否是微信登录
function MainModel.IsWeChatChannel()
    if true then return false end --统一走支付宝提现
    if not MainModel.UserInfo.channel_type then return end
    if MainModel.UserInfo.channel_type == "wechat" or 
        MainModel.UserInfo.channel_type == "yyb_wechat" then
        return true
	end
end

-- 华为low玩家
function MainModel.IsHWLowPlayer()
    local vip_l = MainModel.UserInfo.vip_level
    local channel_type = gameMgr:getMarketChannel()
    dump(channel_type, "<color=red>channel_type</color>")
    if channel_type == "hw_cymj" or channel_type == "hw_wqp" then
        -- key不准修改，修改的后果就是影响老玩家的状态
        local key1 = "HW_lx_state_" .. MainModel.UserInfo.user_id
        local key2 = "HW_lx_last_time_" .. MainModel.UserInfo.user_id
        local state = PlayerPrefs.GetInt(key1, 0)
        local old_t = PlayerPrefs.GetString(key2, "0")

        local ct = os.time()
        local y = os.date("%Y", ct)
        local m = os.date("%m", ct)
        local d = os.date("%d", ct)
        local t = os.time({year=tostring(y), month=tostring(m), day=tostring(d), hour ="0", min = "0", sec = "0"})

        local newtime = tonumber( os.date("%Y%m%d", t-1) )
        local oldtime = tonumber( os.date("%Y%m%d", tonumber(old_t)) )
        if oldtime == newtime then -- 连续登录
            state = 1
            PlayerPrefs.SetInt(key1, 1)
        end
        if vip_l < 1 and state == 0 then
            PlayerPrefs.SetString(key2, tostring(os.time()))
            return true
        end
    end
end

function MainModel.OnExitScene()
    MainModel.asset_change_list = {}
end

function MainModel.GetScene_MatchWidthOrHeight(width, height)
    -- 1是高适配 0是宽适配
    -- 2020年04月02日 决定放弃宽适配
    if width / height < 1920 / 1080 then
        return 0 -- 2020年04月02日 决定放弃宽适配(return 0)
    else
        return 1
    end
end
-- 决定放弃宽适配后决定写个控制背景缩放的方法
function MainModel.SetGameBGScale(bg)
    local width = Screen.width
    local height = Screen.height
    if width / height < 1 then
        width,height = height,width
    end
    local matchWidthOrHeight = MainModel.GetScene_MatchWidthOrHeight(width, height)
    local scale
    if matchWidthOrHeight == 1 then
        scale = (width * 1080) / (height * 1920)
        if scale < 1 then
            scale = 1
        end
    else
        scale = (height * 1920) / (width * 1080)
        if scale < 1 then
            scale = 1
        end
    end
    if IsEquals(bg) then
        bg.transform.localScale = Vector3.New(scale, scale, 1)
    end
end

function MainModel.GetServerName()
    if this.UserInfo and this.UserInfo.server_name then
        return this.UserInfo.server_name
    else
        return SERVER_TYPE.ZS
    end
end

function MainModel.register_by_introducer_response(_,data)
    dump(data,"<color=white>register_by_introducer_response</color>")
    if not data then return end
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result)
        return
    end
    MainModel.UserInfo.parent_id = data.parent_id
    Event.Brocast("model_register_by_introducer_response")
end

--获取玩家此刻所拥有的小游戏币和金币之和
function MainModel.GetMiniGameCoinAndJingBiAllNum()
    local temp = MainModel.UserInfo.jing_bi + GameItemModel.GetItemCount("prop_tiny_game_coin")
    return temp
end



--获取当前小游戏场的"专属游戏币"和"金币"的显示("num"为消耗数量)
function MainModel.GetMiniGameCurCoinAndJingBiTXT(num)
    if num then
        local temp_data = {}
        local temp = 0
        if GameItemModel.GetItemCount("prop_tiny_game_coin") < num then
            temp = num - GameItemModel.GetItemCount("prop_tiny_game_coin")
            temp_data.jing_bi = MainModel.UserInfo.jing_bi - temp
            temp_data.coin = 0
            return temp_data
        else
            temp_data.jing_bi = MainModel.UserInfo.jing_bi
            temp_data.coin = GameItemModel.GetItemCount("prop_tiny_game_coin") - num
            return temp_data
        end
    else
        dump(num,"<color>-----------------num为空--------------------</color>")
    end
end