-- 创建时间:2019-10-23
-- 许愿管理器

local basefunc = require "Game/Common/basefunc"
SYSXYManager = {}
local M = SYSXYManager
M.key = "sys_xy"
GameButtonManager.ExtLoadLua(M.key, "SYSXY_JYFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSXY_EnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "VowPanel")
GameButtonManager.ExtLoadLua(M.key, "VowExtGetPanel")

local Vow_Gift_config = GameButtonManager.ExtLoadLua(M.key, "Vow_Gift_config")

local this
local lister
local update_time

M.VowState = {
	VS_Get = "领取时段",
	VS_Nor = "正常时段",
}

-- 是否有活动
function M.IsActive()
    local _permission_key = "drt_block_xuyuanchi" -- 屏蔽许愿池
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            return false
        end
        return true
    else
        return true
    end
end
function M.CheckIsShow()
    return M.IsActive()
end
function M.GotoUI(parm)
	if not M.IsActive() then
		return
	end
    if parm.goto_scene_parm == "panel" then
        return VowPanel.Create()
    elseif parm.goto_scene_parm == "jyfl_enter" then
		return SYSXY_JYFLEnterPrefab.Create(parm.parent, parm.cfg)
	elseif parm.goto_scene_parm == "enter" then
    	return SYSXY_EnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if not M.IsActive() then return ACTIVITY_HINT_STATUS_ENUM.AT_Nor end
	if this.m_data then
		if this.m_data.is_vow == 0 then
			return ACTIVITY_HINT_STATUS_ENUM.AT_Get
		else
			if this.state == M.VowState.VS_Get then
				return ACTIVITY_HINT_STATUS_ENUM.AT_Get
			else
				return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
			end
		end
	end
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

    lister["query_xuyuanchi_base_info_response"] = this.on_query_xuyuanchi_base_info_response
    lister["xuyuanchi_base_info_change"] = this.on_xuyuanchi_base_info_change
end

function M.Init()
	M.Exit()

	this = SYSXYManager
	this.m_data = {}
	MakeLister()
    AddLister()
    update_time = Timer.New(M.Update, 10, -1, nil, true)
    update_time:Start()

	M.InitUIConfig()
end
function M.Exit()
	if this then
		if update_time then
			update_time:Stop()
			update_time = nil
		end
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig={
        config = {},
    }
    this.UIConfig.config = Vow_Gift_config
end
function M.Update()
	-- local cur_t = os.time()
	-- local hh = tonumber( os.date("%H", cur_t) )
	-- local hh = tonumber( os.date("%H", cur_t) )
	-- if hh >= 8 and hh < 10 then
	-- 	this.state = M.VowState.VS_Get
	-- else
	-- 	this.state = M.VowState.VS_Nor
	-- end
	if this.m_data and this.m_data.is_vow == 1 and this.m_data.overtime_count then
		while this.m_data.overtime_count < 0 do
	        this.m_data.overtime_count = this.m_data.overtime_count + 86400
	    end
	end
	if this.m_data.is_vow == 1 then
		if this.m_data.overtime_count > 0 and this.m_data.overtime_count <= 7200 then
			this.state = M.VowState.VS_Get
		else
			this.state = M.VowState.VS_Nor
		end
	else
		this.state = M.VowState.VS_Nor
	end
end

function M.OnLoginResponse(result)
	if result == 0 then
		Network.SendRequest("query_xuyuanchi_base_info")
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_query_xuyuanchi_base_info_response(_, data)
	-- dump(data, "<color=red>SYSXY on_query_xuyuanchi_base_info_response</color>")
	if data and data.result == 0 then
		this.m_data = data
		M.Update()

		Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
	end
end
function M.on_xuyuanchi_base_info_change(_, data)
	dump(data, "<color=red>SYSXY on_xuyuanchi_base_info_change</color>")
	if this.m_data then
		this.m_data.is_vow = data.is_vow
		this.m_data.overtime_count = data.overtime_count
		M.Update()

		Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
	end
end



