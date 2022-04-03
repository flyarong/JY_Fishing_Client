-- 创建时间:2020-08-12
-- Act_026_XRCDJManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_026_XRCDJManager = {}
local M = Act_026_XRCDJManager
M.key = "act_026_xrcdj"
GameButtonManager.ExtLoadLua(M.key, "Act_026_XRCDJPanel")
GameButtonManager.ExtLoadLua(M.key, "ActXRCDJCJCellPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_026_XRCDJEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_026_XRCDJ_CJPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_026_XRCDJ_DHHFPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_026_XRCDJ_TagPrefab")
local config = GameButtonManager.ExtLoadLua(M.key, "act_026_xrcdj_config")

local this
local lister

-- 是否有活动
function M.IsActive()
    if MainModel.UserInfo.ui_config_id == 1 then return end 
    local e_time
    local s_time = 1597809000 -- 2020/8/19 11:50:0
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if M.IsFinishAllTask() then
        return false
    end

    -- 对应权限的key
    local _permission_key = "cpl_xrcdj"
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
        return Act_026_XRCDJPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return Act_026_XRCDJEnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsCanGetAwardByTag() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["box_exchange_response"] = this.on_box_exchange_response
    lister["model_task_change_msg"] = this.on_model_task_change_msg

    lister["query_login_day_data_response"] = this.on_query_login_day_data_response
end

function M.Init()
	M.Exit()

	this = Act_026_XRCDJManager
	this.m_data = {}
    this.m_data.login_day = 1

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

    this.UIConfig.tag_list = {}
    this.UIConfig.tag_map = {}
    this.UIConfig.award_map = {}
    for k,v in ipairs(config.config) do
        v.id = v.line
        this.UIConfig.tag_list[#this.UIConfig.tag_list + 1] = v
        this.UIConfig.tag_map[v.id] = v
        if v.award then
            this.UIConfig.award_map[v.award] = config[v.award]
        end
    end

    this.UIConfig.task_map = {}
    for k,v in ipairs(config.task_content) do
        this.UIConfig.task_map[v.id] = v
    end

    this.UIConfig.ew_tasks = {1000014, 1000015, 1000016, 1000017}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.QueryData()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryData()
    if this.m_data.login_day_result == 0 then
        Event.Brocast("act_026_xrcdj_query_finish_msg")
    else
        Network.SendRequest("query_login_day_data")
    end
end

function M.on_query_login_day_data_response(_, data)
    dump(data, "<color=red>on_query_login_day_data_response </color>")
    this.m_data.login_day_result = data.result
    if data.result == 0 then
        this.m_data.login_day = data.day
        Event.Brocast("act_026_xrcdj_query_finish_msg")
    end
end

function M.on_box_exchange_response(_, data)
    dump(data, "<color=red>on_box_exchange_response </color>")
    if data.result == 0 then
        Event.Brocast("act_026_xrcdj_box_exchange_msg", { award_id = data.award_id[1] })
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_model_task_change_msg(data)
    if this.UIConfig.task_map[data.id] then
        Event.Brocast("act_026_xrcdj_task_change_msg")
    end
end

-- 获取奖励列表
function M.GetAwardListByKey(kk)
    return this.UIConfig.award_map[kk]
end

function M.GetTagList()
    local list = {}
    for k,v in ipairs(this.UIConfig.tag_list) do
        list[#list + 1] = basefunc.copy(v)
        list[#list].is_finish = M.IsFinishAllTask(v.id)
    end
    MathExtend.SortListCom(list, function (v1, v2)
        if not v1.is_finish and v2.is_finish then
            return false
        elseif v1.is_finish and not v2.is_finish then
            return true
        else
            if v1.id > v2.id then
                return true
            else
                return false
            end
        end
    end)
    return list
end

function M.GetTagConfigByIndex(index)
    return this.UIConfig.tag_list[index]
end
-- 任务配置
function M.GetTaskConfig(id)
    return this.UIConfig.task_map[id]
end

-- 是否可以领取10元话费
function M.IsCanLQHF()
    local task_data = GameTaskModel.GetTaskDataByID( 1000017 )
    if task_data and task_data.award_status == 1 then
        return true
    end
    return false
end

-- 是否解锁
function M.IsUnlock(tag)
    if tag == 1 then
        return true
    end

    local a,vip = GameButtonManager.RunFunExt("vip", "get_vip_level")
    if a and vip then
        if tag == 2 and (this.m_data.login_day >= 2 or vip >= 1) then
            return true
        elseif tag == 3 and (this.m_data.login_day >= 5 or vip >= 1) then
            return true
        end        
    end
    return false
end
-- 获取可以抽奖的次数
function M.GetCanCJNum(tag)
    return 0
end
-- 获取完成抽奖的进度
function M.GetFinishCJJD(tag)
    local task_data = GameTaskModel.GetTaskDataByID( this.UIConfig.ew_tasks[tag] )
    if task_data then
        return {task_data.now_process, task_data.need_process}
    end
    return {0,1}
end
-- 获取当前进行中的任务ID
function M.GetTaskIDByTag(tag)
    local cfg = this.UIConfig.tag_map[tag]
    local _task_id = cfg.task_id[1]
    for i=#cfg.task_id, 1, -1 do
        local task_data = GameTaskModel.GetTaskDataByID( cfg.task_id[i] )
        if task_data and task_data.other_data_str then
            _task_id = cfg.task_id[i]
            break
        end
    end
    dump(_task_id, "<color=red>_task_id</color>")
    return _task_id
end
function M.GetTaskDataByTag(tag)
    local task_id = M.GetTaskIDByTag(tag)
    if task_id then
        return GameTaskModel.GetTaskDataByID( task_id )
    end
end

function M.GetSYTime()
    local f_t = tonumber(MainModel.UserInfo.first_login_time) 
    if not f_t then return 0 end
    return f_t + 7 * 24 * 3600 - MainModel.GetCurTime()
end

function M.GetLJDay()
    if this.m_data.login_day then
        return this.m_data.login_day
    end
    return 1
end

function M.GetLJXYDay(tag)
    if tag == 2 then
        return 2
    elseif tag == 3 then
        return 5
    else
        return 666
    end
end

function M.GetEndTaskIDByTag(tag)
    local cfg = this.UIConfig.tag_map[tag]
    return cfg.task_id[#cfg.task_id]
end

function M.GetDHHFTaskID()
    return this.UIConfig.ew_tasks[#this.UIConfig.ew_tasks]
end
-- 能否领奖
function M.IsCanGetAwardByTag(tag)
    if not tag then
        for i = 1, 4 do
            local b = M.IsCanGetAwardByTag(i)
            if b then
                return b
            end
        end
        return false
    else
        if tag == 4 then
            return M.IsCanLQHF()
        else
            local cfg = M.GetTagConfigByIndex(tag)
            local cj_num = GameItemModel.GetItemCount(cfg.item_key)
            if M.IsUnlock(tag) and cj_num > 0 then
                return true
            end
            return false
        end
    end
end

-- 是否完成所有任务
function M.IsFinishAllTask(tag)
    if not tag then
        for i = 1, 4 do
            local b = M.IsFinishAllTask(i)
            if not b then
                return false
            end
        end
        return true
    else
        if tag < 4 then
            local task_data = M.GetTaskDataByTag(tag)
            if task_data then
                local cfg = M.GetTagConfigByIndex(tag)
                local cj_num = GameItemModel.GetItemCount(cfg.item_key)
                if task_data.award_status == 2 and task_data.id == M.GetEndTaskIDByTag(tag) and cj_num == 0 then
                    return true
                end
            end
            return false
        else
            local task_data = GameTaskModel.GetTaskDataByID( 1000017 )
            if task_data and task_data.award_status ~= 2 then
                return false
            end
            return true
        end
    end
end