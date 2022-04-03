-- 创建时间:2019-10-24
-- 首充礼包

local basefunc = require "Game/Common/basefunc"
SYSSCLB1Manager = {}
local M = SYSSCLB1Manager
M.key = "sys_sclb1"
GameButtonManager.ExtLoadLua(M.key, "SCLB1EnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "SCLB1Panel")
local this
local lister

function M.CheckIsShow()
    if not M.check_can_pay() then return end
	if MainModel.UserInfo.ui_config_id == 1 then
		return
	end
    return true
end

function M.GotoUI(parm)
    if not M.check_can_pay() then return end
    if MainModel.UserInfo.ui_config_id == 1 then
        return
    end
    if parm.goto_scene_parm == "panel" then
        return SCLB1Panel.Create(nil,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
    	return SCLB1EnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
function M.SetHintState()
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

    lister["finish_gift_shop"] = this.on_finish_gift_shop_shopid
    lister["PayPanelCreate"] = this.PayPanelCreate
end

function M.Init()
	M.Exit()

	this = SYSSCLB1Manager
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
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetOutTime()
    if MainModel.UserInfo.ui_config_id == 2 then 
        local f_t = tonumber(MainModel.UserInfo.first_login_time) 
        if not f_t then return 0 end  
        return f_t + 7 * 24 * 3600 - os.time()
    else
        return 0
    end 
end

function M.on_finish_gift_shop_shopid(id)
    M.CheckShopId()
    local is_gift = false
    for i=1,#M.shopid do
        if M.shopid[i] == id then
            is_gift = true
            break
        end
    end
    if not is_gift then return end
    if MainModel.UserInfo.GiftShopStatus[id] then
        MainModel.UserInfo.GiftShopStatus[id].status = 0
    end
    Event.Brocast("model_sclb1_gift_change_msg")
end

function M.PayPanelCreate()
    GameButtonManager.GotoUI({gotoui = "sys_sclb1",goto_scene_parm = "panel"})
end

function M.check_can_pay()
    M.CheckShopId()
    for i=1, #M.shopid do
        local status = MainModel.GetGiftShopStatusByID(M.shopid[i])
        -- dump({M.shopid[i],status},"<color=white>全返礼包</color>")
        if status == 0 then
            --有礼包已经购买
            return false
        end
    end
    return true
end

function M.CheckShopId()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "actp_buy_gift_bag_class_first_deposit_gift", is_on_hint = true}, "CheckCondition")
    if a and b then
        M.type = 2
        M.shopid = {10611,10612,10613}
    else
        M.type = 1
        M.shopid = {95,96,99}
    end
end