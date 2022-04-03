-- 创建时间:2021-08-06
-- SYS_Exit_AskManager 管理器

local basefunc = require "Game/Common/basefunc"
SYS_Exit_AskManager = {}
local M = SYS_Exit_AskManager
M.key = "sys_exit_ask"

M.config = GameButtonManager.ExtLoadLua(M.key,"sys_exit_ask_config")
GameButtonManager.ExtLoadLua(M.key, "SYS_Exit_AskPanel")
GameButtonManager.ExtLoadLua(M.key, "SYS_Exit_AskItemBase")

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

    if FishingModel.game_id and (FishingModel.game_id == 2 or FishingModel.game_id == 3 or FishingModel.game_id == 4 or FishingModel.game_id == 5) then
    else
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
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end

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

    lister["sys_exit_ask_open_msg"] = this.on_sys_exit_ask_open_msg 
    lister["finish_gift_shop"] = this.on_finish_gift_shop--完成礼包购买
end

function M.Init()
	M.Exit()

	this = SYS_Exit_AskManager
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

    this.UIConfig.gift_id_map = {}
    for k,v in pairs(M.config.gift_config) do
        this.UIConfig.gift_id_map[v.game_id] = this.UIConfig.gift_id_map[v.game_id] or {}
        this.UIConfig.gift_id_map[v.game_id][v.gift_id] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetGiftConfig()
    return this.UIConfig.gift_id_map[FishingModel.game_id]
end

function M.GetCheckConfig()
    return M.config["check_config"]
end

function M.on_sys_exit_ask_open_msg(callback)
    SYS_Exit_AskPanel.Create(callback)
end

function M.on_finish_gift_shop(id)
    for k,v in pairs(this.UIConfig.gift_id_map) do
        for kk,vv in pairs(v) do
            if vv.gift_id == id then
                Event.Brocast("sys_exit_ask_gift_buy_msg")
                break
            end
        end
    end
end