-- 创建时间:2020-07-29
-- SYSTGXTManager 管理器

local basefunc = require "Game/Common/basefunc"
SYSTGXTManager = {}
local M = SYSTGXTManager
M.key = "sys_tgxt"
M.config = GameButtonManager.ExtLoadLua(M.key,"systgxt_config")
GameButtonManager.ExtLoadLua(M.key, "SYSTGXTEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSTGXTPanel")
--GameButtonManager.ExtLoadLua(M.key, "SYSTGXTSharePanel")
GameButtonManager.ExtLoadLua(M.key, "SYSTGXTMyAwardPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSTGXTMyAwardItemBase")
GameButtonManager.ExtLoadLua(M.key, "SYSTGXTMakeSurePanle")
GameButtonManager.ExtLoadLua(M.key, "SYSTGXTBDPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSTGXTZQJCPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSTGXTInComePanel")
GameButtonManager.ExtLoadLua(M.key, "SYSTGXHistoryItemBase")


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
        if a and  b then
            return true
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
    if parm.goto_scene_parm == "panel" then
        return SYSTGXTPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return SYSTGXTEnterPrefab.Create(parm.parent,parm.backcall)
    elseif  parm.goto_scene_parm == "panel2" then
        return SYSTGXTBDPanel.Create(parm.node) 
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
    if M.IsCashChange() then
        M.SetLocalData("red1", 1)
        M.SetLocalData("red2", 1)
    end
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
    lister["global_game_panel_open_msg"] = this.global_game_panel_open_msg
    lister["AssetChange"] = this.on_AssetChange
end

function M.Init()
	M.Exit()

	this = SYSTGXTManager
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
    local index = 1
    for i=1,#M.config.permission do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= M.config.permission[i].condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            index = i
            this.UIConfig.IsShowInviteCode = M.config.permission[i].is_show_invite_code == 1
            break
        end
    end

    this.UIConfig.jc_config = {}--教程config
    for i=1,#M.config.permission[index].jc_config do
        this.UIConfig.jc_config[#this.UIConfig.jc_config + 1] = M.config.jc_config[M.config.permission[index].jc_config[i]]
    end
    this.UIConfig.share_config = {}--分享图片config
    this.UIConfig.share_config = M.config.permission[index].share_config
end

function M.OnLoginResponse(result)
	if result == 0 then
        this.CASH_KEY = M.key..MainModel.UserInfo.user_id.."_cash"
        this.RED1_KEY = M.key..MainModel.UserInfo.user_id.."_red1"
        this.RED2_KEY = M.key..MainModel.UserInfo.user_id.."_red2"
        -- 数据初始化
        --Network.SendRequest("111111111111111111请求数据(可以判断自己是哪种玩家)")
        this.m_data.old_cash = PlayerPrefs.GetInt(this.CASH_KEY, -1)
        if this.m_data.old_cash == -1 then
            M.SetLocalData("cash")
            this.m_data.old_cash = MainModel.UserInfo.cash
        end

        M.SetHintState()
	end
end

function M.OnReConnecteServerSucceed()
end

function M.GetFakePlayerName()
    return this.m_data.play_name
end

function M.GetFakeNum()
    return this.m_data.num
end

--获取玩家的ID
function M.GetMyInviteCode()
    return MainModel.UserInfo.user_id
end

function M.GetBinDingStatus()
    
end

--创建了之后，发送一个“上级”消息
function M.global_game_panel_open_msg(data)
    if data.ui == "NewPersonPanel" and this.UIConfig.IsShowInviteCode then
        Event.Brocast("SYSTGXT_bind_up_person_msg")
    end
end

--获取我的上级
function M.GetMyParentID()
    return MainModel.UserInfo.parent_id 
end

function M.SetLocalData(key, val)
    if key == "dj" then
        PlayerPrefs.SetInt(M.key .. MainModel.UserInfo.user_id, 1)
    end
    if key == "cash" then
        PlayerPrefs.SetInt(this.CASH_KEY, MainModel.UserInfo.cash)
    end
    if key == "red1" then
        PlayerPrefs.SetInt(this.RED1_KEY, val)
    end
    if key == "red2" then
        PlayerPrefs.SetInt(this.RED2_KEY, val)
    end
    Event.Brocast("sys_tgxt_red_state_change_msg")
end
function M.GetLocalData(key)
    if key == "dj" then
        return PlayerPrefs.GetInt(M.key .. MainModel.UserInfo.user_id, 0)
    end
    if key == "cash" then
        return PlayerPrefs.GetInt(this.CASH_KEY, MainModel.UserInfo.cash)
    end
    if key == "red1" then
        return PlayerPrefs.GetInt(this.RED1_KEY, 1)
    end
    if key == "red2" then
        return PlayerPrefs.GetInt(this.RED2_KEY, 1)
    end    
end
function M.IsCashChange()
    if this.m_data.old_cash < MainModel.UserInfo.cash then
        return true
    end
    return false
end

function M.on_AssetChange()
    if this.m_data.old_cash and MainModel.UserInfo.cash and this.m_data.old_cash < MainModel.UserInfo.cash then
        M.SetLocalData("red1", 0)
        M.SetLocalData("red2", 0)
        M.SetLocalData("cash", 0)
        this.m_data.old_cash = MainModel.UserInfo.cash
    end
end

--获取教程配置
function M.GetJCCfg()
    return this.UIConfig.jc_config
end

--获取分享图片配置
function M.GetShareCfg()
    return this.UIConfig.share_config
end

--是否显示邀请码
function M.IsShowInviteCode()
    return this.UIConfig.IsShowInviteCode
end