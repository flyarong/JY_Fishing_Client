-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
SysInteractivePlayerManager = {}
local M = SysInteractivePlayerManager
M.key = "sys_interactive_player"
M.config = GameButtonManager.ExtLoadLua(M.key, "player_Interaction")
print("<color=red>？？？？？？？？？？？？？？？？？？？</color>")
GameButtonManager.ExtLoadLua(M.key, "PersonalInfoManager")
GameButtonManager.ExtLoadLua(M.key, "PlayerInfoPanel")
local lister
function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return PlayerInfoPanel.Create(parm.data, parm.uipos)
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
end

function M.Init()
	M.Exit()
	M.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    print("<color=red>初始化？？？？？？？？？？？？？？</color>")
    PersonalInfoManager.Init()
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

function M.Create(data,uipos)
    PlayerInfoPanel.Create(data, uipos)
end
function M.Close(  )
    PlayerInfoPanel.Exit()
end