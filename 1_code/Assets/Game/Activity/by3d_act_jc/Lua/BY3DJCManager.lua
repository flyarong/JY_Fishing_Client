-- 创建时间:2020-06-16
-- BY3DJCManager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DJCManager = {}
local M = BY3DJCManager
M.key = "by3d_act_jc"
GameButtonManager.ExtLoadLua(M.key, "BY3DJCShowPanel")
GameButtonManager.ExtLoadLua(M.key, "BY3DJsEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "BY3DJCAnimManager")
GameButtonManager.ExtLoadLua(M.key, "JCExplainPrefab")
GameButtonManager.ExtLoadLua(M.key, "BY3DJCGameShowPanel")
GameButtonManager.ExtLoadLua(M.key, "BY3DJCZMCDJPanel")
GameButtonManager.ExtLoadLua(M.key, "BY3DJCGameRulesLeftPrefab")
GameButtonManager.ExtLoadLua(M.key, "BY3DJCGameRulesPanel")
GameButtonManager.ExtLoadLua(M.key, "by3djc_rulse_2")
GameButtonManager.ExtLoadLua(M.key, "by3djc_rulse_1")

local pms_rules_config = GameButtonManager.ExtLoadLua(M.key,"by3djc_rules_config")

local this
local lister

local send_time

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
    if  MainModel.myLocation == "game_Fishing3D" and FishingModel and (FishingModel.game_id == 1 or FishingModel.game_id == 2 or FishingModel.game_id == 3) then
        return false
    end
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "gameshow" and (FishingModel.game_id == 4 or FishingModel.game_id == 5) then 
        return BY3DJCGameShowPanel.Create(parm)
    else
        local ys = parm.cfg.parm[2]
        if ys == "enter_hall"
            or ys == "enter_fish"
            or ys == "enter4"
            or ys == "enter5" then 
            return BY3DJCShowPanel.Create(parm)  
        elseif ys == "explain" then
            return  JCExplainPrefab.Create()
        elseif ys == "hallEnter" then 
            return BY3DJsEnterPrefab.Create(parm)
        else    
            dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
        end
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

    lister["EnterScene"] = this.OnEnterScene
    lister["fish_3d_get_award_pool_num_response"] = this.on_get_award_pool_num

    lister["fish_3d_get_award_pool_award"]=this.get_award_pool_award
    lister["fish_3d_query_geted_award_pool_num_response"] = this.on_query_geted_award_pool_num
    lister["fish_3d_get_lottery_pool_num_response"] = this.on_get_lottery_pool_num
    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
end

function M.Init()
	M.Exit()
	this = BY3DJCManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()  


end
function M.Exit()
    M.StopSendTime()
	if this then
        M.SendJCData()
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

M.isLogined=false
function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化 
        M.isLogined=true
	end
end
function M.OnReConnecteServerSucceed()
end

function M.OnEnterScene()
     
    M.StopSendTime()
    if MainModel.myLocation == "game_Hall" or MainModel.myLocation == "game_Fishing3DHall"  or   MainModel.myLocation == "game_Fishing3D"  then
        this.m_data.is_one = true
        M.SendJCData()
        send_time = Timer.New(function ()
            M.SendJCData()
        end, 2, -1, nil, true)
        send_time:Start()
    end
   -- if MainModel.myLocation == "game_Fishing3DHall" then
        Network.SendRequest("fish_3d_query_geted_award_pool_num")
    -- end

    if MainModel.myLocation == "game_Fishing3D" then
        this.m_data.is_one_enter_1 = true
    end  
end

function M.QueryData()
    if this.m_data.award_pool_result == 0 then
        Event.Brocast("model_fish_3d_query_geted_award_pool_num")
    else
        Network.SendRequest("fish_3d_query_geted_award_pool_num")
    end
end

function M.StopSendTime()
    if send_time then
        send_time:Stop()
        send_time = nil
    end
end

function M.SendJCData()
    if M.isLogined then
        Network.SendRequest("fish_3d_get_award_pool_num")
    end
end

function M.on_get_award_pool_num(_, data)
    if data.result == 0 then
        this.m_data.award_pool = data.award_pool
        this.m_data.all_award_pool = 0
        this.m_data.award_pool_map = this.m_data.award_pool_map or {}
        for k,v in ipairs(data.award_pool) do
            this.m_data.all_award_pool = this.m_data.all_award_pool + v.award_num
            this.m_data.award_pool_map[v.game_id] = v.award_num
        end
        Event.Brocast("model_get_award_pool_num_msg", {is_one=this.m_data.is_one})
        Event.Brocast("enter_model_get_award_pool_num_msg", {award = this.m_data.all_award_pool})
        this.m_data.is_one = false
    end
end

-- 获取奖池大小 根据游戏ID
function M.GetAwardPoolByGameID(id)
    if this.m_data and this.m_data.award_pool_map and this.m_data.award_pool_map[id] then
        return tonumber(this.m_data.award_pool_map[id])
    end
    return 0
end
-- 获取总奖池
function M.GetAwardPoolAll()
    if this.m_data then
        return this.m_data.all_award_pool or 0
    end
    return 0
end


function M.get_award_pool_award(_,data)
    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiangli3.audio_name)
    Event.Brocast("global_select_top_index_msg",{gotoui = M.key})   
    Event.Brocast("now_have_jc_index_msg")   
    BY3DJCAnimManager.PlayAward({award_type=data.award_type, money=data.money})
end


function M.on_query_geted_award_pool_num(_, data)
    this.m_data.time_cbhw = {}
    this.m_data.time_shcc = {}
    this.m_data.award_pool_result = data.result
    if data.result == 0 then
        --可抽奖次数
        this.m_data.data = data.data or 0-- 4545554
        --周末中奖
        this.m_data.money = tonumber(data.money) or 0
        --能否抽奖
        this.m_data.can_lottery = data.can_lottery
        for i,v in ipairs(this.m_data.data) do
             if v == 4 then
                this.m_data.time_cbhw[#this.m_data.time_cbhw +1] = v
            elseif v == 5 then
                this.m_data.time_shcc[#this.m_data.time_shcc +1] = v
            end          
        end
        this.m_data.time = {#this.m_data.time_cbhw , #this.m_data.time_shcc}
        Event.Brocast("get_award_time_num_msg")
        Event.Brocast("ui_button_state_change_msg")
        Event.Brocast("model_fish_3d_query_geted_award_pool_num")
    end
end

--返回周末抽奖次数  大于4 则显示入口
function M.GetZMCJTimeByDataLength()
    local length = #this.m_data.data
    if this.m_data.data then
        if length >= 4 then
            return true
        else
            return false
        end
    end
end

---是否为周末
function M.IsZM()
  local time = os.time()
  local week_day = os.date("*t" , time).wday
    if week_day == 1 then
        return true
    else
        return false
    end
end

--周末抽奖次数
function M.GetZMCJTime()   
    return this.m_data.time 
end

--周末总奖池
function M.GetZMJCAward()
    return this.m_data.money or 0
end

function M.get_lottery_pool_num(data)
    this.m_data.zm_award = data
end

--返回每个场次中奖次数
function  M.GetGameZJTime()
    if FishingModel.game_id == 4 then
        return #this.m_data.time_cbhw
    else
        return #this.m_data.time_shcc
    end
end

--获取当前周数
function M.GetCurrWeekIndex()
    local index 
    -- if M.IsZM() then
    --     index = os.date("%W") - 1
    -- else
    --     index = os.date("%W")
    -- end
    index = os.date("%W")
    return index
end


function M.GetSumTime()
    if table_is_null(this.m_data.data) then
        return 0 
    else
        return #this.m_data.data
    end
end

--能否抽奖 一开始是能抽奖就进入游戏创建界面 后调整为常态
function M.IsCreateZMCJPanel() 
    if this.m_data.can_lottery == 0 then
        return false
    elseif this.m_data.can_lottery == 1 then
        return true
    else
        return false
    end
end

function M.on_fishing_ready_finish()
    if M.IsCreateZMCJPanel() and this.m_data.is_one_enter_1 and (FishingModel.game_id == 4 or FishingModel.game_id == 5)  then
        BY3DJCZMCDJPanel.Create()
    end
    this.m_data.is_one_enter_1 = false
end

function M.GetRulseConfig()
    return pms_rules_config
end
