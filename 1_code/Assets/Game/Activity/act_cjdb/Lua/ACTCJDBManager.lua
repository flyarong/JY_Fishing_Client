-- 创建时间:2021-05-17
-- ACTCJDBManager 管理器

local basefunc = require "Game/Common/basefunc"
ACTCJDBManager = {}
local M = ACTCJDBManager
M.key = "act_cjdb"
local config = GameButtonManager.ExtLoadLua(M.key, "act_cjdb_config")
local config_xybx = GameButtonManager.ExtLoadLua(M.key, "act_cjdb_xybx_config")
GameButtonManager.ExtLoadLua(M.key, "ACTCJDBPanel")
GameButtonManager.ExtLoadLua(M.key, "ACTCJDBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ACTCJDBPathPrefab")
GameButtonManager.ExtLoadLua(M.key, "ACTCJDBRYSZBuyPrefab")
GameButtonManager.ExtLoadLua(M.key, "ACTCJDBRYSZUsePrefab")
GameButtonManager.ExtLoadLua(M.key, "ACTCJDBBXPanel")
GameButtonManager.ExtLoadLua(M.key, "ACTCJDB_box_prefab")
GameButtonManager.ExtLoadLua(M.key, "ACTCJDBHelpPrefab")


local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time=M.GetActEndtime()
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
        return ACTCJDBPanel.Create(parm.parent, parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return ACTCJDBEnterPrefab.Create(parm.parent)
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

    lister["super_treasure_query_base_info_response"] = this.on_super_treasure_query_base_info
    lister["super_treasure_buy_dice_response"] = this.on_super_treasure_buy_dice
    lister["super_treasure_use_renyi_dice_response"] = this.on_super_treasure_use_renyi_dice
    lister["super_treasure_use_normal_dice_response"] = this.on_super_treasure_use_normal_dice
end

function M.Init()
	M.Exit()

	this = ACTCJDBManager
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
    for k,v in ipairs(config.config) do
        this.UIConfig.config[v.group] = v
    end
    this.UIConfig.map_config = {}
    for k,v in ipairs(config.map) do
        this.UIConfig.map_config[v.group] = this.UIConfig.map_config[v.group] or {}
        this.UIConfig.map_config[v.group][#this.UIConfig.map_config[v.group] + 1] = v
    end

    this.UIConfig.endTime = 1628265599
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetUIConfigByTag(group)
    return this.UIConfig.config[group]
end
function M.GetMapConfigByGroup(group)
    return this.UIConfig.map_config[group]
end
function M.GetAllConfigByXYBX(group)
    if group==1 then
        return config_xybx.award_1
    end
    return config_xybx.award_2
end
function M.GetActEndtime()
    return this.UIConfig.endTime
end
-- 网络请求
function M.QueryBaseData(_type)
        Network.SendRequest("super_treasure_query_base_info",{type = _type}, "查询数据")
end
function M.on_super_treasure_query_base_info(_, data)
    dump(data,"<color=yellow>+++on_super_treasure_query_base_info+++</color>")
    if data.result == 0 then
        this.m_data.base_info = this.m_data.base_info or {}
        this.m_data.base_info[data.type] = this.m_data.base_info[data.type] or {}
        this.m_data.base_info[data.type].location = data.location + 1
        this.m_data.base_info[data.type].dice_use_num = data.dice_use_num
    end
    Event.Brocast("model_super_treasure_query_base_info_msg", data.result)
end
function M.GetBaseData(_type)
    return this.m_data.base_info[_type]
end
-- 任意骰子的可购买次数
function M.GetAnyDiceBuyCount(_type)
    local dd = M.GetBaseData(_type)
    local max_count = this.UIConfig.config[_type].vip_rysz[VIPManager.get_vip_level()] or 0
    return max_count - dd.dice_use_num
end
-- 任意骰子的可购买次数
function M.GetAnyDiceMaxCount(_type)
    local dd = M.GetBaseData(_type)
    local max_count = this.UIConfig.config[_type].vip_rysz[VIPManager.get_vip_level()] or 0
    return max_count
end

-- 任意骰子的可使用次数
function M.GetAnyDiceUseCount(_type)
    local kk = "prop_any_dice_2"
    if _type == 1 then
        kk = "prop_any_dice_1"
    else
        kk = "prop_any_dice_2"
    end
    return GameItemModel.GetItemCount(kk)
end

function M.on_super_treasure_buy_dice(_, data)
    dump(data,"<color=yellow>+++on_super_treasure_buy_dice+++</color>")
    if data.result == 0 then
        this.m_data.base_info[data.type].dice_use_num = this.m_data.base_info[data.type].dice_use_num + 1
    end
    Event.Brocast("model_super_treasure_buy_dice_msg", data.result)
end
function M.on_super_treasure_use_renyi_dice(_, data)
    if data.result == 0 then
        Event.Brocast("model_super_treasure_use_dice_msg", {is_any=true, dot=data.dot, location=data.location + 1})
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.on_super_treasure_use_normal_dice(_, data)
    dump(data,"<color=yellow>+++on_super_treasure_use_normal_dice+++</color>")
    if data.result == 0 then
        Event.Brocast("model_super_treasure_use_dice_msg", {is_any=false, dot=data.dot, location=data.location + 1})
    else
        HintPanel.ErrorMsg(data.result)
    end    
end

