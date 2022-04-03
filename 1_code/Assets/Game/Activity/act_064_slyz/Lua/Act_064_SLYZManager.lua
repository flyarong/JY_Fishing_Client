-- 创建时间:2021-11-01
-- Act_064_SLYZManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_064_SLYZManager = {}
local M = Act_064_SLYZManager
M.key = "act_064_slyz"
GameButtonManager.ExtLoadLua(M.key,"Act_064_SLYZEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_064_SLYZPanel")

local this
local lister
local config = {
    [1] = {
        index = 1,
        game_id = 3,
        gift_id = 10670,
        award_txt = {"狂暴*2","冰冻*5","锁定*8","slyz_imgf_528"},
        award_img = {"3dby_btn_kb","3dby_btn_bd","3dby_btn_sd","ty_icon_yb_3"},
        price = 48,
    },
    [2] = {
        index = 2,
        game_id = 4,
        gift_id = 10671,
        award_txt = {"狂暴*5","冰冻*10","锁定*15","slyz_imgf_1088"},
        award_img = {"3dby_btn_kb","3dby_btn_bd","3dby_btn_sd","ty_icon_yb_4"},
        price = 98,
    },
    [3] = {
        index = 3,
        game_id = 5,
        gift_id = 10672,
        award_txt = {"狂暴*10","冰冻*20","锁定*30","slyz_imgf_5488"},
        award_img = {"3dby_btn_kb","3dby_btn_bd","3dby_btn_sd","ty_icon_yb_5"},
        price = 498,
    },
}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if not M.CheckCanShow() then
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
        return Act_064_SLYZPanel.Create(parm.callback)
    elseif parm.goto_scene_parm == "enter" then
        return Act_064_SLYZEnterPrefab.Create(parm.parent, parm.cfg)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
    if parm.goto_scene_parm == "panel" then
        return Act_064_SLYZPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return Act_064_SLYZEnterPrefab.Create(parm.parent, parm.cfg)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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

    lister["finish_gift_shop"] = this.on_finish_gift_shop--完成礼包购买
end

function M.Init()
	M.Exit()

	this = Act_064_SLYZManager
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
    for k,v in pairs(config) do
        this.UIConfig.config[v.game_id] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetCurConfig()
    return this.UIConfig.config[FishingModel.game_id]
end

function M.CheckCanShow()
    if MainModel.myLocation == "game_Fishing3D" and (FishingModel.game_id == 3 or FishingModel.game_id == 4 or FishingModel.game_id == 5) then
        local config = M.GetCurConfig()
        if MainModel.IsCanBuyGiftByID(config.gift_id) then
            if M.CheckPC() or M.CheckTime() then
                M.MarkTime()
                return true
            end
        end
    end
    return false
end

function M.CheckPC()
    local i = FishingModel.GetPosToSeatno(FishingModel.GetPlayerSeat())
    local data = FishingModel.GetSeatnoToUser(i)
    return data.isPC
end

function M.on_finish_gift_shop(id)
    if MainModel.myLocation == "game_Fishing3D" and (FishingModel.game_id == 3 or FishingModel.game_id == 4 or FishingModel.game_id == 5) then
        local config = M.GetCurConfig()
        if config.gift_id == id then
            Event.Brocast("ui_button_data_change_msg", { key = M.key })
        end
    end
end

function M.MarkTime()
    if (PlayerPrefs.GetInt(MainModel.UserInfo.user_id..M.key..FishingModel.game_id,0) == 0) or (os.time() > PlayerPrefs.GetInt(MainModel.UserInfo.user_id..M.key..FishingModel.game_id,0)) then
        PlayerPrefs.SetInt(MainModel.UserInfo.user_id..M.key..FishingModel.game_id,os.time() + 1800)
    end
end

function M.CheckTime()
    if os.time() <= PlayerPrefs.GetInt(MainModel.UserInfo.user_id..M.key..FishingModel.game_id,0) then
        return true
    end
end