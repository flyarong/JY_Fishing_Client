-- 创建时间:2020-11-02
-- Act_035_YBWLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_035_YBWLManager = {}
local M = Act_035_YBWLManager
M.key = "act_035_ybwl"
M.config = GameButtonManager.ExtLoadLua(M.key,"act_035_config")
GameButtonManager.ExtLoadLua(M.key,"Act_035_YBWLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_035_YBWLGamePanel")
GameButtonManager.ExtLoadLua(M.key,"Act_035_YBWLLeftPage")
GameButtonManager.ExtLoadLua(M.key,"Act_035_YBWLItemBase")
local this
local lister
M.father_task_id = 1000099
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
        if M.CheckIsShow() then
            return Act_035_YBWLGamePanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return Act_035_YBWLEnterPrefab.Create(parm.parent, parm.cfg)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsCanGet() then
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["finish_gift_shop"] = this.on_finish_gift_shop--完成礼包购买
    lister["query_one_task_data_response"] = this.on_query_one_task_data_response
    lister["task_change_msg"] = this.on_task_change_msg
    lister["model_task_change_msg"] = this.on_model_task_change_msg
end

function M.Init()
	M.Exit()

	this = Act_035_YBWLManager
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

    this.m_data.gift_ids = {}
    for i=1,#M.config.base_info do
        this.m_data.gift_ids[#this.m_data.gift_ids + 1] = M.config.base_info[i].gift_id
    end

    this.m_data.task_ids = {}
    for i=1,#M.config.base_info do
        this.m_data.task_ids[#this.m_data.task_ids + 1] = M.config.base_info[i].task_id
    end
    this.m_data.wz_and_ry_gift_id = {}
    for i=7,8 do
        this.m_data.wz_and_ry_gift_id[#this.m_data.wz_and_ry_gift_id + 1] = M.config.base_info[i].gift_id
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.QueryBaseTaskData()
        --M.QueryWZandRYgiftData()
	end
end
function M.OnReConnecteServerSucceed()
end

local M_DATA = nil
function M.GetBaseCfg()
--[[    if M_DATA then
        return M_DATA
    else
        M_DATA = basefunc.deepcopy(M.config.base_info)
    end
    return M_DATA--]]
    return M.config.base_info
end

function M.GetConfig()
    return M.config.base_info
end

function M.QueryWZandRYgiftData()
    Network.SendRequest("query_gift_bag_status_by_ids",{ gift_bag_ids = this.m_data.wz_and_ry_gift_id })
end

function M.GetAward(id,index)
    Network.SendRequest("get_task_award_new", {id = id,award_progress_lv = index})
end

function M.on_finish_gift_shop(id)
    dump(id,"<color=yellow><size=15>++++++++++on_finish_gift_shop++++++++++</size></color>")
    for i=1,#M.config.base_info do
        if id == M.config.base_info[i].gift_id then
            --PlayerPrefs.SetInt("YBWL"..MainModel.UserInfo.user_id..id,0)
            Event.Brocast("ybwl_gift_had_buy_msg")
            return
        end
    end
end

function M.IsCanGet()
    for i=1,#M.config.base_info do
        local task_data = GameTaskModel.GetTaskDataByID(M.config.base_info[i].task_id)
        if task_data then
            if task_data.award_status == 1 then
                return true
            end
        end
    end
    return false
end

--获取礼包的有效时间
function M.GetGiftValueTime()
    return this.m_data.value_time or 0
end

--请求基础数据
function M.QueryBaseTaskData()
    if this.m_data.value_time and this.m_data.buy_gift_ids then
        Event.Brocast("ybwl_base_data_is_get_msg")
    else
        dump("<color=blue><size=15>++++++++++data++++++++++</size></color>")
        Network.SendRequest("query_one_task_data",{task_id = M.father_task_id})
    end
end

function M.on_query_one_task_data_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_query_one_task_data_response++++++++++</size></color>")
    if data and data.result == 0 then
        data = data.task_data
        if data then
            if data.id == M.father_task_id then
                dump(data,"<color=blue><size=15>++++++++++data++++++++++</size></color>")
                if data.other_data_str then
                    local other = basefunc.parse_activity_data(data.other_data_str)
                    this.m_data.value_time = tonumber(other.valid_time)
                    this.m_data.buy_gift_ids = this.m_data.buy_gift_ids or {}
                    this.m_data.buy_gift_ids = other.bought_gift_bag_ids
                    this.m_data.gift_bag_sp_ids = this.m_data.gift_bag_sp_ids or {}
                    this.m_data.gift_bag_sp_ids = other.gift_bag_sp_ids
                    Event.Brocast("ybwl_base_data_is_get_msg")
                end
            else
                for i=1,#this.m_data.task_ids do
                    if data.id == this.m_data.task_ids[i] then
                        Event.Brocast("ybwl_task_has_change_msg")
                    end
                end
            end
        end
    end
end

--检查此礼包是否购买过
function M.CheckGiftWasBought(id)
    --dump({id=id,pt=this.m_data.buy_gift_ids,sp=this.m_data.gift_bag_sp_ids},"<color=red><size=15>++++++++++CheckGiftWasBought++++++++++</size></color>")
    if not table_is_null(this.m_data.buy_gift_ids) then
        if this.m_data.value_time then
            if os.time() < this.m_data.value_time then
                for k,v in pairs(this.m_data.buy_gift_ids) do
                    if v == id then
                        return true
                    end
                end
            end
        end
    end
    if not table_is_null(this.m_data.gift_bag_sp_ids) then
        for k,v in pairs(this.m_data.gift_bag_sp_ids) do
            if v == id then
                local task_id
                if id == 10390 then
                    task_id = 1000106
                elseif id == 10391 then
                    task_id = 1000107
                end
                local data = GameTaskModel.GetTaskDataByID(task_id)
                dump(data,"<color=red><size=15>++++++++++RRRRRRRRRRRRRRRRRR++++++++++</size></color>")
                if data then
                    if data.award_status ~= 2 then
                        return true
                    end
                else
                    return true
                end
            end
        end
    end
   --[[ local data = MainModel.GetGiftDataByID(id)
    if data and data.status == 0 then--王者礼包和荣耀礼包
        return true
    end--]]
    return false
end

function M.on_task_change_msg(_,data)
    data = data.task_item
    if data then
        if data.id == M.father_task_id then
            dump(data,"<color=blue><size=15>++++++++++data++++++++++</size></color>")
            if data.other_data_str then
                local other = basefunc.parse_activity_data(data.other_data_str)
                dump(other,"<color=green><size=15>++++++++++data++++++++++</size></color>")
                this.m_data.value_time = tonumber(other.valid_time)
                this.m_data.buy_gift_ids = this.m_data.buy_gift_ids or {}
                this.m_data.buy_gift_ids = other.bought_gift_bag_ids
                this.m_data.gift_bag_sp_ids = this.m_data.gift_bag_sp_ids or {}
                this.m_data.gift_bag_sp_ids = other.gift_bag_sp_ids
                Event.Brocast("ybwl_base_data_is_get_msg")
            end
        else
            --dump({id=data.id,ids=this.m_data.task_ids},"<color=blue><size=15>++++++++++ididididid++++++++++</size></color>")
            for i=1,#this.m_data.task_ids do
                if data.id == this.m_data.task_ids[i] then
                    Event.Brocast("ybwl_task_has_change_msg")
                end
            end
        end
    end
end

function M.on_model_task_change_msg(data)
    if data then
        for i=1,#this.m_data.task_ids do
            if data.id == this.m_data.task_ids[i] then
                Event.Brocast("ybwl_task_has_change_msg")
            end
        end
    end
end

function M.GetTaskAwardStatus(task_id,count)
    if not task_id or not count then return end 
    local td = GameTaskModel.GetTaskDataByID(task_id)
    dump({td=td,task_id =task_id},"<color=yellow><size=15>++++++++++td++++++++++</size></color>")
    if table_is_null(td) then return end
    local all_task_award_status = basefunc.decode_task_award_status(td.award_get_status)
    all_task_award_status = basefunc.decode_all_task_award_status(all_task_award_status, td, count)
    return all_task_award_status
end

function M.InitWZgiftstatus(data)
    dump(data,"<color=red><size=15>++++++++++remove++++++++++</size></color>")
    if data then
        if data.award_status == 2 then
            for i=1,#this.m_data.gift_bag_sp_ids do
                if this.m_data.gift_bag_sp_ids[i] == M.config.base_info[7].task_id then
                    dump(this.m_data.gift_bag_sp_ids,"<color=red><size=15>++++++++++remove++++++++++</size></color>")
                    table.remove(this.m_data.gift_bag_sp_ids,i)
                end
            end
        end
    end
end

function M.InitRYgiftstatus(data)
    local data = GameTaskModel.GetTaskDataByID(M.config.base_info[8].task_id)
    dump(data,"<color=red><size=15>++++++++++remove++++++++++</size></color>")
    if data then
        if data.award_status == 2 then
            for i=1,#this.m_data.gift_bag_sp_ids do
                if this.m_data.gift_bag_sp_ids[i] == M.config.base_info[8].task_id then
                    dump(this.m_data.gift_bag_sp_ids,"<color=red><size=15>++++++++++remove++++++++++</size></color>")
                    table.remove(this.m_data.gift_bag_sp_ids,i)
                end
            end
        end
    end
end

function M.InitRYgiftstatus(data)
    dump(data,"<color=red><size=15>++++++++++remove++++++++++</size></color>")
    if data then
        if data.award_status == 2 then
            for i=1,#this.m_data.gift_bag_sp_ids do
                if this.m_data.gift_bag_sp_ids[i] == M.config.base_info[8].task_id then
                    dump(this.m_data.gift_bag_sp_ids,"<color=red><size=15>++++++++++remove++++++++++</size></color>")
                    table.remove(this.m_data.gift_bag_sp_ids,i)
                end
            end
        end
    end
end

function M.GetGiftIdsList()
    return this.m_data.gift_ids
end