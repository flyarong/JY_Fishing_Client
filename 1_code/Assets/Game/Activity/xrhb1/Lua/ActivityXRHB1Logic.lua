-- 创建时间:2018-12-12
-- 新人红包 7日活动

local basefunc = require "Game.Common.basefunc"

ActivityXRHB1Logic = {}
local M = ActivityXRHB1Logic
M.key = "xrhb1"
GameButtonManager.ExtLoadLua(M.key, "ActivityXRHB1Model")
GameButtonManager.ExtLoadLua(M.key, "XRHB1EnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ActivityXRHB1Panel")
GameButtonManager.ExtLoadLua(M.key, "ActivityXRHB1TaskPrefab")

local this -- 单例
local model
local countdown_timer = nil

function M.CheckIsShow()
    -- dump(cfg, "<color=white>新人红包任务：</color>")
    -- dump(ActivityXRHB1Model.IsOver(), "<color=white>新人红包权限</color>")
   -- dump(os.time() > ActivityXRHB1Model.data.over_time, "<color=white>新人红包权限时间？？？</color>")
    if ActivityXRHB1Model.IsOver() then
        return
    end
    
    if os.time() > ActivityXRHB1Model.data.over_time then
        return
    end

    return true
end
function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return ActivityXRHB1Panel.Create(parm.parent, parm.backcall)
	elseif parm.goto_scene_parm == "enter" then
        return XRHB1EnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local lister
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
    -- lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["open_activity_seven_day"] = this.open_activity_seven_day
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["global_hint_state_change_msg"] = this.on_global_hint_state_change_msg
end

function ActivityXRHB1Logic.Init()
    print("<color=red>初始化新人红包系统</color>")
    ActivityXRHB1Logic.Exit()
    this = ActivityXRHB1Logic
    MakeLister()
    AddLister()
    return this
end
function ActivityXRHB1Logic.Exit()
	if this then
		if model then
			model.Exit()
		end
		model = nil
		RemoveLister()
		this = nil
	end
end

--正常登录成功
function ActivityXRHB1Logic.OnLoginResponse(result)
    if result==0 then
    	if model then
    		model.Exit()
    	end
    	model = ActivityXRHB1Model.Init()
    end
end

--正常登录成功
function ActivityXRHB1Logic.open_activity_seven_day(forceShow)
	ActivityXRHB1Model.forceShow = forceShow
	ActivityXRHB1Panel.Create()
end

-- 活动的提示状态
function M.GetHintState()
    if ActivityXRHB1Model.CanGetStatus then
		return ACTIVITY_HINT_STATUS_ENUM.AT_Red
	end
    return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end

function M.SetHintState()
    ActivityXRHB1Model.CheckTaskCanGet()
end

function M.on_global_hint_state_set_msg(parm)
    if parm.gotoui ~= M.key then return end
    M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", parm)
end

function M.on_global_hint_state_change_msg(parm)
    if parm.gotoui ~= M.key then return end
    M.SetHintState()
    Event.Brocast("module_global_hint_state_change_msg",parm)
end

function M.GetExtTaskToID(parm)
    return ActivityXRHB1Model.GetTaskToID(parm.id)
end
