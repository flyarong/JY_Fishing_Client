-- 创建时间:2021-09-26
-- Act_061_XYHLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_061_XYHLManager = {}
local M = Act_061_XYHLManager
M.key = "act_061_xyhl"
GameButtonManager.ExtLoadLua(M.key, "Act_061_XYHLChild1Panel")
GameButtonManager.ExtLoadLua(M.key, "Act_061_XYHLChild2Panel")
GameButtonManager.ExtLoadLua(M.key, "Act_061_XYHLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_061_XYHLPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_061_XYHLTaskItem")
GameButtonManager.ExtLoadLua(M.key, "Act_061_XYHLBDIDPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_061_XYHLPageItemBase")

local this
local lister
M.is_debug = false
local task_config = {
    [1] = {
        [1] = {
            index = 1,
            task_id = 1000798,
            task_desc = "成功绑定新游戏ID",
            award_img = "ty_icon_flq3",
            award_txt = "x300",
            need_process = 1,
            tip_txt = "联系客服QQ：4008882620可直升VIP3",
        },
        [2] = {
            index = 2,
            task_id = 1000799,
            task_desc = "在新游中累计赢金100万",
            award_img = "ty_icon_flq1",
            award_txt = "x100",
            need_process = 1000000,
            level = 1,
        },
        [3] = {
            index = 3,
            task_id = 1000799,
            task_desc = "在新游中累计赢金200万",
            award_img = "ty_icon_flq2",
            award_txt = "x100",
            need_process = 2000000,
            level = 2,
        },
        [4] = {
            index = 4,
            task_id = 1000799,
            task_desc = "在新游中累计赢金500万",
            award_img = "ty_icon_flq2",
            award_txt = "x200",
            need_process = 5000000,
            level = 3,
        },
        [5] = {
            index = 5,
            task_id = 1000799,
            task_desc = "在新游中累计赢金2000万",
            award_img = "ty_icon_flq3",
            award_txt = "x300",
            need_process = 20000000,
            level = 4,
        },
        [6] = {
            index = 6,
            task_id = 1000799,
            task_desc = "在新游中累计赢金5000万",
            award_img = "ty_icon_flq4",
            award_txt = "x500",
            need_process = 50000000,
            level = 5,
        },
        [7] = {
            index = 7,
            task_id = 1000799,
            task_desc = "在新游中累计赢金1亿",
            award_img = "ty_icon_flq5",
            award_txt = "x1000",
            need_process = 100000000,
            level = 6,
        },
    },
    [2] = {
        [1] = {
            index = 1,
            task_id = 1000800,
            task_desc = "在新游中累计充值10元",
            award_img = "ty_icon_flq1",
            award_txt = "x200",
            need_process = 1000,
            level = 1,
            is_money = 1,
        },
        [2] = {
            index = 2,
            task_id = 1000800,
            task_desc = "在新游中累计充值100元",
            award_img = "ty_icon_flq2",
            award_txt = "x500",
            need_process = 10000,
            level = 2,
            is_money = 1,
        },
        [3] = {
            index = 3,
            task_id = 1000800,
            task_desc = "在新游中累计充值500元",
            award_img = "ty_icon_flq3",
            award_txt = "x1000",
            need_process = 50000,
            level = 3,
            is_money = 1,
        },
        [4] = {
            index = 4,
            task_id = 1000800,
            task_desc = "在新游中累计充值1000元",
            award_img = "ty_icon_flq4",
            award_txt = "x1200",
            need_process = 100000,
            level = 4,
            is_money = 1,
        },
        [5] = {
            index = 5,
            task_id = 1000800,
            task_desc = "在新游中累计充值3000元",
            award_img = "ty_icon_flq4",
            award_txt = "x2000",
            need_process = 300000,
            level = 5,
            is_money = 1,
        },
        [6] = {
            index = 6,
            task_id = 1000800,
            task_desc = "在新游中累计充值10000元",
            award_img = "ty_icon_flq5",
            award_txt = "x10000",
            need_process = 1000000,
            level = 6,
            is_money = 1,
        },
    },
}
local page_config = {
    [1] = {
        index = 1,
        left = "新游豪礼",
        right = "Act_061_XYHLChild1Panel",
    },
    [2] = {
        index = 2,
        left = "赢金福利",
        right = "Act_061_XYHLChild2Panel",
    },
    [3] = {
        index = 3,
        left = "充值福利",
        right = "Act_061_XYHLChild2Panel",
    },
}


-- 是否有活动
function M.IsActive(parm)
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (s_time and os.time() < s_time) then
        return false
    end
    if (e_time and os.time() > e_time) and M.TaskIsComplete() then
        return false
    end

    if not this.can_show then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if parm and parm.condi_key then
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
    if parm.goto_scene_parm == "enter" then
        return Act_061_XYHLEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return Act_061_XYHLPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsAwardCanGet() then
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

    lister["xyhl_set_new_game_player_id_response"] = this.on_xyhl_set_new_game_player_id_response
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["xyhl_get_new_game_player_info_response"] = this.on_xyhl_get_new_game_player_info_response
    lister["model_vip_upgrade_change_msg"] = this.on_model_vip_upgrade_change_msg
end

function M.Init()
	M.Exit()

	this = Act_061_XYHLManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
        M.StopCheckActiveTimer()
        if this.timer then
            this.timer:Stop()
            this.timer = nil
        end
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
        this.timer = Timer.New(function ()
            M.QueryMainData()
        end,1,1,false)
        this.timer:Start()
        M.CheckActiveTimer()
	end
end
function M.OnReConnecteServerSucceed()
end


function M.BDID(str)
    if M.is_debug then
        Event.Brocast("xyhl_set_new_game_player_id_response","xyhl_set_new_game_player_id_response",{result = 0,id = 888888})
    else
        this.m_data.send_id = str
        Network.SendRequest("xyhl_set_new_game_player_id",{new_game_player_id = str})
    end
end

function M.on_xyhl_set_new_game_player_id_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_bdid_msg++++++++++</size></color>")
    if data.result == 0 then
        this.m_data.new_id = this.m_data.send_id
        this.m_data.new_vip = data.new_game_player_vip_level
        Event.Brocast("061_xyhl_bdid_success_msg")
        LittleTips.Create("绑定成功")
    else
        this.m_data.send_id = nil
        LittleTips.Create("ID错误，请核实后再输入")
    end
end

function M.GetTaskConfig()
    return task_config
end

function M.GetPageConfig()
    return page_config
end

function M.GetNewID()
    return this.m_data.new_id
end

function M.GetNewVIP()
    return this.m_data.new_vip or 0
end

function M.GetNewLJYJ()
    local data = GameTaskModel.GetTaskDataByID(1000799)
    if data then
        return data.now_total_process
    else
        return 0
    end
end

function M.GetNewLJCZ()
    local data = GameTaskModel.GetTaskDataByID(1000800)
    if data then
        return data.now_total_process / 100
    else
        return 0
    end
end

function M.GetWasDownLoad()
    return this.m_data.is_download == 1
end

function M.GetTaskEndTime()
    if M.is_debug then
        return 1632894168
    else
        return (this.m_data.bind_time or 0) + 604800
    end
end

function M.get_count(id)
    local config = M.GetTaskConfig()
    local count = 0
    for k,v in pairs(config) do
        for kk,vv in pairs(v) do
            if vv.task_id == id then
                count = count + 1
            end
        end
    end
    return count
end

function M.IsAwardCanGet()
    for j=1,2 do
        local temp_tab = basefunc.deepcopy(M.GetTaskConfig()[j])
        local config = {}
        for i=1,#temp_tab do
            if temp_tab[i].condi_key then
                local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = temp_tab[i].condi_key, is_on_hint = true}, "CheckCondition")
                if a and b then
                    config[#config + 1] = temp_tab[i]
                end
            else
                config[#config + 1] = temp_tab[i]
            end
        end
        for k,v in pairs(config) do
            local data = GameTaskModel.GetTaskDataByID(v.task_id)
            if data then
                if v.level then
                    local b = basefunc.decode_task_award_status(data.award_get_status)
                    b = basefunc.decode_all_task_award_status(b, data, M.get_count(v.task_id))
                    if b[v.level] == 1 then
                        return true
                    end
                else
                    if data.award_status == 1 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function M.CheckIsCareTask(id)
    for k,v in pairs(M.GetTaskConfig()) do
        for kk,vv in pairs(v) do
            if vv.task_id == id then
                return true
            end
        end
    end
    return false
end

function M.on_model_task_change_msg(data)
    if data and M.CheckIsCareTask(data.id) then
        Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
        Event.Brocast("061_xyhl_task_change_msg")
    end
end

function M.QueryMainData()
    if M.is_debug then
        Event.Brocast("xyhl_get_new_game_player_info_response","xyhl_get_new_game_player_info_response", {is_download = true,new_id = 888888,new_vip = 2,new_ljyj = 555551,new_ljcz = 6})
    else
        Network.SendRequest("xyhl_get_new_game_player_info")
    end
end

function M.on_xyhl_get_new_game_player_info_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++新游豪礼主数据++++++++++</size></color>")
    if data then
        if data.result == 0 then
            this.m_data.is_download = data.is_download
            this.m_data.cpl_p_key = data.cpl_p_key
            this.m_data.new_id = data.new_game_player_id
            this.m_data.new_vip = data.new_game_player_vip_level
            this.m_data.bind_time = data.bind_time
            this.can_show = true
            Event.Brocast("061_xyhl_maindata_had_got_msg")
            Event.Brocast("ui_button_state_change_msg")
        elseif data.result == -1 then
            this.can_show = false
            Event.Brocast("ui_button_state_change_msg")
        end
    end
end

function M.GetCurKey()
    return this.m_data.cpl_p_key
end

function M.TaskIsComplete()
    for j=1,2 do
        local temp_tab = basefunc.deepcopy(M.GetTaskConfig()[j])
        local config = {}
        for i=1,#temp_tab do
            if temp_tab[i].condi_key then
                local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = temp_tab[i].condi_key, is_on_hint = true}, "CheckCondition")
                if a and b then
                    config[#config + 1] = temp_tab[i]
                end
            else
                config[#config + 1] = temp_tab[i]
            end
        end
        for k,v in pairs(config) do
            local data = GameTaskModel.GetTaskDataByID(v.task_id)
            if data then
                if v.level then
                    local b = basefunc.decode_task_award_status(data.award_get_status)
                    b = basefunc.decode_all_task_award_status(b, data, M.get_count(v.task_id))
                    if b[v.level] ~= 2 then
                        return false
                    end
                else
                    if data.award_status ~= 2 then
                        return false
                    end
                end
            end
        end
    end
    return true
end

function M.on_model_vip_upgrade_change_msg()
    local a,vip = GameButtonManager.RunFun({gotoui="vip"}, "get_vip_level")
    if a and vip >= 6 then
        M.QueryMainData()
    end
end

function M.CheckActiveTimer()
    M.StopCheckActiveTimer()
    this.m_data.check_timer = Timer.New(function ()
        if not M.IsActive() then
            Event.Brocast("ui_button_state_change_msg")
            Event.Brocast("act_061_xyhl_is_overtime_msg")
            M.StopCheckActiveTimer()
        end
    end,1,-1,false)
end

function M.StopCheckActiveTimer()
    if this.m_data.check_timer then
        this.m_data.check_timer:Stop()
        this.m_data.check_timer = nil
    end
end