-- 创建时间:2020-11-25
-- FishFarmJlSpringManager 管理器

local basefunc = require "Game/Common/basefunc"
FishFarmJlSpringManager = {}
local M = FishFarmJlSpringManager
M.key = "sys_fishfarm_jlspring"

GameButtonManager.ExtLoadLua(M.key, "FishFarmNoCanCJPanel")
GameButtonManager.ExtLoadLua(M.key, "JLSpringPanel")
GameButtonManager.ExtLoadLua(M.key, "AwardPrefab_FishFarm")

local config = SysItemManager.item_config
local config_lottery = GameButtonManager.ExtLoadLua(M.key, "fishbowl_lottery")
local this
local lister

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
        JLSpringPanel.Create()
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
    lister["fishbowl_lottery_info_response"] = this.on_fishbowl_lottery_info_response
end

function M.Init()
	M.Exit()

	this = FishFarmJlSpringManager
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

    this.UIConfig.award_map = {} 
    this.UIConfig.award_list = {}  
    this.UIConfig.big_award_list_pt = {}
    this.UIConfig.big_award_list_gj = {}
    this.UIConfig.big_award_map_pt = {}
    this.UIConfig.big_award_map_gj = {}

    for k,v in ipairs(config.config) do
        this.UIConfig.award_list[k] = v
        this.UIConfig.award_map[v.item_key] = v
    end

    for i,v in ipairs(config_lottery.lottery10) do
        if v.id == 1 then
            this.UIConfig.big_award_list_pt[i] = v.no
        else
            this.UIConfig.big_award_list_gj[#this.UIConfig.big_award_list_gj + 1] = v.no
        end
    end

    for i,v in ipairs(config_lottery.award) do
        if v.id == 1 then
            this.UIConfig.big_award_map_pt[v.asset_type] = v.no
        else
            this.UIConfig.big_award_map_gj[v.asset_type] = v.no
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


function M.GetAwardConfigByAwardID(_type)
    return this.UIConfig.award_map[_type]
end

function M.on_fishbowl_lottery_info_response(_, data)
    this.m_data.cj = {}
    this.m_data.cj.pt = {}
    this.m_data.cj.gj = {}
    dump(data, "<color=red>EEE on_fishbowl_lottery_response</color>")
    if data.result == 0 then
        this.m_data.cj.pt = data.data[1]
        this.m_data.cj.gj = data.data[2]
        if data.data[1] and data.data[1].ad_time then
            this.m_data.time = data.data[1].ad_time
        else
            this.m_data.time = 0
        end 
        Event.Brocast("have_on_fishbowl_lottery_info_msg")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.GetCDTime()
    dump(this.m_data.time,"<color=red>ssssssssssssssssssssssssssssssssss</color>")
    if this.m_data.time then
        return this.m_data.time 
    end
    return 0
end

function M.GetNum()
    return this.m_data.cj.pt.ad or 0
end

function M.GetCJTime()
    return  this.m_data.cj
end

function M.GetSpringBuyInfor()
    return config_lottery.buy
end

function M.GetBigAwardPTList()
    return  this.UIConfig.big_award_list_pt
end

function M.GetBigAwardGJList()
    return  this.UIConfig.big_award_list_gj
end

function M.GetAwardType(_type)
    if _type == 1 then
        return this.UIConfig.big_award_map_pt
    else
        return this.UIConfig.big_award_map_gj
    end
end