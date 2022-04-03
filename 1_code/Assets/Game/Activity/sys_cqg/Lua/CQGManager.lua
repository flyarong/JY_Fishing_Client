-- 创建时间:2020-04-26
-- CQGManager 管理器

local basefunc = require "Game/Common/basefunc"
CQGManager = {}
local M = CQGManager
M.key = "sys_cqg"
CQGManager.ccdw_config = GameButtonManager.ExtLoadLua(M.key,"cqg_ccdw_config")
GameButtonManager.ExtLoadLua(M.key,"CQGEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"CQGPanel")
GameButtonManager.ExtLoadLua(M.key,"CQGGetHintPrefab")

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
        if M.CheckIsShow() then
            return CQGPanel.Create(parm.parent,parm.backcall)
            --[[if not M.panel_map["CQGPanel"] then
                local pre = CQGPanel.Create(parm.parent,parm.backcall)
                M.panel_map["CQGPanel"] = pre
            else
                M.panel_map["CQGPanel"]:MyRefresh()

            end
            return M.panel_map["CQGPanel"]--]]
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return CQGEnterPrefab.Create(parm.parent, parm.cfg)
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


    lister["query_deposit_data_response"] = this.on_query_deposit_data_response
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
end

function M.Init()
	M.Exit()

	this = CQGManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
    M.update_time(false)
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
        if M.IsActive() then
            M.query_data()
        end
	end
end
function M.OnReConnecteServerSucceed()
end


function M.on_backgroundReturn_msg()
    Event.Brocast("CQG_on_backgroundReturn_msg")
end

--[[function M.QueryJingBiData()
    if this.m_data.money and this.m_data.state then
        Event.Brocast("model_cqg_data_change_msg")
    else
        M.query_data()
    end
end--]]

function M.query_data(b)
    if b then
        NetMsgSendManager.SendMsgQueue("query_deposit_data", nil, "")
    else
        NetMsgSendManager.SendMsgQueue("query_deposit_data", nil)
    end
end

function M.on_query_deposit_data_response(_,data)
    dump(data,"<color=green>+++++++++++++++++data+++++++++++++</color>")
    if data.result == 0 then
        --local value = data.money - (this.m_data.money or 0)
        this.m_data.money = data.money or 0
        this.m_data.state = data.state
        M.Refresh()
    end
end


function M.Refresh(value)
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})--刷新enter
    Event.Brocast("model_cqg_data_change_msg",value)--刷新panel
end

function M.IsCanGet()
    if this.m_data.state == 0 then--已经把昨天累计的领取了
        return false--入口提示"明日可领取"
    else
        return true--入口提示"领福利"
    end
end


function M.GetCurData()
    local mm = {}
    if this.m_data then
        mm.money = this.m_data.money or 0
        mm.state = this.m_data.state or 0
    else
        mm.money = 0
        mm.state = 0
    end
    return mm
end

function M.StopUpdateTime()
    if _time then
        _time:Stop()
        _time = nil
    end
end

function M.update_time(b)
    M.StopUpdateTime()
    if b then
        _time = Timer.New(function ()
            M.query_data()
        end, 5, -1, nil, true)
        _time:Start()
    end
end

function M.CheckShowExitAsk()
    local mm = M.GetCurData()
    local data1 = (mm.state ~= 0)
    local data2 = mm.money
    local data3 = function ()
        CQGPanel.Create()
    end
    return data1,data2,data3
end