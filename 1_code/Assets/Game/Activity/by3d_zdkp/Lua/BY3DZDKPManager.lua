-- 创建时间:2020-08-03
-- BY3DZDKPManager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DZDKPManager = {}
local M = BY3DZDKPManager
M.key = "by3d_zdkp"
GameButtonManager.ExtLoadLua(M.key, "BY3DZDKPEnterPanel")
GameButtonManager.ExtLoadLua(M.key, "BY3DZDKPHintPanel")

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
function M.CheckIsShow(parm, type)
    -- 8是激光场，没有自动开炮
    if MainModel.myLocation == "game_Fishing3D" and FishingModel and FishingModel.GetPlayerData() and FishingModel.game_id ~= 8 then
        return M.IsActive()
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "enter" then
        return BY3DZDKPEnterPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
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

    lister["fsg_3d_query_auto_fire_response"] = this.on_fsg_3d_query_auto_fire
    lister["fsg_3d_use_auto_fire_response"] = this.on_fsg_3d_use_auto_fire

    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
end

function M.Init()
	M.Exit()

	this = BY3DZDKPManager
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

    -- 有条件限制的场次配置
    this.UIConfig.tj_cc_map = {}
    this.UIConfig.tj_cc_map[1] = {sy_time = 900, max_num = 5}
    this.UIConfig.tj_cc_map[2] = {sy_time = 900, max_num = 5}
    this.UIConfig.tj_cc_map[3] = {sy_time = 900, max_num = 5}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_fishing_ready_finish()
    Event.Brocast("ui_button_state_change_msg")
end

function M.QueryAutoData()
    if this.m_data.is_query_wc then
        Event.Brocast("by3d_zdkp_query_auto_msg")
    else
        Network.SendRequest("fsg_3d_query_auto_fire")
    end
end
function M.on_fsg_3d_query_auto_fire(_, data)
    dump(data, "<color=red>EEE fsg_3d_query_auto_fire</color>")
    this.m_data.result = data.result
    if data.result == 0 then
        this.m_data.is_query_wc = true
        this.m_data.num = data.num
        if data.time then
            this.m_data.time = tonumber(data.time)
        else
            this.m_data.time = 0
        end
        Event.Brocast("by3d_zdkp_query_auto_msg")
    end
end
function M.on_fsg_3d_use_auto_fire(_, data)
    dump(data, "<color=red>EEE fsg_3d_use_auto_fire</color>")
    if data.result == 0 then
        this.m_data.num = data.num
        if data.time then
            this.m_data.time = tonumber(data.time)
        else
            this.m_data.time = 0
        end
        Event.Brocast("by3d_zdkp_sy_auto_msg")
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.IsHintTJOpen()
    if SYSQXManager.IsNeedWatchAD() then
        if this.UIConfig.tj_cc_map[FishingModel.game_id] then
            return true
        end
    end
end
function M.GetCount()
    return this.m_data.num or 0
end
-- 试用的时间
function M.GetSYTime()
    if this.m_data.time and this.m_data.time > os.time() then
        return this.m_data.time - os.time()
    end
    return 0
end
