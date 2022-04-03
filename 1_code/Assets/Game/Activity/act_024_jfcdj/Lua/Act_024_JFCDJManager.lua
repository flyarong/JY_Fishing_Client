-- 创建时间:2019-05-29
-- Panel:Act_024_JFCDJManager
local basefunc = require "Game/Common/basefunc"

Act_024_JFCDJManager = basefunc.class()
local M = Act_024_JFCDJManager
M.key = "act_024_jfcdj"
local config = GameButtonManager.ExtLoadLua(M.key, "act_024_jfcdj_config")
M.config = config
GameButtonManager.ExtLoadLua(M.key, "Act_024_JFCDJPanel")

local lister
local this
local type_info = {
	type = "summer_gift_day",
	start_time = 1,
    end_time = 1597679999, 
    config = config,
}


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

function M.CheckIsShow()
	if not M.IsActive() then
		return
	end
end


function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then	
		return Act_024_JFCDJPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetConfig()
	return config
end

function M.GetData()
	return this.m_data
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
	lister["query_new_player_lottery_base_info_response"] = M.SetData
	lister["new_player_lottery_base_info_change"] = M.SetData
	lister["get_one_common_lottery_info"] = M.SetData
    lister["OnLoginResponse"] = M.OnLoginResponse
	lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
	lister["global_hint_state_set_msg"] = M.SetHintState

	lister["AssetChange"] = M.OnAssetChange
end

function M.Init()
	M.Exit()

	this = Act_024_JFCDJManager
	this.m_data = {}
	MakeLister()
	AddLister()
end

function M.Exit()
	if M then
		RemoveLister() 
	end
end



function M.OnLoginResponse(result)
	if result == 0 then
		LotteryBaseManager.AddQuery(type_info)
	end
end

function M.OnReConnecteServerSucceed()
	
end

-- 活动的提示状态
function M.GetHintState(parm)
	local newtime = tonumber(os.date("%Y%m%d", os.time()))
	local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
	--dump("<color=yellow>------------------------</color>")
	if LotteryBaseManager.IsAwardCanGet(type_info.type) then 
		return ACTIVITY_HINT_STATUS_ENUM.AT_Get
	else
		if oldtime ~= newtime then
			return ACTIVITY_HINT_STATUS_ENUM.AT_Red
		end
	end 
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end

function M.SetHintState(parm)
	if parm.gotoui == M.key then
		PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
		Event.Brocast("global_hint_state_change_msg", parm)
	end
end


function M.CheckIsShowInActivity( )
	return M.IsActive()
end

function M.SetMyJiFen(jifen)
	this.m_data.jifen = jifen
end

function M.GetMyJiFen()
	return this.m_data.jifen
end

function M.OnAssetChange()
	--Event.Brocast("global_hint_state_change_msg", {gotoui = M.key})
end

function M.SetData(_,data)
	Event.Brocast("ui_button_data_change_msg", {key = M.key})
	Event.Brocast("global_hint_state_set_msg", {gotoui = M.key})
end