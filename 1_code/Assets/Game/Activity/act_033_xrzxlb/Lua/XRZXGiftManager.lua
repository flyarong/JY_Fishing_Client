-- 创建时间:2020-10-11
-- XRZXGiftManager 管理器

local basefunc = require "Game/Common/basefunc"
XRZXGiftManager = {}
local M = XRZXGiftManager
M.key = "act_033_xrzxlb"

GameButtonManager.ExtLoadLua(M.key,"XRZXGiftPanel")
GameButtonManager.ExtLoadLua(M.key,"XRZXGiftEnterPrefab")

local this
local lister



local  M_config = GameButtonManager.ExtLoadLua(M.key,"act_030_xrzxlb_config")



-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 2552233600
    local s_time = 1603756800
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end


    -- 对应权限的key
    local _permission_key = "xrzx_newplayer"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and  b then
            if M.IsFinishBuyGift() then
                return false
            else
                return true
            end
        end
        return false
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
    if parm.goto_scene_parm == "enter" then
        return XRZXGiftEnterPrefab.Create(parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end

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

	this = XRZXGiftManager
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
    this.m_data.xrzxgift_config = {}
    this.m_data.xrzxgift_config = this.m_data.xrzxgift_config or {}
    for i,v in ipairs(M_config.Sheet1) do
        this.m_data.xrzxgift_config[#this.m_data.xrzxgift_config + 1 ] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetCurGiftInforByID()
    local status = 0
    for i=1,#this.m_data.xrzxgift_config do
        status = MainModel.GetGiftShopStatusByID(this.m_data.xrzxgift_config[i].gift_id)
        if status == 1 then
            return this.m_data.xrzxgift_config[i]
        end  
    end  
end

function M.IsFinishBuyGift()
    local is_Finish = false
    local status_map = {}
    for i=1,#this.m_data.xrzxgift_config do
        status_map[i] = MainModel.GetGiftShopStatusByID(this.m_data.xrzxgift_config[i].gift_id)
    end
    
    if not table_is_null(status_map) then 
       for i=1,#status_map do
            if status_map[i] == 1 then
                return false
            end
        end   
        return true
    end
end
