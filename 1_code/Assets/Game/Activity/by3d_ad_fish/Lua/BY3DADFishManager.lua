-- 创建时间:2020-08-04
-- BY3DADFishManager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DADFishManager = {}
local M = BY3DADFishManager
M.key = "by3d_ad_fish"
GameButtonManager.ExtLoadLua(M.key, "BY3DADFishPanel")
GameButtonManager.ExtLoadLua(M.key, "BY3DADFishEnterPrefab")

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

    if not SYSQXManager.IsNeedWatchAD() then
        return false
    end

    -- 对应权限的key
    local _permission_key = "cps_ggxt"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and  b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    if MainModel.myLocation == "game_Fishing3D" and FishingModel and FishingModel.GetPlayerData() and FishingModel.game_id < 4 then
        return M.IsActive()
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
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

    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
    lister["fsg_3d_query_ad_fish_response"] = this.on_fsg_3d_query_ad_fish
    lister["fsg_3d_use_ad_fish_response"] = this.on_fsg_3d_use_ad_fish
    lister["fsg_3d_ad_fish_come"] = this.on_fsg_3d_ad_fish_come
end

function M.Init()
	M.Exit()

	this = BY3DADFishManager
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

function M.QueryInfoData()
    NetMsgSendManager.SendMsgQueue("fsg_3d_query_ad_fish")
end

function M.on_fishing_ready_finish()
    if M.CheckIsShow() then
        if SYSQXManager.IsNeedWatchAD() and M.IsActive() then
            M.QueryInfoData()
        end
    end
end

function M.on_fsg_3d_query_ad_fish(_, data)
    dump(data, "<color=red>EEE fsg_3d_query_ad_fish</color>")
    if data.result == 0 then
        if data.time then
            this.m_data.time = tonumber(data.time)
            this.m_data.award = data.award
        else
            this.m_data.time = 0
        end
        M.CheckAndCreateADFish()
    end
end
function M.on_fsg_3d_use_ad_fish(_, data)
    dump(data, "<color=red>EEE fsg_3d_use_ad_fish</color>")
end

function M.on_fsg_3d_ad_fish_come(_, data)
    dump(data, "<color=red>EEE fsg_3d_ad_fish_come</color>")
    if data.time then
        this.m_data.time = tonumber(data.time)
        this.m_data.award = data.award
    else
        this.m_data.time = 0
    end
    M.CheckAndCreateADFish()
end

function M.CheckAndCreateADFish()
    Event.Brocast("by3d_ad_fish_close_msg")
    if M.CheckIsShow() then
        if this.m_data.time and (this.m_data.time + 60) > os.time() then
            BY3DADFishEnterPrefab.Create()
        end
    end
end

function M.GetAwardData()
    if this.m_data.award then
        return AwardManager.GetAssetsList(this.m_data.award)
    end
    return {}
end

function M.GetADFishTime()
    local t = (this.m_data.time + 60) - os.time()
    if t < 30 then
        t = 30
    end
    return t
end
