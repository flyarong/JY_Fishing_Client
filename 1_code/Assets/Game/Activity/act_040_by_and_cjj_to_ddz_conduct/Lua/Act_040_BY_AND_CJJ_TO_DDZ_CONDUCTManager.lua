-- 创建时间:2020-12-11
-- Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTManager = {}
local M = Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTManager
M.key = "act_040_by_and_cjj_to_ddz_conduct"
GameButtonManager.ExtLoadLua(M.key,"Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTEnterPrefab")
local this
local lister
M.now_level = nil
local permisstions = {
    "by_cjj_cpl_type_plat",
}

M.url = "http://cwww.jyhd919.cn/webpages/commonDownload.html?platform=normal&market_channel=normal&pageType=normal&category=1"

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1609775999
    local s_time = 1609198200
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    dump(M.GetNowPerMiss(),"<color=red>权限</color>")
    if M.GetNowPerMiss() then 
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
        if M.CheckIsShow() then
            return Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTEnterPrefab.Create(parm.parent, parm.cfg)
        end 
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
end

function M.Init()
	M.Exit()

	this = Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTManager
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

function M.GetNowPerMiss()
    local cheak_fun = function (_permission_key)
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                return false
            end
            return true
        else
            return false
        end
    end
    M.now_level = nil
    for i = 1,#permisstions do 
        if cheak_fun(permisstions[i]) then
            dump(permisstions[i],"符合条件的权限")
            M.now_level = i
            return i
        end
    end
end
