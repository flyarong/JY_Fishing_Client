local basefunc = require "Game/Common/basefunc"
Act_ty_LDFDManager = {}
local M = Act_ty_LDFDManager
M.key = "act_ty_ldfd"
GameButtonManager.ExtLoadLua(M.key,"Act_ty_LDFDFDItem")
GameButtonManager.ExtLoadLua(M.key,"Act_ty_LDFDPanel")
M.configs = GameButtonManager.ExtLoadLua(M.key,"act_ty_ldfd_config")
local this
local lister

--M.permission_key = "actp_own_task_p_031_gqfd_cumulative"
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local index = M.GetCurIndex()
    if not index then
        return false
    end
    if not this.UIConfig.info_map.show_condiy_key or not this.UIConfig.info_map.show_condiy_key[index] then
        return true
    end

    local condi_key = this.UIConfig.info_map.show_condiy_key[index]
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=condi_key, is_on_hint = true}, "CheckCondition")
    if a and b then
        return true
    end
    return false
end
function M.GetCurIndex()
    local len = #this.UIConfig.info_map.endTime
    local cur_t = os.time()
    for i = 1, len do
        local e_time = this.UIConfig.info_map.endTime[i]
        local s_time = this.UIConfig.info_map.beginTime[i]
        local condi_key = this.UIConfig.info_map.show_condiy_key[i]
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = condi_key, is_on_hint = true}, "CheckCondition")
        if CheckTimeInRange(cur_t, s_time, e_time) and a and b then
            M.GetCurTime(s_time,e_time)
            return i
        end
    end
end

function M.GetCurData()
    local index = M.GetCurIndex()
    if not index then
        print("<color=red>FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF</color>")
        return
    end
    local group_id = this.UIConfig.info_map.group_id[index]
    local list = this.UIConfig.gifts_map[group_id]
    for k,v in ipairs(list) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            return v
        end
    end
    print("<color=red>FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF</color>")
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
    if not M.IsActive() then
        return
    end
    dump({parm,M.cfg}, "<color=red>立冬福袋</color>")
    if parm.goto_scene_parm == "panel" then
        return Act_ty_LDFDPanel.Create(parm.parent)
	end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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

    lister["model_query_one_task_data_response"] = this.model_query_one_task_data_response
    lister["model_task_change_msg"] = this.model_task_change_msg
    lister["finish_gift_shop"] = this.finish_gift_shop
    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
end

function M.Init()
	M.Exit()

	this = Act_ty_LDFDManager
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
-- function M.GetCurInfo()
--     local cur_t = os.time()
--     for i,v in ipairs(M.configs.info) do
--         if cur_t >= M.configs.info.beginTime and cur_t <=M.configs.info.endTime then
--             if not v.condiy_key then
--                 return v
--             end
--             local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condiy_key, is_on_hint = true}, "CheckCondition")
--             if a and b then
--                 return v
--             end
--         end
--     end
-- end


function M.InitUIConfig()
    this.UIConfig = {}

    
    --local info_cfg = M.GetCurInfo()
    
    this.UIConfig.info_map = {}
    for k,v in ipairs(M.configs.info) do
        if type(v.value) == "table" then
            this.UIConfig.info_map[v.key] = v.value
        else
            this.UIConfig.info_map[v.key] = {v.value}
        end
    end

    this.UIConfig.gifts_map = {}
    for i,v in ipairs(M.configs.gifts) do
		this.UIConfig.gifts_map[v.group_id] = this.UIConfig.gifts_map[v.group_id] or {}
        this.UIConfig.gifts_map[v.group_id][#this.UIConfig.gifts_map[v.group_id] + 1] = v
    end

    local data = M.GetCurData()
    if not data then
        dump(data, "<color=red>数据不对</color>")
        return
    end
    M.task_id = data.task_id
    M.gift_ids = data.gift_ids
    M.gift_id_hash = {}
    for i,v in ipairs(data.gift_ids) do
        M.gift_id_hash[v] = v
    end
    Network.SendRequest("query_one_task_data", {task_id = M.task_id})

end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        -- Network.SendRequest("query_one_task_data", {task_id = M.task_id})
	end
end
function M.OnReConnecteServerSucceed()
end

function M.ActivityTaskPanel_Exit()
    Act_ty_LDFDPanel.Close()
end

function M.Refresh_Status()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

function M.model_query_one_task_data_response(task_data)
    if task_data.id ~= M.task_id then return end
    M.task_data = GameTaskModel.GetTaskDataByID(task_data.id)

    M.all_task_key = M.GetAllGetTaskCount()

    Event.Brocast("act_ty_ldfd_refresh")
end

function M.model_task_change_msg(task_data)
    if task_data.id ~= M.task_id then return end
    M.task_data = GameTaskModel.GetTaskDataByID(task_data.id)
    local status = M.GetAllTaskAwardStatus()

    Event.Brocast("act_ty_ldfd_refresh", (M.all_task_key ~= M.GetAllGetTaskCount()))
    M.all_task_key = M.GetAllGetTaskCount()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
    M.SetHintState()
end

function M.finish_gift_shop(gift_id)
    if not M.gift_id_hash or not M.gift_id_hash[gift_id] then return end
    Event.Brocast("act_ty_ldfd_refresh_gift", gift_id)
end

function M.IsAwardCanGet()
    local all_task_award_status = M.GetAllTaskAwardStatus()
    if table_is_null(all_task_award_status) then return end
    for i,v in ipairs(all_task_award_status) do
        if v == 1 then
            return true
        end
    end
    return false
end

function M.GetTaskData()
    M.task_data = GameTaskModel.GetTaskDataByID(M.task_id)
    if table_is_null(M.task_data) then 
        Network.SendRequest("query_one_task_data", {task_id = M.task_id})
    end
    return M.task_data
end

function M.GetCurTime(s_time,e_time)
    if s_time and e_time then
        this.UIConfig.stime=s_time
        this.UIConfig.etime=e_time
    else
        return this.UIConfig
    end
end

function M.GetAllTaskAwardStatus()
    local atas = M.GetAllTaskAwardStatus_1(M.task_id,#M.gift_ids)
     return atas
end

-- 领取的任务个数
function M.GetAllGetTaskCount()
    local atas = M.GetAllTaskAwardStatus()
    local num = 0
    for k,v in ipairs(atas) do
        if v == 2 then
            num = num + 1
        end
    end
    return num
end

function M.GetAllTaskAwardStatus_1(task_id,count)
   if not task_id or not count then return end 
   local td = GameTaskModel.GetTaskDataByID(task_id)
   if table_is_null(td) then return end
   local all_task_award_status = basefunc.decode_task_award_status(td.award_get_status)
   all_task_award_status = basefunc.decode_all_task_award_status(all_task_award_status, td, count)
   return all_task_award_status
end

function M.on_fishing_ready_finish()
    --[[if  M.IsActive() then
        if MainModel.myLocation == "game_Fishing3D" then
            ActivityYearPanel.Create()
        end
    end--]]
end