-- 创建时间:2021-03-12
-- Act_055_XHNSManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_055_XHNSManager = {}
local M = Act_055_XHNSManager
M.key = "act_055_xhns"
local config = GameButtonManager.ExtLoadLua(M.key,"Act_055_xhns_config")
GameButtonManager.ExtLoadLua(M.key,"Act_055_XHNSPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_055_XHNSItem")

local this
local lister
--add_task_progress "105784",21728,200000

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local startTime=this.m_data.otherInfo.startTime
    local endTime=this.m_data.otherInfo.endTime
    if (endTime and os.time() > endTime) or (startTime and os.time() < startTime) then
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
    if parm.goto_scene_parm == "panel" then
        return Act_055_XHNSPanel.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsHint() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
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
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
end

function M.Init()
	M.Exit()

	this = Act_055_XHNSManager
	this.m_data = {}
    this.m_data.task_data = {}
	MakeLister()
    AddLister()
	M.InitConfig()
    M.SetTaskData()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitConfig()
    for k,v in pairs(config.otherInfo) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            this.m_data.otherInfo = v
            break
        end
    end

    this.m_data.task_cfg = {}
    for k,v in pairs(this.m_data.otherInfo.award) do
        this.m_data.task_cfg[#this.m_data.task_cfg + 1] = config.awardInfo[v]
    end
    M.m_task_id = this.m_data.otherInfo.task_id
end
----模板{按钮}参数
function M.GetGotoUIStr()
    return this.m_data.otherInfo.gotoui
end
----模板{底边描述}参数
function M.GetDowDesc()
    return this.m_data.otherInfo.downDes
end
function M.GetActEndTime()
    return this.m_data.otherInfo.endTime
end
function M.GetConfig()
    return this.m_data.task_cfg
end

local function SetData(_award_status, _now_total_process, _need_process)
	this.m_data.task_data.award_status = _award_status
	this.m_data.task_data.now_total_process = math.floor(_now_total_process / 100000)
	this.m_data.task_data.need_processte = math.floor(_need_process / 100000)
end

function M.SetTaskData()
	local _cur_task_data = GameTaskModel.GetTaskDataByID(M.m_task_id)
    dump(_cur_task_data,"<color=white>TTTTTTTTTTTTT0000TTTTTTTTTTTTTTTTTaskData</color>")

	if _cur_task_data then
		local b = basefunc.decode_task_award_status(_cur_task_data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, _cur_task_data, #this.m_data.task_cfg)
		SetData(b, _cur_task_data.now_total_process, _cur_task_data.need_process)
	else
		local status = {}
		for i = 1, #this.m_data.task_cfg do
			status[i] = 0
		end
		SetData(status, 0, 0)
	end
    dump(this.m_data.task_data,"<color=white>TTTTTTTTTTT1111TTTTTTTTTTTTTTTTTTTaskData</color>")
    Event.Brocast("model_xcns_task_refresh")
    M.SetHintState()
end
function M.GetTaskData()
    return this.m_data.task_data
end

function M.IsHint()
    for i = 1, #this.m_data.task_data.award_status do
        if this.m_data.task_data.award_status[i] == 1 then
            return true
        end
    end
end

function M.GetTaskLv()

    if this.m_data.task_data.now_total_process >= this.m_data.task_cfg[#this.m_data.task_cfg].need_num then
        return #this.m_data.task_cfg
    end

    for i = 1, #this.m_data.task_cfg do
        if this.m_data.task_data.now_total_process < this.m_data.task_cfg[i].need_num then
            return i
        end
    end
    return 
end

function M.on_model_task_change_msg(data)
    -- dump(data,"<color=white>+++++++on_model_task_change_msg+++++++</color>")
    if data and data.id == M.m_task_id then
        M.SetTaskData()
    end
end

function M.on_model_query_task_data_response()
    local data = GameTaskModel.GetTaskDataByID()
    dump(data,"<color=red>+++++on_model_query_task_data_response+++++</color>")
    if data then
        for k,v in pairs(data) do
            if v.id == M.m_task_id then
                M.SetTaskData()
            end
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()

end