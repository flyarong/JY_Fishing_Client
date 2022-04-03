-- 创建时间:2020-06-03
-- BYDRBCSManager 管理器

local basefunc = require "Game/Common/basefunc"
BYDRBCSManager = {}
local M = BYDRBCSManager
M.key = "by_drb_cs"
GameButtonManager.ExtLoadLua(M.key, "FishingDRBCSRankPanel")
GameButtonManager.ExtLoadLua(M.key, "BYDRBCSEnterPrefab")
local config = GameButtonManager.ExtLoadLua(M.key, "fish_drbcs_rank_config")

local this
local lister

M.rank_types = {
    "buyu_3d_yingjin_rank",  -- 
}

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
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
		return FishingDRBCSRankPanel.Create(parm.parent)
	elseif parm.goto_scene_parm == "enter" then
		return BYDRBCSEnterPrefab.Create(parm.parent, parm.cfg)
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

    lister["query_rank_base_info_response"] = this.query_rank_base_info_response
end

function M.Init()
	M.Exit()

	this = BYDRBCSManager
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
        -- for i = 1,#M.rank_types do
        --     Network.SendRequest("query_rank_base_info",{rank_type = M.rank_types[i]})
        -- end
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetConfig()
	return config
end
function M.GetAwardByRank(rank)
	for i,v in ipairs(config.awards) do
		 if rank >= v.min_rank and rank <= v.max_rank then
			 return v.desc
		 end
	end
    return ""
end

function M.GetMyRankData(rank_type)
    return this.m_data.mydata[rank_type]
end

function M.query_rank_base_info_response(_, data)
    dump(data,"<color=red><size=30>我的排行榜数据------</size></color>")
    if data and data.result == 0 then
    	this.m_data.mydata = this.m_data.mydata or {}
        this.m_data.mydata[data.rank_type] = data
        Event.Brocast("by_drb_cs_base_info_get", {rank_type = data.rank_type})
    end
end