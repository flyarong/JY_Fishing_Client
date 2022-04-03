-- 创建时间:2021-01-18
-- Act_048_XNSMTManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_048_XNSMTManager = {}
local M = Act_048_XNSMTManager
M.key = "act_048_xnsmt"
local config = GameButtonManager.ExtLoadLua(M.key, "act_048_xnsmt_config")
GameButtonManager.ExtLoadLua(M.key,"Act_048_XNSMTEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_048_XNSMTPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_048_XNSMTFAQPanel")

local this
local lister

M.item_key = "prop_xnsmt_mtsp" --茅台碎片
M.lottery_item_key = "prop_xnsmt_cjq" --抽奖券
M.collect_task_id = 1000281
M.box_exchange_id = 74
M.fx_task_id = 1000280

M.help_info = 
{
    "1.活动期间，完成任务可获得茅台抽奖券，有机会获得飞天茅台",
    "2.为避免恶意刷量，被邀请的玩家中，有效玩家占比不得低于50%，否则视为有刷量嫌疑，在游戏中成功进行一次兑出且游戏行为正常视为有效",
    "3.严禁进行刷量行为，一经发现，不予发放任何奖励",
    "4.本公司保留在法律规定范 围内对上述规则解释的权利",
}

M.end_time = 1613404799

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1613404799
    local s_time = 1612827000
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

    if parm.goto_scene_parm == "enter" then
        return Act_048_XNSMTEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return Act_048_XNSMTPanel.Create(parm.parent)
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
    lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["query_everyday_shared_award_response"] = this.on_query_everyday_shared_award_response

    lister["AssetChange"] = this.on_AssetChange
end

function M.Init()
	M.Exit()

	this = Act_048_XNSMTManager
    this.m_data = {}
    if M.CheckIsCJJ() then
        this.m_data.tasks_cfg = config.tasks_cjj
    else
        this.m_data.tasks_cfg = config.tasks
    end
    this.m_data.lottery_rewards_cfg = config.lottery_rewards
    
    this.m_data.collect_rewards_cfg = config.collect_rewards

    this.m_data.tasks_data = {} --key:task_id

    this.m_data.is_share_award = false
	MakeLister()
    AddLister()
    M.InitUIConfig()
    
    M.QueryCollectTaskData()
    M.QueryTaskData()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    M.CheckBoxExchangeId()
    if M.CheckIsCJJ() then
        M.answer_type = "answer_2021_2_9_cjj"
    else
        M.answer_type = "answer_2021_2_9"
    end
    local config_q = {}
    for i=1,#config.questions do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = config.questions[i].condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            config_q[#config_q + 1] = config.questions[i]
        end
    end 
    this.m_data.questions_cfg = config_q
end

function M.UpdateCollectTaskData(_data)
    this.m_data.collect_task_data = {}
    this.m_data.collect_task_data.now_total_process = _data.now_total_process
    local b = basefunc.decode_task_award_status(_data.award_get_status)
    b = basefunc.decode_all_task_award_status(b, _data, 5)
    this.m_data.collect_task_data.get_state = b
    -- local now_level = 1
    -- for i = #this.m_data.collect_rewards_cfg ,1, -1 do
    --     if this.m_data.collect_task_data.now_total_process >= this.m_data.collect_rewards_cfg[i].collect_num then
    --         now_level = i
    --         break
    --     end
    -- end
    -- this.m_data.collect_task_data.now_level = now_level
    this.m_data.collect_task_data.need_process = _data.need_process
    this.m_data.collect_task_data.now_process = _data.now_process
    this.m_data.collect_task_data.now_lv = _data.now_lv
end

function M.UpdateTaskData(_data)
    this.m_data.tasks_data[_data.id] = _data
end

function M.GetTaskCfg()
    return this.m_data.tasks_cfg
end

function M.GetLotteryRdCfg()
    return this.m_data.lottery_rewards_cfg
end

function M.GetQuestionCfg()
    return this.m_data.questions_cfg
end

function M.GetCollectRdCfg()
    return this.m_data.collect_rewards_cfg
end

function M.GetCollectTaskData()
    return this.m_data.collect_task_data
end

function M.GetTaskData()
    local task_tab = {}
    local cfg = this.m_data.tasks_cfg
    local data = this.m_data.tasks_data
    if table_is_null(data) then return end
    for i = 1,#cfg do
        task_tab[i] = {}
        local task_data = data[cfg[i].task_id]
        if table_is_null(task_data) then return end
        local b = basefunc.decode_task_award_status(task_data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, task_data, 6)
        if not cfg[i].level then
            task_tab[i].state = task_data.award_status
        else
            local my_level = cfg[i].level
            task_tab[i].state = b[my_level]
        end
        task_tab[i].now_total_process = task_data.now_total_process
        task_tab[i].need_process = task_data.need_process
    end
    --dump(task_tab,"<color=red>TTTTTTTTTTTTTTTTTTTTTT</color>")
    return task_tab
    --return this.m_data.tasks_data
end

function M.GetAwardIndex(_award_id)
    for i = 1, #this.m_data.lottery_rewards_cfg do
        for j = 1, #this.m_data.lottery_rewards_cfg[i].award_id do
            if this.m_data.lottery_rewards_cfg[i].award_id[j] == _award_id then
                return i - 1
            end
        end
    end
end

function M.GetItemCount()
    return MainModel.GetItemCount(M.item_key)
end


function M.IsContainTask(task_id)
    for i = 1, #this.m_data.tasks_cfg do
        if this.m_data.tasks_cfg[i].task_id == task_id then
            return true
        end
    end
    return false
end


function M.IsHint()
    if MainModel.GetItemCount(M.lottery_item_key) >= 3 then
        return true
    end

    if GameTaskModel.GetTaskDataByID(M.fx_task_id) and GameTaskModel.GetTaskDataByID(M.fx_task_id).award_status and GameTaskModel.GetTaskDataByID(M.fx_task_id).award_status ~= 2 then
        return true
    end

    local data = M.GetCollectTaskData()
    if data then 
        for k,v in pairs(data.get_state) do
            if v == 1 then
                return true
            end
        end
    end

    if M.CheckTaskCanGet() then
        return true
    end

    return false
end

function M.QueryCollectTaskData()
    Network.SendRequest("query_one_task_data", { task_id = M.collect_task_id })
end

function M.QueryTaskData()
    local task_id_lis = {}
    local cur_task_id
    for i = 1, #this.m_data.tasks_cfg do
        local _cfg = this.m_data.tasks_cfg[i]
        if cur_task_id ~= _cfg.task_id then
            Network.SendRequest("query_one_task_data", { task_id = _cfg.task_id })
            cur_task_id = _cfg.task_id
        end 
    end
end

function M.on_model_query_one_task_data_response(data)
    --dump(data,"<color=white>+++++++on_model_query_one_task_data_response+++++++</color>")
    if data then
        M.HandleTaskData(data)
    end
end

function M.on_model_task_change_msg(data)
    --dump(data,"<color=white>+++++++on_model_task_change_msg+++++++</color>")
    if data then
        M.HandleTaskData(data)
    end
end

function M.HandleTaskData(data)
    if data.id == M.collect_task_id then
        M.UpdateCollectTaskData(data)
        Event.Brocast("model_xnsmt_collect_refresh")
    end

    if M.IsContainTask(data.id) then
        M.UpdateTaskData(data)
        Event.Brocast("model_xnsmt_task_refresh")
    end

    if data.id == M.fx_task_id then
        Event.Brocast("model_xnsmt_share_refresh")
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()

end

--判断是否是cjj
function M.CheckIsCJJ()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
    if a and b then
        return true
    else
        return false
    end
end


function M.on_AssetChange()
    M.CheckBoxExchangeId()
end

function M.CheckBoxExchangeId()
    if M.GetItemCount() < 600 then
        M.box_exchange_id = 74
    elseif M.GetItemCount() >= 600 and M.GetItemCount() < 900 then
        M.box_exchange_id = 75
    elseif M.GetItemCount() > 900 then
        M.box_exchange_id = 76
    end
end

function M.CheckTaskCanGet()
    local tab = M.GetTaskData()
    if table_is_null(tab) then return false end
    for k,v in pairs(tab) do
        if v.state == 1 then
            return true
        end
    end
    return false
end