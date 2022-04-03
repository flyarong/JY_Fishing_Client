-- 创建时间:2021-02-26
-- SGXXL_Tower_ClimbingManager 管理器

local basefunc = require "Game/Common/basefunc"
SGXXL_Tower_ClimbingManager = {}
local M = SGXXL_Tower_ClimbingManager
M.key = "sgxxl_tower_climbing"
local config = GameButtonManager.ExtLoadLua(M.key,"sgxxl_tower_climbing_config")
GameButtonManager.ExtLoadLua(M.key,"SGXXL_Tower_ClimbingEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"SGXXL_Tower_ClimbingPanel")
GameButtonManager.ExtLoadLua(M.key,"SGXXL_Tower_ClimbingHelpPanel")
M.index_map = {[1] = 1,[2] = 2,[3] = 3,[4] = 4,[5] = 5,[6] = 6,[7] = 7}
M.layer_task_award = {"10福利券","100福利券","1000福利券"}
local this
local lister
M.layer_task_id = 96
M.father_task_id = 96

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
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
    if parm.goto_scene_parm == "panel" then
        return SGXXL_Tower_ClimbingPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return SGXXL_Tower_ClimbingEnterPrefab.Create(parm.parent, parm.cfg)
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

    lister["model_task_change_msg"] = M.on_model_task_change_msg
    lister["query_one_task_data_response"] = this.on_query_one_task_data_response
    lister["task_change_msg"] = this.on_task_change_msg
    lister["set_xiaoxiaole_tower_get_award_way_response"] = this.on_set_xiaoxiaole_tower_get_award_way_response
    lister["EnterScene"] = this.OnEnterScene
    lister["sgxxl_tower_climbing_last_task_data_save"] = this.on_sgxxl_tower_climbing_last_task_data_save
    lister["model_get_task_award_response"] = this.on_model_get_task_award_response
    lister["sgxxl_tower_climbing_auto_get_asset"] = this.on_sgxxl_tower_climbing_auto_get_asset
    lister["AssetChange"] = this.on_AssetChange
    lister["ExitScene"]=this.on_ExitScene
    lister["sgxxl_tower_refresh_change_msg"] = this.on_sgxxl_tower_refresh_change_msg
end

function M.Init()
	M.Exit()

	this = SGXXL_Tower_ClimbingManager
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
    for k,v in pairs(config.task_info) do
        this.UIConfig.task_map[v.task_id] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetLayerTaskAward(level)
    Network.SendRequest("get_task_award_new",{id = M.layer_task_id,award_progress_lv = level})
end

function M.on_model_task_change_msg(data)
    if data and data.id == M.layer_task_id then
        Event.Brocast("sgxxl_tower_climbing_task_change_msg")
    end
end

function M.SetIsShow(type,b)
    this.m_data.is_show = this.m_data.is_show or {}
    this.m_data.is_show[type] = b
end

function M.GetIsShow(type)
    if this.m_data.is_show then
        return this.m_data.is_show[type]
    else
        return false
    end
end

function M.GetCurTaskId()
    return this.m_data.cur_task_id
end

function M.GetCurTaskConfig()
    return this.UIConfig.task_map[this.m_data.cur_task_id]
end

function M.GetCurLayer()
    return this.m_data.cur_layer or 1 
end

function M.GetCurTaskData()
    return this.m_data.tower_task_data
end

--领取奖励
function M.GetAward()
    Network.SendRequest("get_task_award",{id = this.m_data.cur_task_id})
end

--请求当前层的任务id和层数
function M.QueryCurLayerTaskId()
    Network.SendRequest("query_one_task_data",{task_id = M.father_task_id})
end

--请求当前层的任务数据
function M.QueryCurLayerTaskData()
    Network.SendRequest("query_one_task_data",{task_id = this.m_data.cur_task_id})
end

function M.on_query_one_task_data_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_query_one_task_data_response++++++++++</size></color>")
    if data and data.result == 0 then
        data = data.task_data
        if data then
            if data.id == M.father_task_id then
                this.m_data.cur_layer = tonumber(data.now_total_process) + 1
                local other = basefunc.parse_activity_data(data.other_data_str)
                dump(data,"<color=yellow><size=15>++++++++++other++++++++++</size></color>")
                this.m_data.cur_task_id =  tonumber(other.children_task_id)
                this.m_data.auto = tonumber(other.is_auto_get_children_task_award) or 0
                M.QueryCurLayerTaskData()
            elseif this.m_data.cur_task_id and data.id == this.m_data.cur_task_id then
                --[[local other = basefunc.parse_activity_data(data.other_data_str)
                data.other = other--]]
                dump(data,"<color=yellow><size=15>++++++++++other++++++++++</size></color>")
                this.m_data.tower_task_data = data
                Event.Brocast("sgxxl_tower_climbing_last_task_data_save")
                Event.Brocast("sgxxl_tower_climbing_cur_task_data_is_queried")
            end
        end
    end
end

function M.on_task_change_msg(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_task_change_msg++++++++++</size></color>")
    data = data.task_item
    if data then
        if data.id == M.father_task_id then--父任务改变
            if this.m_data.cur_layer ~= (tonumber(data.now_total_process) + 1) or this.m_data.cur_task_id ~= tonumber(data.other_data_str) then--换层了或者子任务id改变了
                this.m_data.cur_layer = tonumber(data.now_total_process) + 1
                local other = basefunc.parse_activity_data(data.other_data_str)
                dump(data,"<color=yellow><size=15>++++++++++other++++++++++</size></color>")
                this.m_data.cur_task_id =  tonumber(other.children_task_id)
                this.m_data.auto = tonumber(other.is_auto_get_children_task_award) or 0
                M.QueryCurLayerTaskData()
            end
        elseif this.m_data.cur_task_id and data.id == this.m_data.cur_task_id then--子任务改变
            --local other = basefunc.parse_activity_data(data.other_data_str)
            dump(data,"<color=yellow><size=15>++++++++++other++++++++++</size></color>")
            --data.other = other
            this.m_data.tower_task_data = data 
        end
    end
end

function M.SetAuto()
    dump(this.m_data.auto,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
    if this.m_data.auto and this.m_data.auto == 2 then
        Network.SendRequest("set_xiaoxiaole_tower_get_award_way",{way = 0,parent_task_id = M.father_task_id})
    else
        Network.SendRequest("set_xiaoxiaole_tower_get_award_way",{way = 2,parent_task_id = M.father_task_id})
    end
end

function M.on_set_xiaoxiaole_tower_get_award_way_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_set_auto_response++++++++++</size></color>")
    if data and data.result == 0 then
        if this.m_data.auto == 2 then
            this.m_data.auto = 0
        elseif not this.m_data.auto or this.m_data.auto == 0 then
            this.m_data.auto = 2 
        end
        Event.Brocast("sgxxl_tower_climbing_on_auto_response")
    end
end

function M.GetAuto()
    return this.m_data.auto == 2
end

function M.OnEnterScene()
    if MainModel.myLocation ~= "game_Eliminate" then
        if this.m_data.auto and this.m_data.auto == 2 then
            Network.SendRequest("set_xiaoxiaole_tower_get_award_way",{way = 0,parent_task_id = M.father_task_id})
        end
    else
        this.is_need_save_data = true
    end
end

function M.on_sgxxl_tower_climbing_last_task_data_save()
    print(debug.traceback())
    dump("<color=red><size=15>++++++++++///////////++++++++++</size></color>")
    this.m_data.last_task_data = GameTaskModel.GetTaskDataByID(this.m_data.cur_task_id)
    this.m_data.last_layer_task_data = GameTaskModel.GetTaskDataByID(M.father_task_id)
    this.m_data.last_task_config = this.UIConfig.task_map[this.m_data.cur_task_id]
end

function M.GetLastTaskData()
    return this.m_data.last_task_data
end

function M.GetLastLayerTaskData()
    return this.m_data.last_layer_task_data
end

function M.GetLastTaskCfg()
    return this.m_data.last_task_config
end

function M.on_model_get_task_award_response(data)
    if data and data.result == 0 then
        if this.UIConfig.task_map[data.id] then
            dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
            Event.Brocast("sgxxl_tower_climbing_last_task_data_save")
            Event.Brocast("sgxxl_tower_climbing_cur_task_data_is_change")
            Event.Brocast("sgxxl_tower_climbing_auto_get_asset")
        end
    end
end

function M.on_sgxxl_tower_climbing_auto_get_asset()
    if this.m_data.asset_data then
        if M.GetAuto() then
            dump(this.m_data.asset_data,"<color=yellow><size=15>++++++++111111111++data++++++++++</size></color>")
            Event.Brocast("AssetGet",{data = this.m_data.asset_data.data, title_img = "xxlcg_imgf_2",title_scale = Vector3.New(2,2,2),tips = "(自动领取)",tips_pos = Vector3.New(0,160,0)})
        else
            dump(this.m_data.asset_data,"<color=yellow><size=15>++++++++222222222++data++++++++++</size></color>")
            Event.Brocast("AssetGet",{data = this.m_data.asset_data.data, title_img = "xxlcg_imgf_2",title_scale = Vector3.New(2,2,2)}) 
        end
        this.m_data.asset_data = nil
    end
end

function M.on_AssetChange(data)
    if data and data.change_type == "task_xiaoxiaole_tower" then
        this.m_data.asset_data = data
    end
end

function M.on_ExitScene()
    --dump({location = MainModel.Location,bool = this.is_need_save_data},"<color=yellow><size=15>++++++++++88888888888data++++++++++</size></color>")
    if MainModel.Location ~= "game_Eliminate" and this.is_need_save_data then
        --结算完成才能刷新消消乐爬塔的显示
        Event.Brocast("sgxxl_tower_climbing_last_task_data_save")
        --Event.Brocast("sgxxl_tower_climbing_cur_task_data_is_change")
        this.is_need_save_data = false
    end
end

function M.on_sgxxl_tower_refresh_change_msg(data)
    dump(data, "11111111111111111111")
    local c_data = M.GetCurTaskData()
    local l_data = M.GetLastTaskData()
    local l_config = M.GetLastTaskCfg()
    dump(l_config)
    local icon_map = {}
    for k,v in ipairs(l_config.task_icon) do
        icon_map[tonumber(string.sub(v,-1))] = k
    end
    if not icon_map[data.id] then
        return
    end
    if l_data then
        if (not l_data.other) or (not c_data.other) then
            local other = basefunc.parse_activity_data(l_data.other_data_str)
            c_data.other = basefunc.parse_activity_data(c_data.other_data_str)
            l_data.other = other
        end
        for k,v in pairs(l_config.task_icon) do
            if not l_data.other[tonumber(string.sub(v,-1))] then
                l_data.other[tonumber(string.sub(v,-1))] = 0
            end
        end
        if not c_data.other or not c_data.other[data.id] or (l_data.other[data.id] >= c_data.other[data.id]) then
            return
        end
        data.fly_index = icon_map[data.id]
        l_data.other[data.id] = l_data.other[data.id] + data.num
        if l_data.other[data.id] > c_data.other[data.id] then
            l_data.other[data.id] = c_data.other[data.id]
        end
        Event.Brocast("sgxxl_tower_climbing_fx_msg",data)
    end
end
