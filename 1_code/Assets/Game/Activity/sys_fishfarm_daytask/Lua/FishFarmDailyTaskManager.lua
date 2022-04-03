-- 创建时间:2020-04-16
-- FishFarmDailyTaskManager 管理器

local basefunc = require "Game/Common/basefunc"
FishFarmDailyTaskManager = {}
local M = FishFarmDailyTaskManager
M.key = "sys_fishfarm_daytask"
local config = GameButtonManager.ExtLoadLua(M.key,"fishbowl_daily_task_info_config")
GameButtonManager.ExtLoadLua(M.key,"FishFarmDailyTaskPanel")
GameButtonManager.ExtLoadLua(M.key,"FishFarmDailyTaskItemBase")
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
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow() then
        return
    end
    if parm.goto_scene_parm == "panel" then
        return FishFarmDailyTaskPanel.Create(parm.parent,parm.backcall)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if not this then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end

	if parm and parm.gotoui == M.key then 
        if M.IsCanGetAward() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
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
    lister["EnterScene"] = this.OnEnterScene
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["client_system_variant_data_change_msg"] = this.on_client_system_variant_data_change_msg
    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg
end

function M.Init()
	M.Exit()

	this = FishFarmDailyTaskManager
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
    this.UIConfig.task_id_map = {}
    this.UIConfig.config_list = {}

    local active_award_config = config.active_task_item
    for k,v in ipairs(active_award_config) do
        this.UIConfig.config_list[#this.UIConfig.config_list + 1] = v
        this.UIConfig.task_id_map[v.task_id] = v
    end

    M.SetCurTaskList()
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        -- M.QueryData()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.SetCurTaskList()
    this.UIConfig.cur_task_list = {}
    for k,v in ipairs(this.UIConfig.config_list) do
        local a,b = GameButtonManager.RunFunExt("sys_qx", "CheckCondition", nil, {_permission_key=v.key, is_on_hint = true})
        if a and b then
            this.UIConfig.cur_task_list[#this.UIConfig.cur_task_list + 1] = v
        end
    end
end

function M.QueryData(b)
    local msg_list = {}
    for k,v in ipairs(this.UIConfig.cur_task_list) do
        if not GameTaskModel.GetTaskDataByID(v.task_id) then
            msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = v.task_id}, is_close_jh = b}
        end
    end

    if #msg_list > 0 then
        dump(msg_list, "<color=red><size=15>EEE QueryData</size></color>")
        GameManager.SendMsgList(M.key, msg_list)
    else
        Event.Brocast("sys_fishfarm_daytask_task_msg_finish_msg")
    end
end
function M.on_query_send_list_fishing_msg(tag)
    if tag == M.key then
        Event.Brocast("sys_fishfarm_daytask_task_msg_finish_msg")
    end
end

function M.IsCanGetAward()
    local task
    for k,v in ipairs(this.UIConfig.cur_task_list) do
        task = M.GetTaskDataByID(v.task_id)
        if task and task.award_status == 1 then
            return true
        end
    end
    return false
end

function M.on_model_task_change_msg(data)
    if data and M.CheckIsShow() and this.UIConfig.task_id_map[data.id] then
        Event.Brocast("sys_fishfarm_daytask_task_msg_change_msg")
    end
end

function M.IsRedDailyTask()
    return false
end

function M.OnEnterScene()
end

function M.GetTaskCfgByID(task_id)
    return this.UIConfig.task_id_map[task_id]
end

function M.GetTaskDataAndSort()
    local task_list = {}
    for k,v in ipairs(this.UIConfig.cur_task_list) do
        local task = M.GetTaskDataByID(v.task_id)
        if task then
            task_list[#task_list + 1] = M.GetTaskDataByID(v.task_id)
            task_list[#task_list].ID = v.id
        else
            dump(v, "<color=red>rrrr task null </color>")
        end
    end
    local callSortGun = function(v1,v2)
        if v1.award_status == 1 and v2.award_status ~= 1 then
            return false
        elseif v1.award_status ~= 1 and v2.award_status == 1 then
            return true
        else
            if v1.award_status ~= 2 and v2.award_status == 2 then
                return false
            elseif v1.award_status == 2 and v2.award_status ~= 2 then
                return true
            else
                if v1.ID < v2.ID then
                    return false
                else
                    return true
                end
            end
        end
    end
    MathExtend.SortListCom(task_list, callSortGun)
    local ll = {}
    for k,v in ipairs(task_list) do
        ll[k] = v.id
    end
    return ll
end

function M.GetTaskConfig()
    return this.UIConfig.cur_task_list
end

function M.SetTaskState()
    local task
    this.m_data.task_state_map = {}
    for k,v in ipairs(this.UIConfig.cur_task_list) do
        task = M.GetTaskDataByID(v.task_id)
        if task then
            this.m_data.task_state_map[task.id] = {award_status = task.award_status, now_lv=task.now_lv}
        end
    end
end

function M.on_client_system_variant_data_change_msg()
end

function M.GetTaskDataByID(id)
    return GameTaskModel.GetTaskDataByID(id)
end
