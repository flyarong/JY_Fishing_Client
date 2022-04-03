-- 创建时间:2020-07-13
-- Act_022_WYZJFManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_024_WYZJFManager = {}
local M = Act_024_WYZJFManager
M.key = "act_024_wyzjf"
M.special_task_id = 21358 
M.task_config = {
	[21351] = {name = "3D捕鱼中用500及以上炮倍击杀3条彩金鱼",award = {{text = "1000金币",image = "pay_icon_gold2"}},jf_award = {text = "2",image = "sxshl_icon_jf"},goto_ui = "game_Fishing3DHall"},
	
	[21352] = {name = "3D捕鱼中用500及以上炮倍击杀5条活动鱼",award = {{text = "2000金币",image = "pay_icon_gold2"}},jf_award = {text = "4",image = "sxshl_icon_jf"},goto_ui = "game_Fishing3DHall"},
	
	[21353] = {name = "3D捕鱼中用5000及以上炮倍击杀3条美人鱼",award = {{text = "5000金币",image = "pay_icon_gold2"}},jf_award = {text = "6",image = "sxshl_icon_jf"},goto_ui = "game_Fishing3DHall"},
	
	[21354] = {name = "3D捕鱼中用5000及以上炮倍击杀2条深海狂鲨",award = {{text = "10000金币",image = "pay_icon_gold2"}},jf_award = {text = "10",image = "sxshl_icon_jf"},goto_ui = "game_Fishing3DHall"},
	
	[21355] = {name = "3D捕鱼开炮抽红包，累计获得300及以上的福利券",award = {{text = "60000金币",image = "pay_icon_gold2"}},jf_award = {text = "60",image = "sxshl_icon_jf"},goto_ui = "game_Fishing3DHall"},

	[21356] = {name = "水果消消乐用24万及以上档次出现1次幸运时刻",award = {{text = "50000金币",image = "pay_icon_gold2"}},jf_award = {text = "50",image = "sxshl_icon_jf"},goto_ui = "game_Eliminate"},

	[21357] = {name = "水浒消消乐用24万及以上档次累计召唤出3次英雄",award = {{text = "50000金币",image = "pay_icon_gold2"}},jf_award = {text = "50",image = "sxshl_icon_jf"},goto_ui = "game_EliminateSH"},
}

GameButtonManager.ExtLoadLua(M.key,"Act_024_WYZJFPanel")
local this
local lister

-- 是否有活动
function M.IsActive()
    --活动的开始与结束时间
    -- local e_time = 1595892600
    -- local s_time = 1596470399
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
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.IsActive() then
            return Act_024_WYZJFPanel.Create(parm.parent)
        end
    end 
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if  M.IsAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local user_id = MainModel.UserInfo and MainModel.UserInfo.user_id or ""
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. user_id, 0))))
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
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_024_WYZJFManager
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

function M.on_model_task_change_msg(data)
    --dump(data,"<color=yellow>+++++++++++++++++++++++++</color>")
    if M.task_config[data.id] or data.id == M.special_task_id then
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
    end
end

function M.GetRefreshTime()
    local data = GameTaskModel.GetTaskDataByID(M.special_task_id)
    --dump(data,"<color=yellow>++++++++++++++++</color>")
    if data then
        return data.task_round - 1
    end
    return 0
end

function M.IsAwardCanGet()
    for k,v in pairs(M.task_config) do
        local data = GameTaskModel.GetTaskDataByID(k)
        if data and data.award_status == 1 then
            return true 
        end
    end
    return false
end