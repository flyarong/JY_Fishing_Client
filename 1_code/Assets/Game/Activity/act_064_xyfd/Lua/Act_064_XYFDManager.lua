-- 创建时间:2021-11-01
-- Act_064_XYFDManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_064_XYFDManager = {}
local M = Act_064_XYFDManager
M.key = "act_064_xyfd"
GameButtonManager.ExtLoadLua(M.key,"Act_064_XYFDEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_064_XYFDPanel")

local this
local lister
local config = {
    [1] = {
        index = 1,
        condi_key = "actp_buy_gift_bag_class_lucky_grab_bag1",
        gift_id = 10667,
        award_img = {"zpg_icon_cc","zpg_icon_yg","zpg_icon_shui"},
        award_txt = {"铲子*9","太阳*10","水滴*48"},
        price_now = 48,
        price_ori = 52,
    },
    [2] = {
        index = 2,
        condi_key = "actp_buy_gift_bag_class_lucky_grab_bag2",
        gift_id = 10668,
        award_img = {"zpg_icon_cc","zpg_icon_yg","zpg_icon_shui"},
        award_txt = {"铲子*18","太阳*25","水滴*88"},
        price_now = 98,
        price_ori = 107,
    },
    [3] = {
        index = 3,
        condi_key = "actp_buy_gift_bag_class_lucky_grab_bag3",
        gift_id = 10669,
        award_img = {"zpg_icon_sc","zpg_icon_cc","zpg_icon_yg"},
        award_txt = {"杀虫剂*1","铲子*28","太阳*50"},
        price_now = 198,
        price_ori = 219,
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
        return Act_064_XYFDPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return Act_064_XYFDEnterPrefab.Create(parm.parent, parm.cfg)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        local newtime = tonumber(os.date("%Y%m%d", os.time()))
        local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
        if oldtime ~= newtime then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Red
        end
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
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

    lister["new_day"] = this.on_new_day
    lister["finish_gift_shop"] = this.on_finish_gift_shop--完成礼包购买
    lister["AssetChange"] = this.on_AssetChange
end

function M.Init()
	M.Exit()

	this = Act_064_XYFDManager
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


function M.GetConfig()
    for k,v in pairs(config) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            return v
        end
    end
end

function M.CheckCanShow()
    local tab = M.GetConfig()
    if tab then
        return MainModel.IsCanBuyGiftByID(tab.gift_id)
    end
    return false
end

function M.on_new_day()
    Event.Brocast("ui_button_data_change_msg", { key = M.key })
end

function M.on_finish_gift_shop(id)
    local tab = M.GetConfig()
    if tab and tab.gift_id == id then
        Event.Brocast("ui_button_data_change_msg", { key = M.key })
    end
end

function M.on_AssetChange(data)
    dump(data,"<color>+++++++++++++++on_AssetChange++++++++++++++++++</color>")
    if M.CheckIsShow() and data then
        if MainModel.myLocation == "game_ZPG" then
            if ZPGModel and ZPGModel.data and not table_is_null(ZPGModel.data.my_bet_list) then
                local num = 0
                for k,v in pairs(ZPGModel.data.my_bet_list) do
                    num = num + v
                end
                if MainModel.UserInfo.jing_bi and num and GAME_Di_Bao_limit then
                    if (MainModel.UserInfo.jing_bi + num) < GAME_Di_Bao_limit then
                        Act_064_XYFDPanel.Create()
                    end
                end
            end
        end
    end
end