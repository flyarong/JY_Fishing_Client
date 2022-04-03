-- 创建时间:2021-10-18
-- Act_063_XRHBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_063_XRHBManager = {}
local M = Act_063_XRHBManager
M.key = "act_063_xrhb"
GameButtonManager.ExtLoadLua(M.key, "Act_063_XRHBPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_063_XRHBItemBase")
GameButtonManager.ExtLoadLua(M.key, "Act_063_XRHBEnterPrefab")

local this
local lister
local config = {
    [1] = {
        index = 1,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗5000金币",
        award_txt = {"1福利券","1锁定"},
        award_img = {"ty_icon_flq1","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 5000,
        level = 1,
    },
    [2] = {
        index = 2,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗1万金币",
        award_txt = {"2福利券","2锁定"},
        award_img = {"ty_icon_flq1","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 10000,
        level = 2,
    },
    [3] = {
        index = 3,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗2万金币",
        award_txt = {"3福利券","3锁定"},
        award_img = {"ty_icon_flq1","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 20000,
        level = 3,
    },
    [4] = {
        index = 4,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗5万金币",
        award_txt = {"4福利券","4锁定"},
        award_img = {"ty_icon_flq1","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 50000,
        level = 4,
    },
    [5] = {
        index = 5,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗10万金币",
        award_txt = {"5福利券","5锁定"},
        award_img = {"ty_icon_flq1","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 100000,
        level = 5,
    },
    [6] = {
        index = 6,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗30万金币",
        award_txt = {"6福利券","6锁定"},
        award_img = {"ty_icon_flq1","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 300000,
        level = 6,
    },
    [7] = {
        index = 7,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗50万金币",
        award_txt = {"8福利券","7锁定"},
        award_img = {"ty_icon_flq1","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 500000,
        level = 7,
    },
    [8] = {
        index = 8,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗100万金币",
        award_txt = {"10福利券","8锁定"},
        award_img = {"ty_icon_flq1","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 1000000,
        level = 8,
    },
    [9] = {
        index = 9,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗200万金币",
        award_txt = {"20福利券","9锁定"},
        award_img = {"ty_icon_flq2","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 2000000,
        level = 9,
    },
    [10] = {
        index = 10,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗500万金币",
        award_txt = {"30福利券","10锁定"},
        award_img = {"ty_icon_flq3","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 5000000,
        level = 10,
    },
    [11] = {
        index = 11,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗1000万金币",
        award_txt = {"50福利券","11锁定"},
        award_img = {"ty_icon_flq4","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 10000000,
        level = 11,
    },
    [12] = {
        index = 12,
        task_id = 30044,
        task_txt = "在3D捕鱼中累计消耗2000万金币",
        award_txt = {"100福利券","12锁定"},
        award_img = {"ty_icon_flq5","3dby_btn_sd"},
        gotoUI = "game_Fishing3DHall",
        need = 20000000,
        level = 12,
    },
}

-- 是否有活动
function M.IsActive(parm)
    -- 活动的开始与结束时间
    local e_time = M.GetEndTime()
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
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
        return Act_063_XRHBEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return Act_063_XRHBPanel.Create(parm.parent)
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

    lister["model_task_change_msg"] = this.on_model_task_change_msg
end

function M.Init()
	M.Exit()

	this = Act_063_XRHBManager
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


function M.GetEndTime()
    local end_t = MainModel.UserInfo.first_login_time + 604800
    return end_t
end

function M.IsAwardCanGet()
    for k,v in pairs(config) do
        local data = GameTaskModel.GetTaskDataByID(v.task_id)
        if data and data.award_status == 1 then
            return true
        end
    end
    return false
end

function M.GetConfig()
    return basefunc.deepcopy(config)
end

function M.get_count(task_id)
    local len = 0
    for k,v in pairs(config) do
        if task_id == v.task_id then
            len = len + 1
        end
    end
    return len
end

function M.on_model_task_change_msg(data)
    if data then
        for k,v in pairs(config) do
            if v.task_id == data.id then
                Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
                break
            end
        end
    end
end