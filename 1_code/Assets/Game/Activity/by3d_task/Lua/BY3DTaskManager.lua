-- 创建时间:2020-07-15
-- BY3DTaskManager 管理器
-- 3D挑战任务

local basefunc = require "Game/Common/basefunc"
BY3DTaskManager = {}
local M = BY3DTaskManager
M.key = "by3d_task"
GameButtonManager.ExtLoadLua(M.key, "Fishing3DTZTaskPrefab")
local config = GameButtonManager.ExtLoadLua(M.key, "fish3d_task_config")

local this
local lister

BY3DTaskManager.GameType = {
    GT_3D = "3d",
    GT_JJ = "jj",
}
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if not this.m_data.tz_task_id then
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
    if parm.goto_scene_parm == "enter" then
        return Fishing3DTZTaskPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "bytop_area" then
        return Fishing3DTZTaskPrefab.Create(parm.parent, M.GameType.GT_JJ)
    elseif parm.goto_scene_parm == "bytop_area1" then
        return Fishing3DTZTaskPrefab.Create(parm.parent, M.GameType.GT_JJ)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if this.m_data.children_task_map and this.m_data.tz_task_id and this.m_data.children_task_map[this.m_data.tz_task_id] then
        local award_status = this.m_data.children_task_map[this.m_data.tz_task_id].award_status
        if award_status == 1 then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        end
    end

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

    lister["ExitScene"] = this.OnExitScene
    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["query_fish_daily_children_tasks_response"] = this.on_query_fish_daily_children_tasks
    lister["fish_daily_children_tasks_change_msg"] = this.on_fish_daily_children_tasks_change_msg

    lister["ui_appearTZ_task_msg"] = this.ui_appearTZ_task_msg
end

function M.Init()
	M.Exit()

	this = BY3DTaskManager
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
    this.UIConfig.game_task_map = {}
    this.UIConfig.game_task_map[2] = 1
    this.UIConfig.game_task_map[3] = 1
    this.UIConfig.game_task_map[4] = 1
    this.UIConfig.game_task_map[5] = 1

    this.UIConfig.fish_task_map = {}
    for k,v in ipairs(config.Sheet1) do
        this.UIConfig.fish_task_map[v.id] = v
    end

    -- 街机捕鱼
    this.UIConfig.jj_game_task_map = {}
    this.UIConfig.jj_game_task_map[1] = 1
    this.UIConfig.jj_game_task_map[2] = 1
    this.UIConfig.jj_game_task_map[3] = 1

    this.UIConfig.jj_fish_task_map = {}
    for k,v in ipairs(config.config) do
        this.UIConfig.jj_fish_task_map[v.id] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()
end

function M.OnExitScene()
    this.m_data = {}
end

function M.UpdateData()
    if MainModel.myLocation == "game_Fishing3D" then
        Network.SendRequest("query_fish_daily_children_tasks", {fish_game_id=FishingModel.game_id, game_type=2})
    else
        Network.SendRequest("query_fish_daily_children_tasks", {fish_game_id=FishingModel.game_id, game_type=1})
    end
end

function M.CheckTZTask()
    if M.IsGameingAndExistTask() then        
        Event.Brocast("ui_button_state_change_msg")
    end
end

-- 是否在游戏并且当前场次存在任务
function M.IsGameingAndExistTask()
    if MainModel.myLocation == "game_Fishing3D" and FishingModel and this.UIConfig.game_task_map[FishingModel.game_id] then
        return true
    end
    if MainModel.myLocation == "game_Fishing" and FishingModel and this.UIConfig.jj_game_task_map[FishingModel.game_id] then
        return true
    end
end

function M.on_model_task_change_msg(data)
    if this.m_data.children_task_map and this.m_data.children_task_map[data.id] then
        local award_status = this.m_data.children_task_map[data.id].award_status
        this.m_data.children_task_map[data.id] = data
        if award_status ~= data.award_status then
            if data.award_status == 1 then
                Event.Brocast("by3d_task_children_task_finish_msg", {task_id=data.id})-- 任务完成
            end
            Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
        end
        Event.Brocast("by3d_task_children_task_change_msg")-- 任务进度改变
    end
end

function M.on_fishing_ready_finish()
    this.m_data = {}
    if M.IsGameingAndExistTask() then
        M.UpdateData()
    end
end

function M.on_query_fish_daily_children_tasks(_, data)
    if M.IsGameingAndExistTask() then
        dump(data, "<color=red>on_query_fish_daily_children_tasks</color>")
        if data.result == 0 then
            this.m_data.children_task_map = {}
            this.m_data.tz_task_id = nil
            for k,v in ipairs(data.children_tasks) do
                this.m_data.children_task_map[v.id] = v
                this.m_data.tz_task_id = v.id
            end
            M.CheckTZTask()
        end
    end
end

function M.on_fish_daily_children_tasks_change_msg(_, data)
    dump(data, "<color=red>on_fish_daily_children_tasks_change_msg</color>")
    if M.IsGameingAndExistTask() and FishingModel.game_id == data.fish_game_id then
        this.m_data.children_task_map = {}
        this.m_data.tz_task_id = nil
        for k,v in ipairs(data.children_tasks) do
            this.m_data.children_task_map[v.id] = v
            this.m_data.tz_task_id = v.id
        end

        if this.m_data.tz_task_id then -- 发生在鱼死亡产出挑战任务
            if this.m_data.get_parm then -- 无法知道任务改变消息与鱼死亡消息的顺序，又要添加从鱼身上飞出挑战任务的效果，目前这里只有挑战任务
                M.CheckTZTask()
            end
        else
            M.CheckTZTask()
        end
    end
end

function M.ui_appearTZ_task_msg(parm)
    if M.IsGameingAndExistTask() and parm.seat_num == 1 then
        this.m_data.get_parm = parm
        M.CheckTZTask()
    end
end
function M.GetTZTaskData()
    return this.m_data.children_task_map[M.GetTZTaskID()]
end
function M.GetTZTaskID()
    return this.m_data.tz_task_id
end

function M.GetTaskConfigByID(task_id)
    if this.UIConfig.fish_task_map[task_id] then
        return this.UIConfig.fish_task_map[task_id]
    else
        return this.UIConfig.jj_fish_task_map[task_id]
    end
end