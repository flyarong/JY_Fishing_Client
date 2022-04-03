-- 创建时间:2021-10-10
-- Act_062_HGHDManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_062_HGHDManager = {}
local M = Act_062_HGHDManager
M.key = "act_062_hghd"
GameButtonManager.ExtLoadLua(M.key, "Act_062_HGQDFirstOpenPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_062_HGLYPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_062_HGLYItemBase")
GameButtonManager.ExtLoadLua(M.key, "Act_062_HGTQPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_062_HGQDPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_062_HGQDItemBase")
GameButtonManager.ExtLoadLua(M.key, "Act_062_CZLBPanel")
local config = GameButtonManager.ExtLoadLua(M.key, "act_062_czlb_config").config

local this
local lister
M.ly_gift_id = 10641
M.mrlb_task = 30041
M.buy_task_id = 30043
M.qd_config = {
    [1] = {
        condi_key = "actp_own_task_p_come_back_task1",
        task_id = 30036,
        award_img = {{"ty_icon_jb_6y","3dby_icon_p3","3dby_btn_sd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},
                    {"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},
                    {"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},},
        award_txt = {{"金币1万","金币使者炮台7天","锁定*1"},{"金币1万","锁定*3","冰冻*3"},{"金币1万","锁定*4","冰冻*4"},
                    {"金币2万","锁定*5","冰冻*5"},{"金币2万","锁定*6","冰冻*6"},{"金币2万","锁定*8","冰冻*8"},
                    {"金币5万","锁定*10","冰冻*10"}},
    },
    [2] = {
        condi_key = "actp_own_task_p_come_back_task2",
        task_id = 30037,
        award_img = {{"ty_icon_jb_6y","3dby_icon_p5","3dby_btn_bd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},
                    {"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},
                    {"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},},
        award_txt = {{"金币2万","死灵之光炮台7天","冰冻*2"},{"金币3万","锁定*3","冰冻*3"},{"金币4万","锁定*4","冰冻*4"},
                    {"金币5万","锁定*5","冰冻*5"},{"金币6万","锁定*6","冰冻*6"},{"金币7万","锁定*8","冰冻*8"},
                    {"金币8万","锁定*10","冰冻*10"}},
    },
    [3] = {
        condi_key = "actp_own_task_p_come_back_task3",
        task_id = 30038,
        award_img = {{"ty_icon_jb_6y","3dby_icon_p6","3dby_btn_bd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},
                    {"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},{"ty_icon_jb_6y","3dby_btn_sd","3dby_btn_bd"},
                    {"ty_icon_jb_15y","3dby_btn_sd","3dby_btn_bd"},},
        award_txt = {{"金币5万","神龙之力炮台7天","冰冻*5"},{"金币6万","锁定*6","冰冻*6"},{"金币7万","锁定*8","冰冻*8"},
                    {"金币8万","锁定*10","冰冻*10"},{"金币9万","锁定*12","冰冻*12"},{"金币10万","锁定*15","冰冻*15"},
                    {"金币20万","锁定*20","冰冻*20"}},
    },
}

M.ly_config = {
    [1] = {
        task_id1 = 30039,
        task_id2 = 30040,
        level = 1,
        kill_num = 10,
        kill_num_txt = "10",
        award_txt = {"1万金币","100万金币","20福利券"},
        award_img = {"ty_icon_jb_6y","ty_icon_jb_30y","ty_icon_flq1"},
    },
    [2] = {
        task_id1 = 30039,
        task_id2 = 30040,
        level = 2,
        kill_num = 30,
        kill_num_txt = "30",
        award_txt = {"5锁定","100万金币","30福利券"},
        award_img = {"3dby_btn_sd","ty_icon_jb_30y","ty_icon_flq1"},
    },
    [3] = {
        task_id1 = 30039,
        task_id2 = 30040,
        level = 3,
        kill_num = 50,
        kill_num_txt = "50",
        award_txt = {"5冰冻","100万金币","50福利券"},
        award_img = {"3dby_btn_bd","ty_icon_jb_30y","ty_icon_flq2"},
    },
    [4] = {
        task_id1 = 30039,
        task_id2 = 30040,
        level = 4,
        kill_num = 100,
        kill_num_txt = "100",
        award_txt = {"1万金币","10万金币","50福利券"},
        award_img = {"ty_icon_jb_6y","ty_icon_jb_15y","ty_icon_flq2"},
    },
    [5] = {
        task_id1 = 30039,
        task_id2 = 30040,
        level = 5,
        kill_num = 200,
        kill_num_txt = "200",
        award_txt = {"1.5万金币","10万金币","50福利券"},
        award_img = {"ty_icon_jb_6y","ty_icon_jb_15y","ty_icon_flq2"},
    },
    [6] = {
        task_id1 = 30039,
        task_id2 = 30040,
        level = 6,
        kill_num = 500,
        kill_num_txt = "500",
        award_txt = {"2万金币","10万金币","50福利券"},
        award_img = {"ty_icon_jb_6y","ty_icon_jb_15y","ty_icon_flq2"},
    },
    [7] = {
        task_id1 = 30039,
        task_id2 = 30040,
        level = 7,
        kill_num = 1000,
        kill_num_txt = "1k",
        award_txt = {"2.5万金币","10万金币","50福利券"},
        award_img = {"ty_icon_jb_6y","ty_icon_jb_15y","ty_icon_flq2"},
    },
    [8] = {
        task_id1 = 30039,
        task_id2 = 30040,
        level = 8,
        kill_num = 2000,
        kill_num_txt = "2k",
        award_txt = {"5万金币","20万金币","100福利券"},
        award_img = {"ty_icon_jb_6y","ty_icon_jb_18y","ty_icon_flq3"},
    },
}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.GetEndTime()
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_come_back_courtesy"
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
    if parm.goto_scene_parm == "first_open_panel" then
        return Act_062_HGQDFirstOpenPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "hgqd_panel" then
        return Act_062_HGQDPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "hgly_panel" then
        return Act_062_HGLYPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "hgtq_panel" then
        return Act_062_HGTQPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "czlb_panel" then
        return Act_062_CZLBPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then
        if parm.goto_scene_parm and M.IsAwardCanGet(parm.goto_scene_parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
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
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key ,goto_scene_parm = "hgqd_panel"})
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key ,goto_scene_parm = "hgly_panel"})
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key ,goto_scene_parm = "hgtq_panel"})
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key ,goto_scene_parm = "czlb_panel"})
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
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
    lister["model_task_change_msg"] = this.on_model_task_change_msg
end

function M.Init()
	M.Exit()

	this = Act_062_HGHDManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
        M.StopTimer()
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    local check_func = function(_permission_key)
        local a, b = GameButtonManager.RunFun({ gotoui = "sys_qx", _permission_key = _permission_key, is_on_hint = true }, "CheckCondition")
        if a and b then
            return true
        end
    end
    for i = 1, #config do
        if check_func(config[i].permission) then
            this.m_data.cur_lv = i
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.TimerToRefresh()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetEndTime()
    return SYSQXManager.GetRegressTime() + 604800
end

function M.IsAwardCanGet(type)
    if type == "hgqd_panel" then
        local tab = {}
        for k,v in pairs(M.qd_config) do
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condi_key, is_on_hint = true}, "CheckCondition")
            if a and b then
                tab = v
                break
            end
        end
        local data = GameTaskModel.GetTaskDataByID(tab.task_id)
        if data and data.award_status == 1 then
            return true
        end
    elseif type == "hgly_panel" then
        local data1 = GameTaskModel.GetTaskDataByID(M.ly_config[1].task_id1)
        local data2 = GameTaskModel.GetTaskDataByID(M.ly_config[1].task_id2)
        if (data1 and data1.award_status == 1) or (M.CheckGiftIsBoughtByTaskID() and data2 and data2.award_status == 1) then
            return true
        end
    elseif type == "czlb_panel" then
        local taskData = GameTaskModel.GetTaskDataByID(M.mrlb_task)
        if taskData and taskData.award_status == 1 then
            return true
        end
    end
    return false
end

function M.GetCurCfg()
    return config[this.m_data.cur_lv]
end

function M.GetLv()
    return this.m_data.cur_lv
end

function M.on_model_query_task_data_response()
    -- dump("<color=white>JJJJJJJRLB+++111++++on_model_query_task_data_response+++++++</color>")
    local data = GameTaskModel.GetTaskDataByID()
    if data then
        for k,v in pairs(data) do
            if data.id == M.mrlb_task then
                Event.Brocast("global_hint_state_change_msg", { gotoui = M.key , goto_scene_parm = "czlb_panel" })
            end
        end
    end
end

function M.on_model_task_change_msg(data)
    if data and data.id then
        if data.id == M.mrlb_task then
            Event.Brocast("global_hint_state_change_msg", { gotoui = M.key , goto_scene_parm = "czlb_panel" })
        elseif data.id == M.ly_config[1].task_id1 or data.id == M.ly_config[1].task_id2 then
            Event.Brocast("global_hint_state_change_msg", { gotoui = M.key , goto_scene_parm = "hgly_panel" })
        end
    end
end

function M.CheckGiftIsBoughtByTaskID()
    local data = GameTaskModel.GetTaskDataByID(M.buy_task_id)
    if data and data.now_process == 1 then
        return true
    end
    return false
end

function M.TimerToRefresh()
    M.StopTimer()
    this.m_data.timer_to_refresh = Timer.New(function ()
        --dump("<color=yellow><size=15>++++++++++计时中++++++++++</size></color>")
        if os.time() >= M.GetEndTime() then
            --dump("<color=yellow><size=15>++++++++++时间到了++++++++++</size></color>")
            Event.Brocast("ui_button_data_change_msg", {key = "sys_act_base",goto_type = "hghd"})
            Event.Brocast("ActivityYearPanel_off_msg","hghd")
            M.StopTimer()
        end
    end,1,-1,false)
    this.m_data.timer_to_refresh:Start()
end

function M.StopTimer()
    if this.m_data.timer_to_refresh then
        this.m_data.timer_to_refresh:Stop()
        this.m_data.timer_to_refresh = nil
    end
end