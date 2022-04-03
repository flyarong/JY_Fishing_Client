-- 创建时间:2020-05-18
-- SYSBYLevelManager 管理器
-- 捕鱼等级系统

local basefunc = require "Game/Common/basefunc"
SYSBYLevelManager = {}
local M = SYSBYLevelManager
M.key = "sys_by_level"
GameButtonManager.ExtLoadLua(M.key, "SYSBYLevelHallInfoPanel")
M.config = GameButtonManager.ExtLoadLua(M.key, "level_server")
M.pt_config = GameButtonManager.ExtLoadLua(M.key, "level_gun_config").config
GameButtonManager.ExtLoadLua(M.key, "SYSBYLevelNoticeBtn")
GameButtonManager.ExtLoadLua(M.key, "SYSBYLevelAwardPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSBYLevelLockPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSBYLevelEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSBYLevelPTPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSBYLevelPTItemBase")
local this
local lister
local updateTimer
local ABS_level = 0

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    local unlock_tab = M.GetUnlockConfig()
    --dump(#M.config.unlock,"<color=green>---------/////////---------++++++--/</color>")
    if this.m_data.should_index and unlock_tab[this.m_data.should_index] and unlock_tab[this.m_data.should_index].level <= (#M.config.unlock + 1) then
        --dump("<color=yellow>---------/////////---------++++++--/</color>")
    else
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
    if not this.m_data.result or (not this.m_data.level and this.m_data.result ~= 0) then
        M.QueryData()
        return false
    end

    if parm.goto_scene_parm == "enter1" then
        if not this.m_data.level or this.m_data.level > #M.config.level_data then
            return false
        end
    elseif parm.goto_scene_parm == "enter2" then
        local unlock_tab = M.GetUnlockConfig()
        if not this.m_data.should_index
            or not unlock_tab[this.m_data.should_index]
            or unlock_tab[this.m_data.should_index].level > (#M.config.unlock + 1) then
            return false
        end
    end
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        return
    end

    if parm.goto_scene_parm == "panel" then
        return SYSBYLevelHallInfoPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "enter1" then
        return SYSBYLevelNoticeBtn.Create(parm.parent)
    elseif parm.goto_scene_parm == "enter2" then
        return SYSBYLevelEnterPrefab.Create(parm.parent)
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
    lister["EnterScene"] = this.OnEnterScene
	lister["AssetChange"] = this.OnAssetChange
    lister["query_level_data_response"] = this.on_query_level_data_response
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["notify_level_promoted_msg"] = this.on_notify_level_promoted_msg
    lister["fishing_ready_finish"] = this.on_fishing_ready_finish

    lister["query_unlock_level_award_data_response"] = this.on_query_unlock_level_award_data_response
    lister["get_unlock_level_award_response"] = this.on_get_unlock_level_award_response
    lister["model_vip_upgrade_change_msg"] = this.on_model_vip_upgrade_change_msg
end

function M.Init()
	M.Exit()

	this = SYSBYLevelManager
	this.m_data = {}
    this.m_data.level = 1
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
        M.QueryData()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryData()
    Network.SendRequest("query_level_data")
    M.Query_Task_Data()
end

function M.GetData()
    return {level=this.m_data.level, cur_rate=M.CurRate(), max_rate=M.MaxRate()}
end

function M.on_notify_sdk()
	if gameRuntimePlatform == "Android" then
		local channel = gameMgr:getMarketChannel()
		if channel == "xiaomi" then
			if MainModel.UserInfo and this.m_data then
				local userid = MainModel.UserInfo.user_id or 0
				local name = MainModel.UserInfo.name or ""
				local userlv = tostring(this.m_data.level or 1)

				local lua_tbl = {}
				lua_tbl.msg = 0			--register_login+
				lua_tbl.level = userlv
				lua_tbl.roleId = tostring(userid)
				lua_tbl.roleName = name
				lua_tbl.serverId = "1"
				lua_tbl.serverName = "by"
				lua_tbl.zoneId = "1"
				lua_tbl.zoneName = "zh"

				dump(lua_tbl, "[debug] xiaomi send user info")

				sdkMgr:SendToSDKMessage(lua2json(lua_tbl))
			end
		end
	end	
end

function M.on_query_level_data_response(_,data)
    this.m_data.result = data.result
    if data and data.result == 0 then
        this.m_data.level = data.level
        if data.level - this.m_data.level ~= 0 then
            ABS_level = data.level - this.m_data.level
        end
        this.m_data.score = data.score
        Event.Brocast("ui_button_state_change_msg")
        Event.Brocast("level_info_got")

		M.on_notify_sdk()
    end
end
function M.on_notify_level_promoted_msg(_,data)
    dump(data,"<color=red>等级系统的数据：等级发生改变</color>")
    this.m_data.level = data.level
    if data.level - this.m_data.level ~= 0 then
        ABS_level = data.level - this.m_data.level
    end
    this.m_data.score = data.score
    Event.Brocast("level_info_got")
    Event.Brocast("level_info_got_change")
end
--
function M.GetLevel()
    return this.m_data.level or 1
end

function M.GetScore()
    return this.m_data.score
end
function M.StopTime()
    if updateTimer then
        updateTimer:Stop()
        updateTimer = nil
    end
end
--自动更新数据
function M.AutoUpdateData()
    M.StopTime()
    updateTimer = Timer.New(function ()
        Network.SendRequest("query_level_data")
    end,5,-1, nil, true)
    updateTimer:Start()
end

--进入捕鱼场景的时候
function M.OnEnterScene()
    if MainModel.myLocation == "game_Fishing3D" then
        M.AutoUpdateData()
    else
        M.StopTime()
    end
end

function M.CurRate()
    return this.m_data.score - M.GetScoreByLevel(this.m_data.level) 
end

function M.MaxRate()
    return M.GetScoreByLevel(this.m_data.level + 1) - M.GetScoreByLevel(this.m_data.level)
end

--到达level需要多少积分
function M.GetScoreByLevel(level)
    level = level or 1
    for k,v in pairs(M.config.level_data) do
        if level > 1 then
            if v.level == level - 1 then
                return v.score or 0 
            end
        end
    end
    return 0
end

function M.GetAwardImage()

end

--<del>获取等级差（有可能是一次性升两级）</del>
--确认： 如果某个操作导致连升几级，会多次发送msg消息
function M.GetABSLevel()

end

--获取奖励清单，注意，需要从当前等级
function M.GetAwardList()
    -- body
end
--展示下一个等级的奖励面板
function M.ShowNextLevelPanel()
    SYSBYLevelAwardPanel.Create(M.GetNextLevelInfo(), false)
end
--获取下一个等级的相关信息
function M.GetNextLevelInfo()
    local nextlevel = this.m_data.level + 1
    return M.GetLevelInfo(nextlevel)
end

function M.GetLevelInfo(level)
    local data = {}
    for k , v in pairs(M.config.level_data) do
        if v.level == level then
            data.award_info = v
        end
    end
    dump(data,"<color=red>奖励的数据-000000000</color>")
    return data
end

function M.OnAssetChange(data)
    if data and data.change_type then
        local str = string.sub(data.change_type,1,11)

        if str == "level_award" then
            local level = tonumber(string.sub(data.change_type,13))
            dump(level,"<color=red>数据-=-=-=-=-=-=-=-=-=-=-=</color>")
            SYSBYLevelAwardPanel.Create(M.GetLevelInfo(level), true, level)
        end
        if data.change_type=="unlock_level_award" then
            Event.Brocast("AssetGet", data)
            
        end
    end
end

function M.on_fishing_ready_finish() 
    local bool = false
    local a,vip = GameButtonManager.RunFun({gotoui="vip"}, "get_vip_level")
    if a and vip > 0 then -- VIP2开放
        bool = true
    end
    if FishingModel.game_id == 1 or FishingModel.game_id == 4 or FishingModel.game_id == 5 or bool then
        Event.Brocast("by3d_level_lock_rate_init", {1, 10})
    else
        local unlock_tab = M.GetUnlockConfig()
    local t = {}
    local max = 1
    for k,v in pairs(unlock_tab) do
        if v.game_id and v.level and v.game_id == FishingModel.game_id and v.level <= M.GetLevel() then
            t[#t + 1] = v.gun_index
        end
    end
    for i=1,#t do
        max = math.max(t[i],max)
    end
    if FishingModel.game_id == 2 then
        max = math.max(5,max)
    end
    --dump(t,"<color=red>数据-=-=-=-=-=-=t-=-=-=-=-=</color>")
    --dump(max,"<color=red>数据-=-=-=-=-=-=-max=-=-=-=-=</color>")
    Event.Brocast("by3d_level_lock_rate_init", {1, max})
    end
    M.Query_Task_Data()
end

--领取解锁炮倍的奖励
function M.GetAwardPB()
    --[[local unlock_tab = M.GetUnlockConfig()
    if unlock_tab[this.m_data.should_index] and unlock_tab[this.m_data.should_index].level == 12 and FishingModel.game_id == 2 then
        HintPanel.Create(2,"是否确定领取奖励并跳转场次?",function ()
            Network.SendRequest("get_unlock_level_award")
        end)
    else
        Network.SendRequest("get_unlock_level_award")
    end--]]
    Network.SendRequest("get_unlock_level_award")
end


--查询任务数据
function M.Query_Task_Data()
    Network.SendRequest("query_unlock_level_award_data")
end

function M.on_query_unlock_level_award_data_response(_,data)
    --dump(data,"<color=yellow>+++++++++++++on_query_unlock_level_award_data_response+++++++++++++</color>")
    if data and data.result == 0 then
        this.m_data.should_index = data.index
    end
end

function M.GetShouldIndex()
    --dump(this.m_data.should_index,"<color=yellow>+++++++++++++++++++++</color>")
    return this.m_data.should_index
end

function M.on_get_unlock_level_award_response(_,data)
    --dump(data,"<color=yellow>+++++++++++++on_get_unlock_level_award_response+++++++++++++</color>")
    if data and data.result == 0 then
        this.m_data.should_index = data.index + 1
        Event.Brocast("sys_by_level_task_data_msg")
        Event.Brocast("ui_button_state_change_msg")
        local unlock_tab = M.GetUnlockConfig()
        if unlock_tab[data.index].game_id then
            if FishingModel.game_id == unlock_tab[data.index].game_id then
                local gun_index = unlock_tab[data.index].gun_index
                Event.Brocast("by3d_level_lock_rate_change", {is_hand=true, index=gun_index})
            elseif FishingModel.game_id < unlock_tab[data.index].game_id then
                local gun_index = 10
                Event.Brocast("by3d_level_lock_rate_change", {is_hand=true, index=gun_index})
            end
        end
        --[[if data.index == 10 and FishingModel.game_id == 2 then
            GameManager.GuideExitScene({gotoui = "game_Fishing3DHall"})
        end--]]
    end
end

function M.GetUnlockConfig()
    return M.config.unlock
end


function M.on_model_vip_upgrade_change_msg()
    local a,vip = GameButtonManager.RunFun({gotoui="vip"}, "get_vip_level")
    if a and vip > 0 then -- VIP2开放    
        Event.Brocast("by3d_level_lock_rate_change", {index=10})
    end
end

function M.GetPTConfig()
    return M.pt_config
end