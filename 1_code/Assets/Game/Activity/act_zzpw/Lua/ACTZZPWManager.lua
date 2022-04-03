-- 创建时间:2021-05-17
-- ACTZZPWManager 管理器

local basefunc = require "Game/Common/basefunc"
ACTZZPWManager = {}
local M = ACTZZPWManager
M.key = "act_zzpw"
local config = GameButtonManager.ExtLoadLua(M.key, "act_zzpw_config")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWPanel")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWPathPrefab")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWHelpPrefab")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWRankItemBase")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWRankPanel")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWTaskItemBase")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWTaskPanel")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWRankAwardItemBase")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWRankAwardPanel")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWJCItemBase")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWJCPanel")
GameButtonManager.ExtLoadLua(M.key, "ACTZZPWUpGradePanel")

local this
local lister
local dice_key = "prop_dice"
M.is_debug = false

-- 是否有活动
function M.IsActive(parm)
    -- 活动的开始与结束时间
    local e_time=M.GetActEndtime()
    local s_time=M.GetActStaTime()
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if FishingModel and FishingModel.game_id and FishingModel.game_id == 1 then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if parm.condi_key then
        _permission_key = parm.condi_key
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
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive(parm)
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
        return ACTZZPWPanel.Create(parm.parent, parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return ACTZZPWEnterPrefab.Create(parm.parent)
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
    -- lister["super_treasure_query_base_info_response"] = this.on_super_treasure_query_base_info
    -- lister["super_treasure_use_normal_dice_response"] = this.on_super_treasure_use_normal_dice
    -- lister["getjc_response"] = this.on_getjc_response
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["zhizhun_rank_get_data_response"] = this.on_zhizhun_rank_get_data
    lister["zhizhun_rank_dice_response"] = this.on_zhizhun_rank_dice
    lister["zhizhun_rank_data_notify"] = this.on_zhizhun_rank_data_notify

    lister["AssetsGetPanelCreating"] = this.on_AssetsGetPanelCreating
end

function M.Init()
	M.Exit()

	this = ACTZZPWManager
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
    this.UIConfig.config = {}
    this.careTasks ={}
    for k,v in ipairs(config.config) do
        this.UIConfig.config[v.rank] = v
    end
    this.UIConfig.task_config = {}
    for k,v in pairs(config.task) do
        this.UIConfig.task_config[v.group] = v
        if not this.careTasks[v.task_id] then
            this.careTasks[v.task_id] = 1
        end
    end
    this.UIConfig.map_config = {}
    for k,v in ipairs(config.map) do
        this.UIConfig.map_config[v.group] = this.UIConfig.map_config[v.group] or {}
        this.UIConfig.map_config[v.group][#this.UIConfig.map_config[v.group] + 1] = v
    end
    this.UIConfig.jc_config = {}
    for k,v in pairs(config.jc) do
        this.UIConfig.jc_config[v.group] = this.UIConfig.jc_config[v.group] or {}
        this.UIConfig.jc_config[v.group][#this.UIConfig.jc_config[v.group] + 1] = v
    end

    this.UIConfig.staTime_list = {1643068800,1644278400}
    this.UIConfig.endTime_list = {1644249599,1645459199}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetConfig()
    return this.UIConfig.config
end

function M.GetJCConfigByGroup()
    return this.UIConfig.jc_config[M.GetConfigByCurRank().jc_group][1]
end

function M.GetConfigByCurRank()
    return this.UIConfig.config[M.GetCurRank()]
end
function M.GetMapConfigByGroup()
    return this.UIConfig.map_config[M.GetConfigByCurRank().map_group]
end

function M.GetActStaTime()
    return this.UIConfig.staTime
end

function M.GetActEndtime()
    for i=1,#this.UIConfig.endTime_list do
        if os.time() <= this.UIConfig.endTime_list[i] then
            this.UIConfig.endTime = this.UIConfig.endTime_list[i]
            this.UIConfig.staTime = this.UIConfig.staTime_list[i]
            return this.UIConfig.endTime
        end
    end
    return this.UIConfig.endTime_list[#this.UIConfig.endTime_list]
end

function M.IsHint()
    if M.GetCurDiceNum() > 0 then
        return true
    end
end
-- 网络请求
function M.QueryBaseData()
    if M.is_debug then
        -- this.m_data.base_info = this.m_data.base_info or {}
        -- this.m_data.base_info.location = 1
        -- Event.Brocast("model_super_treasure_query_base_info_msg", 0)
        local data = {
            award_pool = 0,
            duanwei = "tong",
            grade = 1,
            position = 0,
            duanwei_index = 1,
        }
        this.m_data.baseData = data
        Event.Brocast("model_super_treasure_query_base_info_msg", 0)
    else
        --Network.SendRequest("super_treasure_query_base_info")
        Network.SendRequest("zhizhun_rank_get_data")
    end
end

-- function M.on_super_treasure_query_base_info(_, data)
--     dump(data,"<color=yellow>+++on_super_treasure_query_base_info+++</color>")
--     if data.result == 0 then
--         this.m_data.base_info = this.m_data.base_info or {}
--         this.m_data.base_info.location = data.location + 1
--     end
--     Event.Brocast("model_super_treasure_query_base_info_msg", data.result)
-- end

-- function M.on_super_treasure_use_normal_dice(_, data)
--     dump(data,"<color=yellow>+++on_super_treasure_use_normal_dice+++</color>")
--     if data.result == 0 then
--         Event.Brocast("model_super_treasure_use_dice_msg", {is_any=false, dot=data.dot, location=data.location + 1})
--     else
--         HintPanel.ErrorMsg(data.result)
--     end    
-- end

function M.on_zhizhun_rank_get_data(_, data)
    dump(data,"<color=yellow>+++至尊排位:基础数据 on_zhizhun_rank_get_data+++</color>")
    if data.result == 0 then
        this.m_data.baseData = data.data
        Event.Brocast("model_zhizhun_rank_get_data_msg")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_zhizhun_rank_dice(_, data)
    --dump(data,"<color=yellow>+++至尊排位:摇骰子结果 on_zhizhun_rank_dice+++</color>")
    if data.result == 0 then
        this.m_data.baseData = data.data
        this.m_data.diceData = data.dice
        Event.Brocast("model_zhizhun_rank_dice_msg", data)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_zhizhun_rank_data_notify(_, data)
    dump(data,"<color=yellow>+++至尊排位:基础数段位升级 on_zhizhun_rank_data_notify+++</color>")
    if not this.m_data.baseData then
        return
    end
    if data.data.duanwei_index > this.m_data.baseData.duanwei_index then
        this.m_data.baseData = data.data
        ACTZZPWUpGradePanel.Create()
        Event.Brocast("model_zhizhun_exp_change_msg")
    end
    if data.data.exp ~= this.m_data.baseData.exp then
        this.m_data.baseData = data.data
        Event.Brocast("model_zhizhun_exp_change_msg")
    end
end

function M.on_model_task_change_msg(data)
    if not data then
        return
    end
    if this.careTasks[data.id] then
        --M.QueryBaseData()
        Event.Brocast("model_zhizhun_task_change_msg")
        return
    end
end

--获得资产面板创建时
function M.on_AssetsGetPanelCreating(data, panelUI)
    -- dump(data, "<color=white>MMMMMMMMMMMMMMMMMMMMMMMMMMMMMM</color>")
    local isContainSz = false
    if not table_is_null(data.data) then
        for i = 1, #data.data do
            if data.data[i].asset_type == "prop_dice" then
                isContainSz = true
                break
            end
        end
    end
    if isContainSz then
        local gotoBtnObj = GameObject.Instantiate(panelUI.confirm_btn)
        gotoBtnObj.name = "goto_btn"
        gotoBtnObj.transform:SetParent(panelUI.confirm_btn.transform.parent)
        local gotoBtn = gotoBtnObj:GetComponent("Button")
        gotoBtn.onClick:AddListener(function()
            Event.Brocast("CloseAssetsPanel")
            ACTZZPWPanel.Create()
        end)
        panelUI.confirm_btn.transform.localPosition = Vector3.New(-237, -325.78, 0)
        gotoBtnObj.transform.localPosition = Vector3.New(177, -325.78, 0)
        gotoBtnObj.transform.localScale = Vector3.New(1.1, 1.1, 1.1)
        local txt = gotoBtnObj.transform:Find("ImgOneMore"):GetComponent("Text")
        txt.text = "去使用"
    end
end 

function M.GetBaseData()
    return this.m_data.baseData
end

function M.GetDicData()
    return this.m_data.diceData
end

function M.GetDotData(lastPos)
    local dot = 0
    --新的一圈
    if this.m_data.diceData.new_round == 1 then
        dot = (26 - lastPos) + this.m_data.baseData.position 
    else
        dot = this.m_data.baseData.position - lastPos
    end
    return dot
end

--当前任务对应的段位，此段位和玩家当前的段位不一定相同
function M.GetCurTaskIndex()
    local taskData = GameTaskModel.GetTaskDataByID(1000815)
    local index = 1
    if taskData.other_data_str then
        local other = basefunc.parse_activity_data(taskData.other_data_str)
        index = other.rank_stage_index
    end
    return index
end

--当前任务的配置
function M.GetCurTaskConfig()
    return this.UIConfig.config[M.GetCurTaskIndex()]
end

--获取当前段位
function M.GetCurRank()
    local rank
    if M.is_debug then
        rank = 1
    else
        rank = this.m_data.baseData.duanwei_index
    end
    return rank
end

function M.GetTaskConfig()
    return this.UIConfig.task_config
end

function M.GetPHBData()
    local phb
    if M.is_debug then
        phb = {{ranking=1,name="asdfaf",rank=5},{ranking=2,name="hfdh",rank=3},{ranking=3,name="tete",rank=1},{ranking=4,name="thhhhh",rank=1}}
    else
        phb = this.m_data.phb
    end
    return phb
end

function M.GetCurDiceNum()
    local num
    if M.is_debug then
        num = 0
    else
        num = GameItemModel.GetItemCount(dice_key)
    end
    return num
end

function M.GetCurJC()
    local num 
    if M.is_debug then
        num = 10000
    else
        num = this.m_data.baseData.award_pool
    end
    return num or 0
end

-- function M.GetJCAward()
    -- if M.is_debug then
    --     Event.Brocast("getjc_response","getjc_response",1)
    -- else
    --     Network.SendRequest("")
    -- end
-- end

-- function M.on_getjc_response(_,data)
    --Event.Brocast("getjc",data)
-- end

function M.GetCurScore()
    local score
    if M.is_debug then
        score = 122
    else
        score = this.m_data.baseData.exp
    end
    return score
end

function M.GetCurNeedScore()
    local config = M.GetConfigByCurRank()
    return config.need_num
end

function M.GetIndexFromScore(score)
    for i = 1, #this.UIConfig.config do
        local num = this.UIConfig.config[i].num
        local need_num = this.UIConfig.config[i].need_num
        local cur_num = tonumber(score) 
        if cur_num >= num and cur_num < need_num then
            return i
        end
        if i == #this.UIConfig.config and cur_num >= num then
            return i
        end
    end
end
