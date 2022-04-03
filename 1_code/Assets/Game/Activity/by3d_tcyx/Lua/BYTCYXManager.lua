-- 创建时间:2020-07-29
-- BYTCYXManager 管理器

local basefunc = require "Game/Common/basefunc"
BYTCYXManager = {}
local M = BYTCYXManager
M.key = "by3d_tcyx"
GameButtonManager.ExtLoadLua(M.key, "BYTCYXDownPrefab")

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
    return M.IsActive()
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

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg

    lister["SYSByPms_enter_scene"] = this.on_SYSByPms_enter_scene
    lister["ExitScene"] = this.OnExitScene

    lister["fishing_gameui_exit"] = this.on_fishing_gameui_exit
    lister["model_ready_finish_msg"] = this.on_model_ready_finish_msg
    lister["model_shoot"] = this.on_model_shoot
end

function M.Init()
	M.Exit()

	this = BYTCYXManager
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

function M.StopTime()
    if this.m_data.update_time then
        this.m_data.update_time:Stop()
        this.m_data.update_time = nil
    end
end

function M.on_reconnect_msg()
    if this.m_data.is_one_enter then
        
    end
end

function M.on_network_error_msg()
    if this.m_data.is_one_enter then
        Event.Brocast("by3d_tcyx_close_down_time_msg")
        M.StopTime()
    end
end

function M.on_fishing_gameui_exit()
    this.m_data.is_one_enter = false
    Event.Brocast("by3d_tcyx_close_down_time_msg")
    M.StopTime()
end
function M.on_model_ready_finish_msg()
    if MainModel.myLocation == "game_Fishing3D" and not this.m_data.is_pms then
        this.m_data.is_one_enter = true
        M.StartTime()
    end
end

function M.StartTime()
    this.m_data.down_time = 0
    this.m_data.cur_state = "nor"
    Event.Brocast("by3d_tcyx_close_down_time_msg")
    M.StopTime()
    this.m_data.update_time = Timer.New(function ()
        M.UpdateCall()
    end, 1, -1, nil, true)
    this.m_data.update_time:Start()
end

function M.UpdateCall()
    this.m_data.down_time = this.m_data.down_time + 1

    if this.m_data.cur_state == "nor" then
        if this.m_data.down_time > 300 then
            this.m_data.cur_state = "down"
            this.m_data.down_time = 0
            -- 显示倒计时界面
            BYTCYXDownPrefab.Create()
        end
    end
end

function M.on_model_shoot(data)
    if this.m_data.is_one_enter and data.seat_num == FishingModel.GetPlayerSeat() then
        if this.m_data.cur_state == "down" then
            Event.Brocast("by3d_tcyx_close_down_time_msg")
        end
        this.m_data.cur_state = "nor"
        this.m_data.down_time = 0
    end
end
function M.OnExitScene()
    this.m_data.is_pms = false
    M.StopTime()
end
function M.on_SYSByPms_enter_scene(b)
    this.m_data.is_pms = not b
    if this.m_data.is_pms then
        M.StopTime()
    else
        M.on_model_ready_finish_msg()
    end
end