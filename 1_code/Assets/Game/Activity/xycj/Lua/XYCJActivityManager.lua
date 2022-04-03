-- 创建时间:2019-10-15
-- 幸运抽奖管理器
-- 可以存放活动数据，配置，还有广播数据改变的消息

local basefunc = require "Game/Common/basefunc"
XYCJActivityManager = {}
local M = XYCJActivityManager
M.key = "xycj"
GameButtonManager.ExtLoadLua(M.key, "XYCJEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "GameNewXYCJPanel")
GameButtonManager.ExtLoadLua(M.key, "GameXycjAwardPrefab")
GameButtonManager.ExtLoadLua(M.key, "GameXycjDHPrefab")
GameButtonManager.ExtLoadLua(M.key, "XYCJ_LightBKPanel")
GameButtonManager.ExtLoadLua(M.key, "GameNew2XYCJPanel")
local activity_xycj_config = GameButtonManager.ExtLoadLua(M.key, "activity_xycj_config")


local this
local lister
local m_data

function M.IsActive(condi_key)
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = condi_key
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

function M.CheckIsShow(parm)
    return M.IsActive(parm.condi_key)
end
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        return
    end
    
    if parm.goto_scene_parm == "panel" then
        return GameNewXYCJPanel.Create({type=parm.data})
    elseif parm.goto_scene_parm == "enter" then
    	return XYCJEnterPrefab.Create(parm.parent, parm.cfg)
    elseif parm.goto_scene_parm == "pt_cj" then
        return GameNew2XYCJPanel.Create({type=1}, parm.parent)
    elseif parm.goto_scene_parm == "vip_cj" then
        return GameNew2XYCJPanel.Create({type=2}, parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
function M.CheckActivityState(parm)
	
end
-- 活动的提示状态
function M.GetHintState(parm)
	local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString("HallXYCJHintTime" .. MainModel.UserInfo.user_id, 0))))
	local useVipCJTime=PlayerPrefs.GetInt("VipCJTime" .. MainModel.UserInfo.user_id, 0)
    -- dump( MainModel.UserInfo.jing_bi >= 10000000,"<color=red>幸运转盘福利券红点判断1：  </color>")
    -- dump( useVipCJTime<2,"<color=red>幸运转盘福利券红点判断2：  </color>")
    -- dump(  oldtime ~= newtime,"<color=red>幸运转盘福利券红点判断3：  </color>")
    if MainModel.UserInfo.jing_bi >= 10000000 and useVipCJTime<2 and oldtime ~= newtime then
		return ACTIVITY_HINT_STATUS_ENUM.AT_Red
	end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end

function M.model_vip_upgrade_change_msg(vip_data)
	M.UpdateData()
end

function M.SetHintState()
	-- PlayerPrefs.SetString("HallXYCJHintTime" .. MainModel.UserInfo.user_id, os.time())
	Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
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
    lister["model_vip_upgrade_change_msg"] = this.model_vip_upgrade_change_msg

    lister["query_luck_lottery_data_response"] = this.on_query_luck_lottery_data
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response

    lister["AssetChange"] = this.on_AssetChange
    lister["AssetsGetPanelConfirmCallback"] = this.on_AssetsGetPanelConfirmCallback
end

function M.Init()
	M.Exit()

	this = XYCJActivityManager
	this.m_data = {}
    this.m_data.close_task_id = 21070 -- 道具清理任务
	-- 这个逻辑上线时间
	this.sxsj = 1581982200
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
    this.UIConfig.dh_map = {}
    this.UIConfig.parm_map = {}
    for k,v in ipairs(activity_xycj_config.config) do
    	this.UIConfig.award_map[v.type] = this.UIConfig.award_map[v.type] or {}
    	this.UIConfig.award_map[v.type][#this.UIConfig.award_map[v.type] + 1] = v    	
    end
    for k,v in ipairs(activity_xycj_config.show) do
    	this.UIConfig.dh_map[v.type] = this.UIConfig.dh_map[v.type] or {}
    	this.UIConfig.dh_map[v.type][#this.UIConfig.dh_map[v.type] + 1] = v    	
    end
    for k,v in ipairs(activity_xycj_config.parm) do
    	this.UIConfig.parm_map[v.type] = v
    end
end

-- 数据更新
function M.UpdateData()
	print("<color=white>请求幸运抽奖数据</color>")
	Network.RandomDelayedSendRequest("query_luck_lottery_data")
    Network.RandomDelayedSendRequest("query_luck_lottery_data")
end

function M.OnLoginResponse(result)
	if result == 0 then
		M.UpdateData()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_query_luck_lottery_data(_, data)
	 dump(data, "<color=red>on_query_luck_lottery_data</color>")
	if data.result == 0 then
		this.m_data.get_num = data.num
		this.m_data.ptcj_num = data.ptcj_num or 0
		Event.Brocast("model_query_luck_lottery_data")
	end
end

-- 左侧奖励列表
function M.GetAwardListByType(tt)
    return this.UIConfig.award_map[tt]
end
function M.GetCJMoneyByType(tt)
    return this.UIConfig.parm_map[tt]
end
-- 兑换列表
function M.GetDHByType(tt)
    return this.UIConfig.dh_map[tt]
end

function M.QueryCJNum()
    if this.m_data.get_num and this.m_data.ptcj_num then
        Event.Brocast("model_query_luck_lottery_data")
    else
        Network.SendRequest("query_luck_lottery_data", nil, "")
    end
end


function M.on_backgroundReturn_msg()
    Event.Brocast("XYCJManager_on_backgroundReturn_msg")
end

function M.on_model_query_one_task_data_response(data)
    if data and data.id == M.m_data.close_task_id then
        Event.Brocast("model_xycj_ptcj_status_msg")
    end
end
function M.GetData()
    return {ptcj_num = M.m_data.ptcj_num, }
end

function M.IsShowPTCJ()
    if not M.m_data or not M.m_data.ptcj_num then
        return false
    end
    if M.m_data.ptcj_num > 0 then
        return false
    end
    local a,vip = GameButtonManager.RunFunExt("vip", "get_vip_level")
    if a and vip then
        if vip > 0 then
            local task = GameTaskModel.GetTaskDataByID(M.m_data.close_task_id)
            if task then
                return true
            else
                Network.SendRequest("query_one_task_data", {task_id = M.m_data.close_task_id})
                return false
            end
        else
            return true
        end
    else
        return false
    end
end

function M.on_AssetChange(data)
    --dump(data,"<color=yellow><size=15>+++++////////++++++++++</size></color>")
    if data.data then
        for i = 1, #data.data, 1 do
            if data.data[i].asset_type=="jing_bi" then
                this.SetHintState()
            elseif data.data[i].asset_type == "prop_xyzp_flqbx" then
                Network.SendRequest("box_exchange",{id = 110,num = 1})
            end
            if data.change_type == "box_exchange_active_award_110" then
                this.flqbx_award = this.flqbx_award or {}
                this.flqbx_award[#this.flqbx_award + 1] = data
                this.flqbx_award[#this.flqbx_award].change_type = "box_exchange_active_award_110_local"
            end
        end
    end
end

function M.ShowFlqbxAward()
    --dump(this.flqbx_award,"<color=yellow><size=15>++++++++++this.flqbx_award++++++++++</size></color>")
    if not table_is_null(this.flqbx_award) then
        for k,v in pairs(this.flqbx_award) do
            Event.Brocast("AssetGet", v)
        end
    end
    this.flqbx_award = nil
end

function M.on_AssetsGetPanelConfirmCallback(data)
    --dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
    if data and data.data and data.data[1] and data.data[1].asset_type then
        if data.data[1].asset_type == "prop_xyzp_flqbx" then
            M.ShowFlqbxAward()
        end
    end
end