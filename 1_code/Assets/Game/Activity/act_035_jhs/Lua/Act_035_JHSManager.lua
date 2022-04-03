-- 创建时间:2020-10-30
-- Act_035_JHSManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_035_JHSManager = {}
local M = Act_035_JHSManager
M.key = "act_035_jhs"

Act_035_JHSManager.config = GameButtonManager.ExtLoadLua(M.key, "act_035_jhs_config")
GameButtonManager.ExtLoadLua(M.key, "Act_035_JHSPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_035_JHSEnterPrefab")

GameButtonManager.ExtLoadLua(M.key, "Act_035_LeftPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_035_CenterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_035_ButtomPrefab")

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
        return Act_035_JHSPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "enter" then
        return Act_035_JHSEnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

-- 活动的提示状态
function M.GetHintState(parm)
    local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
    if oldtime ~= newtime then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Red
    end
        
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
end

function M.Init()
	M.Exit()

	this = Act_035_JHSManager
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

function M.GetCurConfigInfor()
    return Act_035_JHSManager.config.config
end

function M.GetCanGetGiftIndex(tab)
    if MainModel.IsCanBuyGiftByID(tab[1]) then
        return 1
    end

    local gg = MainModel.UserInfo.GiftShopStatus[tab[2]]
    if gg then
        if MainModel.IsCanBuyGiftByID(tab[2]) then
            return 2
        else
            return 3
        end
    end
end

function M.IsCanGetGift(tab)
    if MainModel.IsCanBuyGiftByID(tab[1]) then
        return true
    end

    if MainModel.IsHadBuyGiftByID(tab[2]) then
        return false
    end

    if MainModel.IsCanBuyGiftByID(tab[2]) then
        return true
    end

    return MainModel.IsCanBuyGiftByID(tab[3])
end
    
function M.GetCurHaveBuyFirstId()
    local _index_tabel = M.GetCurConfigInfor()
    if _index_tabel then
        local max_s = -1
        local index
        for i,v in ipairs(_index_tabel) do
            local satat = MainModel.IsCanBuyGiftByID(v.shop_id[1])
            local satat_1 = MainModel.IsCanBuyGiftByID(v.shop_id[2])
            local satat_2 = MainModel.IsCanBuyGiftByID(v.shop_id[3])
            local s
            if satat and  not satat_1 and satat_2 then
                s = 2
            elseif not satat and satat_1  then
                s = 3
            elseif (not satat and not satat_1 and satat_2) or (not satat and not satat_1) then
                s = 1
            end
            if not index then
                index = i
                max_s = s
            else
                if s > max_s then
                    index = i
                    max_s = s
                end
            end
        end
        return index
    end
end