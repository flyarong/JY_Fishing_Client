-- 创建时间:2020-05-06
-- Act_026_BBLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_026_BBLBManager = {}
local M = Act_026_BBLBManager
M.key = "act_026_bblb"
GameButtonManager.ExtLoadLua(M.key, "Act_026_BBLBPanel")
M.config = {
    {shop_id = 10281,price = 1314,title = "一生一世",award1_txt = "1亿3140万金币",award2_txt = "300万鱼币", award3_txt = "520爱心"},
    {shop_id = 10282,price = 520,title = "我爱你",award1_txt = "5200万金币",award2_txt = "100万鱼币", award3_txt = "258爱心"},
    {shop_id = 10283,price = 258,title = "爱我吧",award1_txt = "2580万金币",award2_txt = "50万鱼币", award3_txt = "147爱心"},
    {shop_id = 10284,price = 147,title = "一世情",award1_txt = "1470万金币",award2_txt = "30万鱼币", award3_txt = "52爱心"},
    {shop_id = 10285,price = 52,title = "吾爱",award1_txt = "520万金币",award2_txt = "10万鱼币", award3_txt = "28爱心"},
}

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_026_BBLBPanel.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if not M.CheckIsShowInActivity(parm) then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end

    local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
    if oldtime ~= newtime then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Red
    end
    return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


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
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg
end

function M.Init()
	M.Exit()

	this = Act_026_BBLBManager
	this.m_data = {}
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
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()

end

function M.BuyShop(shopid)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function M.QueryDataTimer(bool)
    M.StopTimer()
    if bool then
        this.m_data.Timer = Timer.New(function ()
            M.IsTomarrow()
        end,10,-1,false)
        this.m_data.Timer:Start()
    end
end

function M.StopTimer()
    if this.m_data.Timer then
        this.m_data.Timer:Stop()
        this.m_data.Timer = nil
    end
end

function M.IsTomarrow()
    if os.time() >= PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."BBLB") then
        M.QueryData()
    end
end

function M.QueryData()
    local msg_list = {}
    local gift_ids = {10281,10282,10283,10284,10285}
    for k,v in pairs(gift_ids) do
        msg_list[#msg_list + 1] = {msg="query_gift_bag_status", data = {gift_bag_id = v}}
    end
    GameManager.SendMsgList("bblb", msg_list)
end

function M.on_query_send_list_fishing_msg(tag)
    if tag == "bblb" then
        M.StopTimer()
        Event.Brocast("Act_026_BBLBManager_status_change_msg")
    end
end