-- 创建时间:2021-01-04
-- SYS_JBPManager 管理器

local basefunc = require "Game/Common/basefunc"
SYS_JBPManager = {}
local M = SYS_JBPManager
M.key = "sys_jbp"
GameButtonManager.ExtLoadLua(M.key,"SYS_JBPPanel")
GameButtonManager.ExtLoadLua(M.key,"SYS_JBP_JYFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"SYS_JBP_TIPPanel")

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time = 1611014400
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if PlayerPrefs.GetInt(M.key..MainModel.UserInfo.user_id.."jbp",0) == 0 or VIPManager.get_vip_level() > 0 then
        return false
    end

    -- 对应权限的key
    local _permission_key-- = "treasure_bowl"
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
    if parm.goto_scene_parm == "jyfl_enter" then
        return SYS_JBP_JYFLEnterPrefab.Create(parm.parent, parm)
    elseif parm.goto_scene_parm == "panel" then
        return SYS_JBPPanel.Create(parm.parent, parm)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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

    lister["query_treasure_bowl_data_response"] = this.on_query_treasure_bowl_data_response
    lister["get_treasure_bowl_award_response"] = this.on_get_treasure_bowl_award_response
    lister["treasure_bowl_info_max_change_msg"] = this.on_treasure_bowl_info_max_change_msg
    lister["model_vip_upgrade_change_msg"] = this.on_model_vip_upgrade_change_msg
    lister["EnterScene"] = this.OnEnterScene
end

function M.Init()
	M.Exit()

	this = SYS_JBPManager
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
    this.is_log_tip = true
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.QueryJBPData()
	end
end
function M.OnReConnecteServerSucceed()
end


function M.QueryJBPData()
    if (not this.jbp_value) or not this.time or (os.time() - this.time > 5) then
        NetMsgSendManager.SendMsgQueue("query_treasure_bowl_data")
    else
        Event.Brocast("jbp_data_has_come_msg")
    end
end

function M.on_query_treasure_bowl_data_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_query_treasure_bowl_data_response++++++++++</size></color>")
    if data and data.result == 0 then
        this.time = os.time()
        this.jbp_value = data.value
        if data.value > 0 then
            PlayerPrefs.SetInt(M.key..MainModel.UserInfo.user_id.."jbp",1)
        end
        Event.Brocast("jbp_data_has_come_msg")
        if M.IsCanGet() then
            M.GetJBPAward()
        end
    end
end

function M.GetJBPAward()
    Network.SendRequest("get_treasure_bowl_award")
end

function M.on_get_treasure_bowl_award_response(_,data)
    --dump(data,"<color=yellow><size=15>++++++++++on_get_treasure_bowl_award_response++++++++++</size></color>")
    if data and data.result == 0 then
        this.jbp_value = 0
        PlayerPrefs.SetInt(M.key..MainModel.UserInfo.user_id.."jbp",0)
        Event.Brocast("jbp_award_had_got_msg")
    end
end

function M.on_treasure_bowl_info_max_change_msg(_,data)
    --dump(data,"<color=yellow><size=15>++++++++++on_treasure_bowl_info_max_change_msg++++++++++</size></color>")
    dump(MainModel.UserInfo.vip_level,"<color=yellow><size=15>++++++++++vip_level++++++++++</size></color>")
    if data then
        this.jbp_value = data.value
        if this.jbp_value > 0 then
            PlayerPrefs.SetInt(M.key..MainModel.UserInfo.user_id.."jbp",1)
        end
        if M.CheckIsShow() then      
            SYS_JBP_TIPPanel.Create()
        end
        Event.Brocast("jbp_award_had_change_msg")
    end
end

function M.CheckIsMoreThanLimit()
    this.jbp_value = this.jbp_value or 0
    return this.jbp_value > 0
end

function M.GetCurJBPJing_bi()
    return this.jbp_value
end

function M.IsCanGet()
    if VIPManager.get_vip_level() > 0 and M.CheckIsMoreThanLimit() then
        return true
    end
    return false
end

function M.on_model_vip_upgrade_change_msg()
    dump("<color=yellow><size=15>++++++++++on_model_vip_upgrade_change_msg++++++++++</size></color>")
    if M.IsCanGet() then
        M.GetJBPAward()
    end
end

function M.OnEnterScene()
    if MainModel.cur_myLocation == "game_Hall" and this.is_log_tip then
        if VIPManager.get_vip_level() <= 0 and M.CheckIsMoreThanLimit() then
            this.is_log_tip = false
            SYS_JBP_TIPPanel.Create()
        end
    end
end