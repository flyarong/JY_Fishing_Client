-- 创建时间:2020-07-21
-- Act_027_JQSHLManager 管理器

--功能修改  金秋送豪礼 -----> 冬日送豪礼
local basefunc = require "Game/Common/basefunc"
Act_027_JQSHLManager = {}
local M = Act_027_JQSHLManager
M.key = "act_027_jqshl"
GameButtonManager.ExtLoadLua(M.key,"Act_027_JQSHLPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_027_JQSHLEnterPrefab")
M.config = GameButtonManager.ExtLoadLua(M.key,"act_027_jqshl_config")

local this
local lister

-- 是否有活动
function M.IsActive(parm)
    -- 活动的开始与结束时间
    local e_time = 1635004799
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    local v=M.GetCurConfig()
    if v==nil then
        return false
    end

    local _permission_key 
    if parm and parm.condi_key then
        -- body
        _permission_key=parm.condi_key
    end
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end

    -- 对应权限的key
    -- M.CheakPerMiss()
    -- if M.Curr_Per then
    --     return true
    -- end
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm)
    return M.IsActive(parm)
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if  M.IsActive() then 
            return Act_027_JQSHLPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.IsActive() then
            return Act_027_JQSHLEnterPrefab.Create(parm.parent,parm.backcall)
        end
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.open_act_027_panel ()
    M.GotoUI({goto_scene_parm = "panel"}) 
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
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
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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

    -- lister["open_act_027_panel"] = this.open_act_027_panel

end

function M.Init()
	M.Exit()

	this = Act_027_JQSHLManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
    M.InitConfigData()

end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end
function M.InitConfigData()
    if M.cz_task_id then
        return
    end
    local config=M.GetCurConfig()
    dump(config,"<color=yellow>金秋送好礼config：  </color>")

    if config then
        --充值任务ID
        M.cz_task_id = config.cz_task_id
        M.taskid = config.taskid
        --充值权限(冬日送豪礼无)
        M.cz_permiss = config.cz_permiss
        M.ljyj_permiss = config.ljyj_permiss
    end
end
function M.GetCurConfig()
    local cur_t = os.time()
    for i,v in ipairs(M.config.other_data) do
        -- if cur_t >= v.sta_time and cur_t <= v.end_time then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condiy_key, is_on_hint = true}, "CheckCondition")
            if a and b then
                return v
            end
        -- end
    end
    return nil
end
function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        
	end
end

function M.OnReConnecteServerSucceed()
end

function M.CheakPerMiss()
    M.Curr_Per = nil
    local check_func = function(_permission_key)
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
    if check_func(M.cz_permiss) then
        print("<color=red>充值任务+++++++++++</color>")
        if check_func(M.ljyj_permiss) then
            print("<color=red>普通任务+++++++++++</color>")
            M.Curr_Per = M.ljyj_permiss
        end
    end
end

function M.GetCurrTaskID()
    --if M.Curr_Per == M.ljyj_permiss then
        M.CurrTaskID = M.taskid
        return M.taskid
   -- end
end
function M.GetCutDownEndTime()
    local config=M.GetCurConfig()
    local startTime=config.sta_time
    local cur_time=os.time()
    local end_time
    local flagIndex=1
    while true do
        end_time=startTime-60*60*8+60*60*24*20*flagIndex
        if cur_time<end_time then
            -- body
           break
        else
            flagIndex=flagIndex+1
        end  
    end
    dump(flagIndex,"flagIndex:   ")

    return end_time
end
function M.IsAwardCanGet()
    local table = {} 
    table[1] = M.GetCurrTaskID()
    table[2] = M.cz_task_id
    for i = 1,#table do
        local data = GameTaskModel.GetTaskDataByID(table[i])
        if data and data.award_status == 1 then
            return true
        end
    end
    return false
end

function M.on_model_task_change_msg( data )
    if data and (data.id == M.cz_task_id) or (data.id == M.taskid) then
        Event.Brocast("global_hint_state_change_msg",{ gotoui = M.key })
    end
end


function M.IsGetAll()
    local bool1
    local bool2
    local data1 = GameTaskModel.GetTaskDataByID(M.cz_task_id)
    if data1 then
        local b = basefunc.decode_task_award_status(data1.award_get_status)
        b = basefunc.decode_all_task_award_status2(b, data1, 5)
        if b[5] == 2 then
            bool1 = true
        end
    end
    local data2 = GameTaskModel.GetTaskDataByID(M.taskid)
    if data2 then
        local b = basefunc.decode_task_award_status(data2.award_get_status)
        b = basefunc.decode_all_task_award_status2(b, data2, 14)
        if b[14] == 2 then
            bool2 = true    
        end
    end
    if bool1 and bool2 then
        return true
    else
        return false
    end
end