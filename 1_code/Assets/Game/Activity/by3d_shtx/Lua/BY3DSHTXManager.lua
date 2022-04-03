-- 创建时间:2020-10-27
-- BY3DSHTXManager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DSHTXManager = {}
local M = BY3DSHTXManager
M.key = "by3d_shtx"
M.config = GameButtonManager.ExtLoadLua(M.key, "by3d_shtx_config")
GameButtonManager.ExtLoadLua(M.key, "BY3DSHTXPanel")
GameButtonManager.ExtLoadLua(M.key, "BY3DSHTXEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "BY3DSHTXLeftItemBase")
local this
local lister
M.guide_tasks = {30019,30020,30021,30022,30023}
M.father_task_id = 93
M.refresh_cost = 10000

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if FishingModel.game_id == 1 and not M.CheckIsInGuide() then
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
        return BY3DSHTXEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "bytop_area" then
        return BY3DSHTXEnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
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

    lister["query_shtx_base_info_response"] = this.on_query_shtx_base_info_response
    lister["query_one_task_data_response"] = this.on_query_one_task_data_response
    lister["task_change_msg"] = this.on_task_change_msg
    lister["refresh_ocean_explore_task_response"] = this.on_refresh_ocean_explore_task--切换任务
    lister["get_task_award_response"] = this.on_get_task_award_response
    lister["set_ocean_explore_get_award_way_response"] = this.on_set_ocean_explore_get_award_way_response
    lister["AssetChange"] = this.on_AssetChange
end

function M.Init()
	M.Exit()

	this = BY3DSHTXManager
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
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

--判断是否大于等于Vip3
function M.CheckIsVip3()
    if MainModel.UserInfo.vip_level >= 3 then
        return true
    else
        return false
    end
end

--请求当前层的任务id和层数
function M.QueryCurLayerTaskId()
    local data = GameTaskModel.GetTaskDataByID(M.father_task_id)
    if data and this.m_data.father_task_time and os.time() - this.m_data.father_task_time < 5 then
        M.QueryCurLayerTaskData()
    else
        this.m_data.father_task_time = os.time()
        Network.SendRequest("query_one_task_data",{task_id = M.father_task_id})
    end
end

--请求当前层的任务数据
function M.QueryCurLayerTaskData()
    local data = GameTaskModel.GetTaskDataByID(M.father_task_id)
    if false--[[data and this.m_data.cur_task_time and os.time() - this.m_data.cur_task_time < 5--]] then--如果第二个任务在第一个任务刚领完的5秒内就完成了,就会出现刷新异常的情况
        Event.Brocast("by3d_shtx_cur_task_data_is_queried")
    else
        this.m_data.cur_task_time = os.time()
        Network.SendRequest("query_one_task_data",{task_id = this.m_data.cur_task_id})
    end
end

function M.on_query_one_task_data_response(_,data)
    --dump(data,"<color=yellow><size=15>++++++++++on_query_one_task_data_response++++++++++</size></color>")
    if data and data.result == 0 then
        data = data.task_data
        if data then
            if data.id == M.father_task_id then
                this.m_data.cur_layer = tonumber(data.now_total_process) + 1
                local other = basefunc.parse_activity_data(data.other_data_str)
                dump(other,"<color=yellow><size=15>++++++++++other++++++++++</size></color>")
                this.m_data.cur_task_id =  tonumber(other.children_task_id)
                this.m_data.auto = tonumber(other.is_auto_get_children_task_award) or 0
                M.QueryCurLayerTaskData()
            elseif this.m_data.cur_task_id and data.id == this.m_data.cur_task_id then
                this.m_data.shtx_task_data = data
                Event.Brocast("by3d_shtx_cur_task_data_is_queried")
            end
        end
    end
end

--获取当前任务的配置
function M.GetCurTaskConfig()
    for i=1,#M.config.task_info do
        if M.config.task_info[i].task_id == this.m_data.cur_task_id then
            return M.config.task_info[i]
        end
    end
end

function M.GetCurLayer()
    return this.m_data.cur_layer or 1
end

--获取当前任务的数据
function M.GetCurTaskData()
    return this.m_data.shtx_task_data
end

--领取奖励
function M.GetAward()
    if M.CheckIsInGuide() then
        for k,v in pairs(M.guide_tasks) do
            local data = GameTaskModel.GetTaskDataByID(v)
            if data and data.award_status == 1 then
                Network.SendRequest("get_task_award",{id = v})
                break
            end
        end
    else
        Network.SendRequest("get_task_award",{id = this.m_data.cur_task_id})
    end
end

function M.on_task_change_msg(_,data)
    --dump(data,"<color=yellow><size=15>++++++++++on_task_change_msg++++++++++</size></color>")
    data = data.task_item
    if data then
        if data.id == M.father_task_id then--父任务改变
            if this.m_data.cur_layer ~= (tonumber(data.now_total_process) + 1) or this.m_data.cur_task_id ~= tonumber(data.other_data_str) then--换层了或者子任务id改变了
                this.m_data.cur_layer = tonumber(data.now_total_process) + 1
                local other = basefunc.parse_activity_data(data.other_data_str)
                dump(other,"<color=yellow><size=15>++++++++++other++++++++++</size></color>")
                this.m_data.cur_task_id =  tonumber(other.children_task_id)
                this.m_data.auto = tonumber(other.is_auto_get_children_task_award) or 0
                M.QueryCurLayerTaskData()
            end
        elseif this.m_data.cur_task_id and data.id == this.m_data.cur_task_id then--子任务改变
            this.m_data.shtx_task_data = data
            Event.Brocast("by3d_shtx_cur_task_data_is_change")
        end
    end
end

function M.on_refresh_ocean_explore_task(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_refresh_ocean_explore_task++++++++++</size></color>")
    if data and data.result == 0 then
    end
end

function M.SetAuto()
    dump(this.m_data.auto,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
    if this.m_data.auto and this.m_data.auto == 2 then
        Network.SendRequest("set_ocean_explore_get_award_way",{way = 0,parent_task_id = M.father_task_id})
    else
        Network.SendRequest("set_ocean_explore_get_award_way",{way = 2,parent_task_id = M.father_task_id})
    end
end

function M.on_set_ocean_explore_get_award_way_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_set_auto_response++++++++++</size></color>")
    if data and data.result == 0 then
        if this.m_data.auto == 2 then
            this.m_data.auto = 0
        elseif not this.m_data.auto or this.m_data.auto == 0 then
            this.m_data.auto = 2 
        end
        Event.Brocast("by3d_shtx_on_auto_response")
    end
end

function M.GetAuto()
    return this.m_data.auto == 2
end

function M.on_AssetChange(data)
    if data and data.change_type == "task_ocean_explore_week_children_task" then
        if M.GetAuto() then
            Event.Brocast("AssetGet",{data = data.data, title_img = "hdjl_bt_shtxjl",title_scale = Vector3.New(2,2,2),tips = "(自动领取)",tips_pos = Vector3.New(0,160,0)}) 
        else
            Event.Brocast("AssetGet",{data = data.data, title_img = "hdjl_bt_shtxjl",title_scale = Vector3.New(2,2,2)}) 
        end   
    end
end

function M.GetExtraAwardCfg()
    local tab = {}
    for i=1,#M.config.extra_award do
        if M.config.extra_award[i].sta_t and M.config.extra_award[i].end_t and os.time() >= M.config.extra_award[i].sta_t and os.time() <= M.config.extra_award[i].end_t then
            tab[#tab + 1] = M.config.extra_award[i]
        end
    end
    if table_is_null(tab) then
        for i=1,#M.config.extra_award do
            if not M.config.extra_award[i].sta_t and not M.config.extra_award[i].end_t then
                tab[#tab + 1] = M.config.extra_award[i]
            end
        end
    end
    return tab
end

function M.CheckIsInGuide()
    local complete = true
    for k,v in pairs(M.guide_tasks) do
        local data = GameTaskModel.GetTaskDataByID(v)
        if data and data.award_status ~= 2 then
            complete = false
            break
        end
    end
    return GameGlobalOnOff.IsOpenGuide and (MainModel.UserInfo.xsyd_status ~= -1) and not complete
end

function M.on_get_task_award_response(_,data)
    --dump(data,"<color=yellow><size=15>++++++++++on_get_task_award_response++++++++++</size></color>")
    if data and data.result == 0 then
        for k,v in pairs(M.guide_tasks) do
            if data.id == v then
                Event.Brocast("ui_button_state_change_msg")
            end
        end   
    end
end