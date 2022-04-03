-- 创建时间:2019-10-23
-- 鲸鱼福利管理器

local basefunc = require "Game/Common/basefunc"
JYFLManager = {}
local M = JYFLManager
M.key = "jyfl"
GameButtonManager.ExtLoadLua(M.key, "JYFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "JYFLPanel")
local jyfl_banner_cfg = GameButtonManager.ExtLoadLua(M.key, "jyfl_banner_cfg")

local this
local lister
local m_data

function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return JYFLPanel.Create(parm.parent, parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
    	return JYFLEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    -- dump(this.activityRedMap ,"<color=yellow>获取福利中心红点信息</color>")
    if this.activityRedMap then
        local state = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        for k,v in pairs(this.activityRedMap) do
            if v == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
                -- dump(k.."_"..v,"<color=yellow>获取福利中心红点信息</color>")
                state = v
                break
            elseif v == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
                -- dump(k.."_"..v,"<color=yellow>获取福利中心红点信息</color>")
                state = v
            end
        end
        -- dump(state,"<color=yellow>获取福利中心红点信息 state</color>")
        return state
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
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
    lister["global_hint_state_change_msg"] = this.on_global_hint_state_change_msg
end

function M.Init()
	M.Exit()

	this = JYFLManager
	m_data = {}
    this.activityRedMap = {}
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
    this.UIConfig={
        config = {},
        map_config = {},
    }
    local cc = this.UIConfig.config
    local map_config = this.UIConfig.map_config
    for k,v in ipairs(jyfl_banner_cfg.config) do
    	if v.isOnOff == 1 then
            if  M.CheckCondition(v.condi_key) then
                cc[#cc + 1] = v
                map_config[v.key] = v
            end
    	end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        M.InitRedHint()
	end
end
function M.OnReConnecteServerSucceed()
end
function M.InitRedHint()
    this.activityRedMap = {}
    local nowT = os.time()
    
    if this.UIConfig.config and next(this.UIConfig.config) then
        for k,v in ipairs(this.UIConfig.config) do
            if v.isOnOff == 1 then
                local parm = {}
                parm.gotoui = v.key
                parm.goto_scene_parm = v.parm
                if M.CheckCondition(v.condi_key) then
                    -- body
                    local b,c = GameButtonManager.RunFun(parm, "CheckIsShowInJYFL")
                    if not b or (b and c) then
                        this.activityRedMap[v.key] = GameManager.GetHintState(parm)
                    end
                end
              
            end
        end
    end
    Event.Brocast("UpdateHallJYFLRedHint")
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Fuli_GET)
end
function M.CheckCondition (condi_key)
    if condi_key then
        -- body
        local b,c = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=condi_key, is_on_hint = true}, "CheckCondition")
        if b and c then
            return true
        end
        return false
    else
        return true

    end

end
function M.on_global_hint_state_change_msg(parm)
    if M.UIConfig.map_config[parm.gotoui] then
        local b,c = GameButtonManager.RunFun(parm, "CheckIsShowInJYFL")
        if not b or (b and c) then
            this.activityRedMap[parm.gotoui] = GameManager.GetHintState(parm)
        end
        Event.Brocast("UpdateHallJYFLRedHint")
        RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Fuli_GET)
    end
end
