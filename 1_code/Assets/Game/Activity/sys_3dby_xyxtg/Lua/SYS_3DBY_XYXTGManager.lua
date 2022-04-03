-- 创建时间:2021-01-29
-- SYS_3DBY_XYXTGManager 管理器

local basefunc = require "Game/Common/basefunc"
SYS_3DBY_XYXTGManager = {}
local M = SYS_3DBY_XYXTGManager
M.key = "sys_3dby_xyxtg"
local config = GameButtonManager.ExtLoadLua(M.key,"sys_3dby_xyxtg_config")
GameButtonManager.ExtLoadLua(M.key,"SYS_3DBY_XYXTGPanel")
GameButtonManager.ExtLoadLua(M.key,"SYS_3DBY_XYXTGXQItemBase")
GameButtonManager.ExtLoadLua(M.key,"SYS_3DBY_XYXTGXQPanel")
GameButtonManager.ExtLoadLua(M.key,"SYS_3DBY_XYXTGYJPanel")
GameButtonManager.ExtLoadLua(M.key,"SYS_3DBY_XYXTGEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"SYS_3DBY_XYXTGTipEnterPrefab")
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

    if FishingModel and (FishingModel.game_id == 1 or FishingModel.game_id == 2) then
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
    if not M.CheckIsShow(parm) then return end
    if parm.goto_scene_parm == "panel" then
        return SYS_3DBY_XYXTGPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return SYS_3DBY_XYXTGEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
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

    lister["little_game_tuoguan_query_history_response"] = this.on_little_game_tuoguan_query_history_response
    lister["little_game_tuoguan_get_award_response"] = this.on_little_game_tuoguan_get_award_response
    lister["little_game_tuoguan_cancel_response"] = this.on_little_game_tuoguan_cancel_response
    lister["little_game_tuoguan_bet_response"] = this.on_little_game_tuoguan_bet_response
    lister["little_game_tuoguan_query_bet_data_response"] = this.on_little_game_tuoguan_query_bet_data_response
    lister["little_game_tuoguan_kaijiang_msg"] = this.on_little_game_tuoguan_kaijiang_msg
    lister["AssetChange"] = this.on_AssetChange
    lister["sysby3djchdenterprefab_has_create_msg"] = this.on_sysby3djchdenterprefab_has_create_msg
end

function M.Init()
	M.Exit()

	this = SYS_3DBY_XYXTGManager
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

    this.UIConfig.game_prefab_list = {}
    for i=1,#config.game_config do
        this.UIConfig.game_prefab_list[#this.UIConfig.game_prefab_list + 1] = config.game_config[i].prefab_name
    end

    this.UIConfig.game_prefab_map = {}
    for k,v in pairs(config.game_config) do
        this.UIConfig.game_prefab_map[v.game_name] = v.prefab_name
    end

    this.UIConfig.game_config_map = {}
    for k,v in pairs(config.game_config) do
        this.UIConfig.game_config_map[v.game_name] = config[v.game_config]
    end

    this.UIConfig.game_name_map = {}
    for k,v in pairs(config.game_config) do
        this.UIConfig.game_name_map[v.prefab_name] = v.game_name
    end

    this.UIConfig.game_name_desc_map = {}
    for k,v in pairs(config.game_config) do
        this.UIConfig.game_name_desc_map[v.game_name] = v.game_name_desc
    end

    this.UIConfig.game_selet_img_map = {}
    for k,v in pairs(config.game_config) do
        this.UIConfig.game_selet_img_map[v.game_name] = v.selet_img
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end


function M.QueryXqData(page_index)
    if not this.m_data.history_data or (os.time() - this.m_data_history_query_last_t > 5) then
        NetMsgSendManager.SendMsgQueue("little_game_tuoguan_query_history",{page_index = page_index})
    else
        Event.Brocast("xyxtg_history_data_had_got_msg",this.m_data.history_data[page_index],page_index)
    end
end

function M.on_little_game_tuoguan_query_history_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_little_game_tuoguan_query_history_response++++++++++</size></color>")
    if data and data.result == 0 then
        this.m_data_history_query_last_t = os.time()
        this.m_data.history_data = this.m_data.history_data or {}
        this.m_data.history_data[data.page_index] = data.history_record
        Event.Brocast("xyxtg_history_data_had_got_msg",this.m_data.history_data[data.page_index],data.page_index)
    end
end

function M.GetAward()
    NetMsgSendManager.SendMsgQueue("little_game_tuoguan_get_award")
end

function M.on_little_game_tuoguan_get_award_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_little_game_tuoguan_get_award_response++++++++++</size></color>")
    if data and data.result == 0 then
        this.m_data.tg_data.bet_money = 0
        this.m_data.tg_data.remain_round = 0
        this.m_data.tg_data.tot_round = 0
        this.m_data.tg_data.award_money = 0
        M.SetHintState()
        Event.Brocast("xyxtg_award_had_got_msg")
    end
end

function M.TGStop()
    NetMsgSendManager.SendMsgQueue("little_game_tuoguan_cancel")
end

function M.on_little_game_tuoguan_cancel_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_little_game_tuoguan_cancel_response++++++++++</size></color>")
    if data and data.result == 0 then
        this.m_data.tg_data.bet_money = 0
        this.m_data.tg_data.remain_round = 0
        this.m_data.tg_data.tot_round = 0
        this.m_data.tg_data.award_money = 0
        M.SetHintState()
        Event.Brocast("xyxtg_bet_had_cancel_msg")
    end
end

function M.TGStart(game_name,bet_money,round)
    dump({game_name = game_name,bet_money = bet_money,round = round},"<color=yellow><size=15>++++++++++TGStart++++++++++</size></color>")
    NetMsgSendManager.SendMsgQueue("little_game_tuoguan_bet",{game_name = game_name,bet_money = bet_money,round = round})
end

function M.on_little_game_tuoguan_bet_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_little_game_tuoguan_bet_response++++++++++</size></color>")
    if data and data.result == 0 then
        this.m_data.tg_data = data.tg_data
        M.SetHintState()
        Event.Brocast("xyxtg_bet_data_had_got_msg")
    end
end

function M.QueryTGData()
    if not this.m_data.tg_data or (this.m_data_tgdata_query_last_t and (os.time() - this.m_data_tgdata_query_last_t > 5)) then
        NetMsgSendManager.SendMsgQueue("little_game_tuoguan_query_bet_data",nil,"")
    else
        M.SetHintState()
        Event.Brocast("xyxtg_all_data_had_got_msg")
    end
end

function M.on_little_game_tuoguan_query_bet_data_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_little_game_tuoguan_query_bet_data_response++++++++++</size></color>")
    if data and data.result == 0 then
        this.m_data_tgdata_query_last_t = os.time()
        if table_is_null(data.tg_data) then
            data.tg_data = {}
            data.tg_data.bet_money = 0
            data.tg_data.remain_round = 0
            data.tg_data.tot_round = 0
            data.tg_data.award_money = 0
        end
        this.m_data.tg_data = data.tg_data
        M.SetHintState()
        Event.Brocast("xyxtg_all_data_had_got_msg")
    end
end

function M.GetTGData()
    return this.m_data.tg_data
end

function M.on_little_game_tuoguan_kaijiang_msg(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_little_game_tuoguan_kaijiang_msg++++++++++</size></color>")
    if data then
        this.m_data.tg_data = data.tg_data
        M.SetHintState()
        Event.Brocast("xyxtg_all_data_had_got_msg")
    end
end

function M.GetMiniGamePrefabList()
    return this.UIConfig.game_prefab_list
end

function M.GetGamePrefabByGameName(game_name)
    return this.UIConfig.game_prefab_map[game_name]
end

function M.GetGameConfigByGameName(game_name)
    return this.UIConfig.game_config_map[game_name]
end

function M.GetGameNameByGamePrefab(game_prefab)
    return this.UIConfig.game_name_map[game_prefab]
end

function M.GetGameNameDescByGameName(game_name)
    return this.UIConfig.game_name_desc_map[game_name]
end

function M.GetSeletImgByGameName(game_name)
    return this.UIConfig.game_selet_img_map[game_name]
end

function M.GetBetTimesLimit()
    return config.bet_times
end

function M.on_AssetChange(data)
    if data and data.change_type == "little_game_tuoguan_award" then
        dump(data,"<color=yellow><size=15>++++++++++on_AssetChange++++++++++</size></color>")
        SYS_3DBY_XYXTGYJPanel.Create(data.data[1].value)
    end
end

--检查推荐的下注档次
function M.GetTJBetMoney(tab)
    local qx_max = #tab
    for i=#tab,1,-1 do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=tab[i].permission, is_on_hint=true}, "CheckCondition")
        if not a or b then
            qx_max = i
            break
        end 
    end
    for i = qx_max,1,-1 do
        if MainModel.UserInfo.jing_bi/20 >= tab[i].bet_money then
            return i
        end 
    end
    return 1
end

function M.IsCanGet()
    if this.m_data.tg_data and (this.m_data.tg_data.remain_round == 0) and (tonumber(this.m_data.tg_data.award_money) > 0) then
        return true
    end
    return false
end