-- 创建时间:2020-08-19
-- Act_026_SGXXLYDManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_026_SGXXLYDManager = {}
local M = Act_026_SGXXLYDManager
M.key = "act_026_sgxxlyd"
M.config = GameButtonManager.ExtLoadLua(M.key,"act_026_sgxxlyd_config")
GameButtonManager.ExtLoadLua(M.key, "Act_026_SGXXLYDPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_026_SGXXLYDEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_026_SGXXLYDHallIcon")
GameButtonManager.ExtLoadLua(M.key, "Act_026_SGXXLYDMini")

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

    if not M.is_still_award() then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_026_sgxxl_yd"
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
    if parm.goto_scene_parm == "panel" then
        return Act_026_SGXXLYDPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "enter" then
        return Act_026_SGXXLYDEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "enter2" then
        return Act_026_SGXXLYDMini.Create(parm.parent)
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

    lister["EnterScene"] = this.OnEnterScene
    lister["model_get_task_award_response"] = this.on_get_task_award_response
    lister["EliminateMoneyPanel_change_bet_msg"] = this.SetBet
end

function M.Init()
	M.Exit()

	this = Act_026_SGXXLYDManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
    M.InitTask_id()
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

function M.InitTask_id()
    this.m_data.task_ids = {}
    for i=1,#M.config do
        this.m_data.task_ids[#this.m_data.task_ids + 1] = M.config[i].task_id
    end
end

function M.GetTask_id()
    return this.m_data.task_ids
end

function M.OnEnterScene()
    local channel_type = gameMgr:getMarketChannel()
    if M.IsActive() then
        if MainModel.myLocation == "game_Eliminate" then
            Event.Brocast("SGXXLYD_enter_msg")
            Act_026_SGXXLYDPanel.Create()
        else
            if MainModel.myLocation == "game_Hall"  then
                if not MainModel.IsLowPlayer() then
                    Act_026_SGXXLYDHallIcon.Create()
                elseif channel_type ~= "vivo" and channel_type ~= "xiaomi" then
                    Act_026_SGXXLYDHallIcon.Create()
                end
            end   
        end
    end
end

function M.is_still_award()
    local task_ids = M.GetTask_id()
    for i=1,#task_ids do
        data = GameTaskModel.GetTaskDataByID(task_ids[i])
        if data and data.award_status ~= 2 then
            return true
        end
    end
    return false
end

function M.on_get_task_award_response(data)
    if data then
        local ids = M.GetTask_id()
        for i=1,#ids do
            if ids[i] == data.id then
                Event.Brocast("ui_button_state_change_msg")
            end
        end
    end
end

function M.SetBet(bet)
    this.m_data.bet = bet
    Event.Brocast("bet_is_change_msg")
end

function M.GetBet()
    return this.m_data.bet
end