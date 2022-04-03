-- 创建时间:2020-01-15
-- XRQTLManager_Old 管理器

local basefunc = require "Game/Common/basefunc"
XRQTLManager_Old = {}
local M = XRQTLManager_Old
M.key = "act_xrqtl_old"
XRQTLManager_Old.config = GameButtonManager.ExtLoadLua(M.key, "activity_xrqtl_config")
GameButtonManager.ExtLoadLua(M.key, "XRQTLEnterPrefab_Old")
GameButtonManager.ExtLoadLua(M.key, "XRQTLPanel_Old")
local this
local lister
local task_ids = {}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    if MainModel.UserInfo.ui_config_id == 1 then return end 
    local e_time
    local s_time = 1581982200
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end
    if MainModel.FirstLoginTime() <= s_time or M.GetDayIndex() > 7 then
        return false
    end

    -- 对应权限的key
    local _permission_key = "drt_block_new_player_happy_seven_day"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and b then
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
        return XRQTLPanel_Old.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return XRQTLEnterPrefab_Old.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsAwardCanGet() then
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
        PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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

    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["get_task_award_response"] = this.on_get_task_award_response

    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg
end

function M.Init()
	M.Exit()

	this = XRQTLManager_Old
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
    this.UIConfig.task_map = {}
    this.UIConfig.task_list = {}
    for k,v in ipairs(XRQTLManager_Old.config.Info) do
        this.UIConfig.task_map[v.task_id] = v
        this.UIConfig.task_list[#this.UIConfig.task_list + 1] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        M.QueryData()
	end
end
function M.OnReConnecteServerSucceed()

end

function M.QueryData(b)
    local msg_list = {}
    for k,v in ipairs(this.UIConfig.task_list) do
        local task = GameTaskModel.GetTaskDataByID(v.task_id)
        if not task then
            msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = v.task_id}, is_close_jh = b}
        end
    end
    if #msg_list > 0 then
        if b then
            dump(msg_list, "<color=red>XRQTL EEE QueryData</color>")
        end
        GameManager.SendMsgList(M.key, msg_list)
    else
        Event.Brocast("act_xrqtl_query_model_msg")
    end
end

--从零开始
function M.GetDayIndex()
    local first_login_time = MainModel.FirstLoginTime()
    local t1 = basefunc.get_today_id(first_login_time)
    local t2 = basefunc.get_today_id(os.time())
    if (t2 - t1) < 0 then
        return 1
    else
        return t2 - t1 + 1
    end
end

function M.on_query_send_list_fishing_msg(tag)
    if tag == M.key then
        Event.Brocast("act_xrqtl_query_model_msg")
    end
end

function M.on_model_task_change_msg(data)
    if data.id and M.IsCareTask(data.id) then 
        Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
        Event.Brocast("XRQTL_DownCount_msg")
    end
end

function M.IsCareTask(task_id)
    if this.UIConfig.task_map[task_id] then
        return true
    end
    return false
end

function M.IsAwardCanGet()
    local task_data = M.GetCurrTaskData()
    if task_data and task_data.award_status == 1 then 
        return true
    end
    return false
end

function M.GetCurrTaskData()
    local day = M.GetDayIndex()
    if day <= #this.UIConfig.task_list then
        return M.GetTaskDataByDay(day)
    end
end

function M.GetTaskDataByDay(index)
    return GameTaskModel.GetTaskDataByID(this.UIConfig.task_list[index].task_id)
end

function M.on_get_task_award_response(_,data)
    if data and data.result == 0 then
        if M.IsCareTask(data.id) then
            local d = os.date("%Y/%m/%d", os.time())
            local strs = {}
            string.gsub(d, "[^-/]+", function(s)
                strs[#strs + 1] = s
            end)
            local et = os.time({year = strs[1], month = strs[2], day = strs[3], hour = "23", min = "59", sec = "59"})
            et = et + 1
            if data.id == 21145 then
                PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."XRQTL",0)
            else
                PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."XRQTL",et)
            end
            Event.Brocast("XRQTL_DownCount_msg")
            Event.Brocast("XRQTL_BX_Show_msg")     
        end
    end
end
