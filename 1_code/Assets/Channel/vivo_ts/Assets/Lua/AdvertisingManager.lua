-- 创建时间:2019-11-25
-- 广告系统 管理器

local basefunc = require "Game/Common/basefunc"
AdvertisingManager = {}
local M = AdvertisingManager
local advertising_config = HotUpdateConfig("Game.CommonPrefab.Lua.advertising_config")

local this
local lister
local ad_map = {}
local ad_key_map = {}
local cur_ad_data
local isOnOff = false
-- 是否是测试阶段的广告
local isTest = false

local isDebug = true
local debug_map = {}

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed

    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg

    lister["sdk_ad_msg"] = this.on_sdk_ad_msg
end

function M.Init()
	M.Exit()

	this = AdvertisingManager
	this.m_data = {}
    this.ad_map = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig={}
    this.UIConfig.AD = advertising_config.config
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end
function M.on_backgroundReturn_msg()
end
function M.on_background_msg()
end


function M.AddAdData(ad_id, key, val)
    if not M.ad_map[ad_id] then
        M.ad_map[ad_id] = {}
    end
    M.ad_map[ad_id][key] = val
end

local ad_error ={
    [20001] = "恭喜您获得免广告特权免除该次广告，充值6元及以上可永久免广告哦！",
    [40007] = "广告获取失败，请重试。",
    [40020] = "恭喜您获得免广告特权免除该次广告，充值6元及以上可永久免广告哦！",
    [40026] = "您的网络地址不正确，请切换网络后重试。",
    [50001] = "广告获取失败，请重试。",
    [60007] = "广告获取失败，请重试。",
    [-1] = "广告获取失败，请重试。",
    [-2] = "您的网络不稳定，待网络稳定后请重试",
    [-3] = "广告获取失败，请重试。",
    [-4] = "广告获取失败，请重试。",
    [-8] = "您看广告太频繁了，请稍作休息10秒后重试。",
    [101] = "广告获取失败，请重试。",
    [102] = "广告获取失败，请重试。",
    [106] = "广告获取失败，请重试。",
}

-- 对接广告接口
function M.OnError(data) -- 下载错误
    local ad_id = data.ad_id
    M.AddAdData(ad_id, "error_code", data.errorCode)
    if M.ad_map[ad_id].call then
        M.ad_map[ad_id].call({result=-999, errorCode = data.errorCode})
    else
        HintPanel.Create(1, "您的网络不稳定，待网络稳定后请重试..")
    end
    Event.Brocast("model_sdk_ad_msg", {result=-999, errorCode = data.errorCode})
    
    if ad_error[data.errorCode] then
        HintPanel.Create(1, ad_error[data.errorCode], function ()
            if tonumber(data.errorCode) == 20001 or tonumber(data.errorCode) == 40020 then
                PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
            end
        end)
    end
end
function M.OnAdClose(data) -- 关闭
    cur_ad_data = nil
    local ad_id = data.ad_id
    if isDebug and debug_map[ad_id] then
        dump(debug_map[ad_id], "<color=red>SYS AD Close</color>")
    end
    dump(M.ad_map[ad_id], "<color=red>SYS AD State</color>")
    if M.ad_map[ad_id] then
        if M.ad_map[ad_id].call then
            M.ad_map[ad_id].call({result=0, isVerify=M.ad_map[ad_id].isVerify})
        else
            if not M.ad_map[ad_id].isVerify then
                HintPanel.Create(1, "广告观看失败，请重新观看.")
            end
        end
        if M.ad_map[ad_id].cg_call and M.ad_map[ad_id].isVerify then
            M.ad_map[ad_id].cg_call()
        end
        Event.Brocast("model_sdk_ad_msg", {result=0, isVerify=M.ad_map[ad_id].isVerify})
    else
        Event.Brocast("model_sdk_ad_msg", {result=0})
    end
end
function M.OnVideoComplete(data) -- 播放完成
    M.AddAdData(data.ad_id, "isVideoComplete", true)    
end
function M.OnVideoError(data) -- 播放错误
    HintPanel.Create(1,"广告播放错误，请重试")
    local ad_id = data.ad_id
    M.AddAdData(ad_id, "isVideoError", true)
    if M.ad_map[ad_id].call then
        M.ad_map[ad_id].call({result=2})
    else
        HintPanel.Create(1, "您的网络不稳定，待网络稳定后请重试...")
    end
    Event.Brocast("model_sdk_ad_msg", {result=2})
end
function M.OnRewardVerify(data) -- 播放有效
    if data.result == 0 and (isTest or data.rewardVerify) then
        M.AddAdData(data.ad_id, "isVerify", true)

        if cur_ad_data then
            ad_key_map[cur_ad_data.key] = {play_time=os.time()}
        end
    end
end
function M.on_sdk_ad_msg(fun_name, data)
    dump(data, "<color=red>SYS AD data</color>")
    if M[fun_name] then
        if isDebug then
            if debug_map[data.ad_id] then
                debug_map[data.ad_id] = debug_map[data.ad_id] .. "->" .. fun_name
            else
                print("<color=red>SYD AD Error</color>")
                debug_map[data.ad_id] = fun_name
            end
        end
        if not data.ad_id or data.ad_id == "" and cur_ad_data then
            data.ad_id = cur_ad_data.ad_id
        end
        dump(data, "<color=red>SYD AD fun_name = " .. fun_name .. " </color>")
        M[fun_name](data)
    end
end

-- 随机播放广告
function M.RandPlay(key, call, cg_call)
    if not isOnOff then
        if call then
            call({result=0, isVerify=true})
        end
        if cg_call then
            cg_call()
        end
        Event.Brocast("model_sdk_ad_msg", {result=0, isVerify=true})
        return
    end

    -- Ios看不了广告
    if not M.IsHaveAD() then
        if call then
            call({result=0, isVerify=true})
        end
        if cg_call then
            cg_call()
        end
        Event.Brocast("model_sdk_ad_msg", {result=0, isVerify=true})
        return
    end

    if ad_key_map[key] then
        local t = ad_key_map[key].play_time
        if (os.time() - t) < 30 then -- 小于30秒 不播放广告
            print("<color=white>同一广告播放间隔太短</color>")
            if call then
                call({result=3})
            else
                HintPanel.Create(1, "广告正在填充中，请稍后再播放")
            end
            Event.Brocast("model_sdk_ad_msg", {result=3})
            return
        end
    end

    if AppDefine.IsEDITOR() then
        ad_key_map[key] = {play_time=os.time()}
        if call then
            call({result=0, isVerify=true})
        end
        if cg_call then
            cg_call()
        end
        DSM.ADShow(key)
        Event.Brocast("model_sdk_ad_msg", {result=0, isVerify=true})
        return
    end

    local index = math.random(1, #this.UIConfig.AD)
    local cfg = this.UIConfig.AD[index]
    local ad_id = cfg.ad_id
    ad_id = tostring(ad_id)
    local width = Screen.width
    local height = Screen.height
    if width / height < 1 then
        width,height = height,width
    end
    width = 1024
    height = 768

    cur_ad_data = {ad_id = ad_id, key=key}
    M.ad_map[ad_id] = {}
    M.AddAdData(ad_id, "key", key)
    M.AddAdData(ad_id, "call", call)
    M.AddAdData(ad_id, "cg_call", cg_call)

    if isDebug then
        debug_map[ad_id] = "RandPlay"
    end
    DSM.ADShow(key)
    RewardADMgr.PrepareAD(ad_id, "金币", 3, MainModel.UserInfo.user_id, "extra", width, height, function(id, preRet)
        print("[AD] prepare result:" .. id .. ", " .. preRet)
        if preRet == 0 then
            --准备成功
            print("<color=white>广告准备成功</color>")
        else
            print("<color=white>广告准备失败</color>")
        end
    end)
end

-- 是否有广告
function M.IsHaveAD()
    return not M.IsCloseAD()
end

function M.IsCloseAD()
    if gameRuntimePlatform == "Ios" then
        return true
    else
        return false
    end
end
