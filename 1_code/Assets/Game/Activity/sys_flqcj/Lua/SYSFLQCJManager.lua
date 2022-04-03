-- 创建时间:2020-07-09
-- SYSFLQCJManager 管理器

local basefunc = require "Game/Common/basefunc"
SYSFLQCJManager = {}
local M = SYSFLQCJManager
M.key = "sys_flqcj"
local config = GameButtonManager.ExtLoadLua(M.key, "game_flqcj_config")
GameButtonManager.ExtLoadLua(M.key, "SYSFLQCJPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSFLQCJPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSFLQCJEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSFLQCJGuidePanel")

local this
local lister

-- 是否有活动
function M.IsActive(condi_key)
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = condi_key
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
function M.CheckIsShow(parm)
    return M.IsActive(parm.condi_key)
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    dump(parm,"福利券抽奖：  ")
    if not M.CheckIsShow(parm) then
        return
    end
    if parm.goto_scene_parm == "panel" then
        if parm.data then
             SYSFLQCJPanel.Create({type=parm.data})
        else
             SYSFLQCJPanel.Create()
        end

        if parm.open_type and parm.open_type=="open_guide" then
            -- body
            SYSFLQCJGuidePanel.Create()
        end
    elseif parm.goto_scene_parm == "enter" then
        return SYSFLQCJEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString("HallXYCJHintTime" .. MainModel.UserInfo.user_id, 0))))
	local useVipCJTime=PlayerPrefs.GetInt("VipCJTime" .. MainModel.UserInfo.user_id, 0)
    -- dump( MainModel.UserInfo.jing_bi >= 10000000,"<color=red>福利券红点判断1：  </color>")
    -- dump( useVipCJTime<2,"<color=red>福利券红点判断2：  </color>")
    -- dump(  oldtime ~= newtime,"<color=red>福利券红点判断3：  </color>")

    if MainModel.UserInfo.jing_bi >= 10000000 and useVipCJTime<2 and  oldtime ~= newtime then
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
    lister["AssetChange"] = this.on_AssetChange

end

function M.Init()
	M.Exit()

	this = SYSFLQCJManager
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

    this.UIConfig.list = {}
    for k,v in ipairs(config.config) do
        if v.is_on_off == 1 then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.condi_key, is_on_hint = true}, "CheckCondition")
            if a and b then
                this.UIConfig.list[#this.UIConfig.list + 1] = v
            end
        end
    end
    MathExtend.SortList(this.UIConfig.list, "order", true)
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetConfigList()
    local ll = {}
    for k,v in ipairs(this.UIConfig.list) do
        local parm = {}
        parm.gotoui = v.gotoUI[1]
        parm.goto_scene_parm = v.gotoUI[2]
        local b,c = GameButtonManager.RunFun(parm, "CheckIsShow")
        if b and c then
            ll[#ll + 1] = v
        end
    end

    return ll
end

function M.on_AssetChange(data)
    if data.data then
        for i = 1, #data.data, 1 do
            if data.data[i].asset_type=="jing_bi" then
                this.SetHintState()
            end
        end
    end
end
