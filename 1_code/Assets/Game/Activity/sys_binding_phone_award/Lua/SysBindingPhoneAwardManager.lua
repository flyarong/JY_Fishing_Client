-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
SysBindingPhoneAwardManager = {}
local M = SysBindingPhoneAwardManager
M.key = "sys_binding_phone_award"
GameButtonManager.ExtLoadLua(M.key, "AwardBindingPhonePanel")
M.config = GameButtonManager.ExtLoadLua(M.key, "sys_binding_phone")
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
        if a and b then
            return false
        end
        dump(_permission_key, "<color=red><size=16>_permission_key</size></color>")
        return true
    else
        return true
    end
end

function M.CheckIsShow()
    return M.IsActive()
end
function M.GotoUI(parm)
    print("<color=white>parm.gotoui</color>",parm.gotoui)
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() and MainModel.IsNeedBindPhone() then
            M.m_data.panel_open_count = M.m_data.panel_open_count + 1
            return AwardBindingPhonePanel.Create(parm.parent ,parm.tips ,parm.binding_callback, parm.backcall)
        end
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
    lister["OnLoginResponse"] = M.OnLoginResponse
    lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg

    lister["EnterScene"] = M.OnEnterScene
end

function M.Init()
	M.Exit()
	M.m_data = {}
    M.m_data.panel_open_count = 0
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if M then
		RemoveLister()
		M.m_data = nil
	end
end
function M.InitUIConfig()
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

-- 是否弹提示
function M.IsPopupHint(parm)
    if M.CheckIsShow() and GameGlobalOnOff.BindingPhone and MainModel.IsNeedBindPhone() then
        return true
    end
    return false
end

function M.OnEnterScene()
    if M.m_data.panel_open_count > 0 and
        M.CheckIsShow()
        and GameGlobalOnOff.BindingPhone
        and MainModel.IsNeedBindPhone()
        and MainModel.lastmyLocation
        and MainModel.myLocation
        and MainModel.myLocation == "game_Hall"
        and MainModel.lastmyLocation ~= "game_Login" then

        M.m_data.panel_open_count = M.m_data.panel_open_count + 1
        AwardBindingPhonePanel.Create()
        
    end
end

function M.GetConfig()
    local cc = {}
    for k,v in ipairs(M.config.config) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            cc[#cc + 1] = v
        end
    end
    return cc
end