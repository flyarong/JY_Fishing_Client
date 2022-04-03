-- 创建时间:2019-10-23
-- 签到系统管理器

local basefunc = require "Game/Common/basefunc"
SYSQDManager = {}
local M = SYSQDManager
M.key = "sys_qd"
GameButtonManager.ExtLoadLua(M.key, "SYSQD_JYFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSQD_EnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "SignInPanel")
local signIn_cfg = GameButtonManager.ExtLoadLua(M.key, "signIn_cfg")

local this
local lister

-- 是否有活动
function M.IsActive(condi_key)
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = condi_key
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

function M.CheckIsShow(parm)
    return M.IsActive(parm.condi_key)
end
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        return
    end
    if parm.goto_scene_parm == "panel" then
        return SignInPanel.Create()
    elseif parm.goto_scene_parm == "jyfl_enter" then
        return SYSQD_JYFLEnterPrefab.Create(parm.parent, parm.cfg)
    elseif parm.goto_scene_parm == "enter" then
    	return SYSQD_EnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if this.m_data then
		if not table_is_null(this.m_data.acc_award) or this.m_data.sign_in_award == 1 then
			return ACTIVITY_HINT_STATUS_ENUM.AT_Get
		else
			return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
		end
	end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
function M.SetHintState()
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

    lister["query_sign_in_data_response"] = this.on_query_sign_in_data_response
end

function M.Init()
	M.Exit()

	this = SYSQDManager
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
    
    this.UIConfig.week = {}
    for k,v in ipairs(signIn_cfg.week) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= v.key, is_on_hint = true}, "CheckCondition")
        if a and b then
            this.UIConfig.week[#this.UIConfig.week + 1] = v
            if #this.UIConfig.week == 7 then
                break
            end
        end
    end

    this.UIConfig.month = {}
    for k,v in ipairs(signIn_cfg.month) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= v.key, is_on_hint = true}, "CheckCondition")
        if a and  b then
            this.UIConfig.month[#this.UIConfig.month + 1] = v
        end
    end
    this.UIConfig.vip_map = {}
    if signIn_cfg.vip then
        for k,v in pairs(signIn_cfg.vip) do
            this.UIConfig.vip_map[v.vip_level] = v
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
		Network.SendRequest("query_sign_in_data")
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_query_sign_in_data_response(_, data)
	dump(data, "<color=red>SYSQD on_query_sign_in_data_response</color>")
	if data and data.result == 0 then
		this.m_data = data
		Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
	end
end

function M.GetConfig()
     return this.UIConfig
end



