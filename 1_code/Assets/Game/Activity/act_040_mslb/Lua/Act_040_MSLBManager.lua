-- 创建时间:2020-05-11
-- Act_040_MSLBManager 管理器


--[[---功能修改说明--------------

    元旦福利 由斗地主登录福利修改

-------------------------------------
]]
local basefunc = require "Game/Common/basefunc"
Act_040_MSLBManager = {}
local M = Act_040_MSLBManager
M.key = "act_040_mslb"
Act_040_MSLBManager.act_config = GameButtonManager.ExtLoadLua(M.key,"act_040_config")
GameButtonManager.ExtLoadLua(M.key,"Act_040_MSLBPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_040_MSLBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_040_MSLBBeforeBuyPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_040_MSLBAfterBuyPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_040_MSLBLotteryPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_040_MSLBEnterPrefab_InFLPanel")
M.act_type = "ydkl_xnfl"
local this
local lister

----当前配置表是前端写的，所以获取方式是这种，若有更新策划已形成配置，但获取方式会有所改变，请注意配置情况
M.qfxl_gift_id =  M.act_config.otherInfo.qfxl_gift_id
M.qfxl_gift_id2 =  M.act_config.otherInfo.qfxl_gift_id2
M.seven_time=M.act_config.otherInfo.seven_time
M.end_time=M.act_config.otherInfo.end_time
local _time_UnrealyData
local _time_IsAfter7Day
local _time_QFXL
local _time_benefits_data
-- 是否有活动
function M.IsActive(parm)
    -- 活动的开始与结束时间
    local e_time
    local s_time = M.act_config.otherInfo.start_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then--NowTime - (NowTime + 8 * 3600) % 86400 
        -- dump("false","<color=red>Act_040_MSLBManager</color>")
        return false
    end

    local mslb_time = PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."mslb")
    if mslb_time and mslb_time == 0 and os.time() >= M.seven_time then
        -- dump("false","<color=red>Act_040_MSLBManager</color>")
        
        return false--活动时间内内没买过的就不显示入口
    end

    if mslb_time and mslb_time ~= 0 and math.floor((os.time() - mslb_time) / 86400) >= 180 then
        -- dump("false","<color=red>Act_040_MSLBManager</color>")
        
        return false--从购买礼包起,180天后,活动消失
    end

    -- 对应权限的key
    local _permission_key-- = "login_welfare"
    if parm then
        -- body
        _permission_key=parm.condi_key
    end
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
    if parm.goto_scene_parm == "enter" and os.time() >= M.seven_time then
        return false
    elseif parm.goto_scene_parm == "jyfl_enter" and os.time() < M.seven_time then
        return false
    end
    return M.IsActive(parm)
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    -- dump(parm,"<color=red>Act_040_MSLBManager</color>")
    if not M.CheckIsShow(parm) then
        return
    end
    if parm.goto_scene_parm == "panel" then
        if parm.goto_type and parm.goto_type=="login" then
            return Act_040_MSLBPanel.Create(parm.parent,parm.backcall)
        end
    elseif parm.goto_scene_parm == "enter" then
        -- dump(111,"<color=red>创建秒杀礼包入口!!!!</color>")
        return Act_040_MSLBEnterPrefab.Create(parm.parent, parm.cfg) 
    elseif parm.goto_scene_parm == "jyfl_enter" then
        return Act_040_MSLBEnterPrefab_InFLPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end

end

-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if not M.IsActive() then return ACTIVITY_HINT_STATUS_ENUM.AT_Nor end
        if M.IsAwardCanGet() then
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

    --请求基本信息
    lister["query_player_welfare_activity_base_info_response"] = this.query_player_welfare_activity_base_info_response
    --请求全服限量的个数
    lister["query_gift_bag_num_response"] = this.on_query_gift_bag_num_response
    --请求假数据
    lister["get_one_welfare_activity_false_lottery_data_response"] = this.on_get_one_welfare_activity_false_lottery_data_response
    --请求抽奖数据
    lister["welfare_activity_lottery_response"] = this.on_welfare_activity_lottery_response
    --每日领取成功
    lister["welfare_activity_receive_award_response"] = this.on_welfare_activity_receive_award_response
    --监听礼包购买成功
    lister["finish_gift_shop"] = this.on_finish_gift_shop

    -- lister["welfare_activity_base_info_change_msg"] = this.on_welfare_activity_base_info_change_msg

end

function M.Init()
	M.Exit()

	this = Act_040_MSLBManager
	this.m_data = {}
    M.Init_M_Data()
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
    M.StopUpdateTime_benefits()
    M.StopUpdateTime_QFXL()
    M.StopUpdateTime_IsAfter7Day()
    M.StopUpdateTime_UnrealyData()
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
        if true or M.IsActive() then
            M.update_time_IsAfter7Day(true)--判断是否满7天了(7天后才请求跑马灯假数据并显示)
            Timer.New(function ()
                M.QueryData()
            end, 1, 1):Start()
        end
	end
end
function M.OnReConnecteServerSucceed()
end


function M.Init_M_Data()
    this.m_data.is_have_data = false--是否有基本数据
    this.m_data.is_have_num = false--是否有全服限量礼包的个数
    this.m_data.buy_time = 0
    this.m_data.qfxl_num = 200
    this.m_data.total_remain_num = 0
    this.m_data.login_day = 0
    this.m_data.is_receive = 0
end


function M.IsAwardCanGet()
    if this.m_data.buy_time ~= 0 and this.m_data.is_receive == 0 then
        return true
    else
        return false
    end

end

function M.StopUpdateTime_IsAfter7Day()
    if _time_IsAfter7Day then
        _time_IsAfter7Day:Stop()
        _time_IsAfter7Day = nil
    end
end
function M.update_time_IsAfter7Day(b)
    M.StopUpdateTime_IsAfter7Day()
    if b then
        _time_IsAfter7Day = Timer.New(function ()
            if os.time() >= M.act_config.otherInfo.seven_time then
                --Event.Brocast("model_mslb_EnterPrefab_move")
                M.update_time_UnrealyData(true)
                M.StopUpdateTime_IsAfter7Day()
            end
        end, 60, -1, nil, true)
        _time_IsAfter7Day:Start()
    end
end

function M.StopUpdateTime_UnrealyData()
    if _time_UnrealyData then
        _time_UnrealyData:Stop()
        _time_UnrealyData = nil
    end
end
function M.update_time_UnrealyData(b)
    M.StopUpdateTime_UnrealyData()
    if b then
        M.QueryUnrealyData()
        _time_UnrealyData = Timer.New(function ()
            M.QueryUnrealyData()
        end, 30, -1, nil, true)
        _time_UnrealyData:Start()
    end
end
function M.QueryUnrealyData()
    Network.SendRequest("get_one_welfare_activity_false_lottery_data",{act_type = M.act_type})
end


function M.StopUpdateTime_QFXL()
    if _time_QFXL then
        _time_QFXL:Stop()
        _time_QFXL = nil
    end
end
function M.update_time_QFXL(b)
    M.StopUpdateTime_QFXL()
    if b then
        _time_QFXL = Timer.New(function ()
            M.QueryQFXLGiftData()
        end, 5, -1, nil, true)
        _time_QFXL:Start()
    end
end
function M.QueryQFXLGiftData()
    -- dump(111,"QueryQFXLGiftData:  ")
    Network.SendRequest("query_gift_bag_num",{gift_bag_id = M.qfxl_gift_id})
end

function M.on_query_gift_bag_num_response(_,data)
    -- dump(data,"<color=blue>on_query_gift_bag_num_response</color>")
    if data.result == 0 and data.gift_bag_id ==M.qfxl_gift_id then
        this.m_data.qfxl_num = data.num
        Event.Brocast("model_mslb_qfxl_num_change_msg")--刷新全服限量个数
        this.m_data.is_have_num = true
    end
end
function M.QueryData()
    if this.m_data.is_have_data and this.m_data.is_have_num then
        Event.Brocast("model_mslb_data_change_msg")--刷新基本信息
    else
        M.query_data()
        M.QueryQFXLGiftData()
    end
end

function M.query_data()
    Network.SendRequest("query_player_welfare_activity_base_info",{act_type = M.act_type})   
end

function M.query_player_welfare_activity_base_info_response(_,data)
    -- dump(data,"<color=yellow><size=15>++++++++++040data++++++++++</size></color>")
    if data.result == 0 then
        this.m_data.buy_time = data.buy_time                --购买时间
        this.m_data.total_remain_num = data.total_remain_num--剩余天数
        this.m_data.is_receive = data.is_receive            --是否领取
        this.m_data.login_day = data.login_day              --登录天数
        this.m_data.lottery_num = data.lottery_num          --抽奖次数
        this.m_data.server_time = data.server_time          --服务器时间
        Event.Brocast("model_mslb_data_change_msg")--刷新基本信息
        M.SetHintState()
        this.m_data.is_have_data = true
        if this.m_data.buy_time ~= 0 then
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."mslb",this.m_data.buy_time)
        end
        PlayerPrefs.SetString(M.key..MainModel.UserInfo.user_id.."change_day_mslb",os.date("%d",os.time()))
    end
end

function M.on_welfare_activity_base_info_change_msg(_,data)
    -- dump(data,"<color=yellow>+on_welfare_activity_base_info_change_msg</color>")
    if data then
        -- body
        this.m_data.buy_time=data.buy_time
        this.m_data.is_receive=data.is_receive
        this.m_data.login_day=data.login_day
        this.m_data.lottery_num=data.lottery_num
        this.m_data.total_remain_num=data.total_remain_num
    end
end
function M.on_get_one_welfare_activity_false_lottery_data_response(_,data)
    -- dump(data,"<color=red>on_get_one_welfare_activity_false_lottery_data_response:  </color>")
    
    if data.result == 0 then
        local unrealy = {}
        unrealy.name = data.name            --虚假数据的玩家昵称
        unrealy.award_name = data.award_name--虚假数据的奖励名称
        unrealy.award_id = data.award_id    --虚假数据的奖励id
        if not unrealy.award_name and unrealy.award_id then
            unrealy.award_name = M.GetAwardConfig()[data.award_id].award_txt
        end
        this.m_data.pmd_list = this.m_data.pmd_list or {}
        this.m_data.pmd_list[#this.m_data.pmd_list + 1] = unrealy
        Event.Brocast("model_mslb_unrealy_change_msg")--刷新假数据
    end
end


function M.on_welfare_activity_lottery_response(_,data)
    if data.result == 0 then
        if not this.m_data.lottery then
            this.m_data.lottery = {}
        end
        this.m_data.lottery.award_name = data.award_name--抽奖的奖励名称
        this.m_data.lottery.award_id = data.award_id    --抽奖的奖励id
        this.m_data.lottery.name = data.name            --抽奖的玩家昵称
        this.m_data.lottery_num = data.lottery_num      --抽奖次数
        local unrealy = {}
        unrealy.name = MainModel.UserInfo.name
        unrealy.award_name = data.award_name
        unrealy.award_id = data.award_id
        if not unrealy.award_name and unrealy.award_id then
            unrealy.award_name = M.GetAwardConfig()[data.award_id].award_txt
        end
        this.m_data.pmd_list = this.m_data.pmd_list or {}
        this.m_data.pmd_list[#this.m_data.pmd_list + 1] = unrealy
        Event.Brocast("model_mslb_lottery_change_msg")
    end
end

function M.on_welfare_activity_receive_award_response(_,data)
    if data.result == 0 then
        this.m_data.is_receive = 1

        Network.SendRequest("query_player_welfare_activity_base_info",{act_type = M.act_type})
        Event.Brocast("model_mslb_receive_award_change_msg")--播放领取后抽奖次数增加的的特效
    end
end


function M.on_finish_gift_shop(id)
    if id ==M.qfxl_gift_id or id ==M.qfxl_gift_id2 then
        Network.SendRequest("query_player_welfare_activity_base_info",{act_type = M.act_type})
    end
end

--获取全服限量的个数
function M.GetQFXLNum()
    return this.m_data.qfxl_num
end

------------------------------

--获取购买时间(可以判断是否购买过)
function M.GetBuyTime()
    return this.m_data.buy_time
end

--获取当前剩余天数
function M.GetTotalRemainNum()
    return this.m_data.total_remain_num
end

--获取当前是否领取
function M.GetIsReceive()
    return this.m_data.is_receive
end

--获取当前登录天数
function M.GetLoginDay()
    return this.m_data.login_day
end

--获取当前抽奖次数
function M.GetLotteryNum()
    return this.m_data.lottery_num
end

---------------------

--获取虚假数据的玩家名字
function M.GetUnrealyPlayerName()
    -- dump(this.m_data,"this.m_data:    ")
    if not table_is_null(this.m_data.pmd_list) then
        return this.m_data.pmd_list[1].name
    end
    return ""
end

--获取虚假数据的奖励名称
function M.GetUnrealyAwardName()
    if not table_is_null(this.m_data.pmd_list) then
        return this.m_data.pmd_list[1].award_name
    end
    return ""
end

--获取虚假数据的奖励id
function M.GetUnrealyAwardID()
    if not table_is_null(this.m_data.pmd_list) then
        return this.m_data.pmd_list[1].award_id
    end
    return ""
end

function M.DeletPMDList(player_name,award_id)
    if not table_is_null(this.m_data.pmd_list) then
        if player_name == this.m_data.pmd_list[1].name and award_id == this.m_data.pmd_list[1].award_id then
            table.remove(this.m_data.pmd_list,1)
        end
    end
end

---------------------

--获取抽奖的奖励名称
function M.GetLotteryAwardName()
    return this.m_data.lottery.award_name
end

--获取抽奖的奖励id
function M.GetLotteryAwardId()
    return this.m_data.lottery.award_id
end

--获取抽奖的玩家名字
function M.GetLotteryPlayerName()
    return this.m_data.lottery.name
end

function M.GetActivityConfig()
    return this.act_config.otherInfo
end

function M.GetAwardConfig()
    return this.act_config.awardConfig
end


function M.StopUpdateTime_benefits()
    if _time_benefits_data then
        _time_benefits_data:Stop()
        _time_benefits_data = nil
    end
end
function M.update_time_benefits(b)
    dump(b,"开始计时：  ")
    M.StopUpdateTime_benefits()
    if b then
        if M.CheckDayIsChange() then
            M.query_data()
        end
        _time_benefits_data = Timer.New(function ()
            if M.CheckDayIsChange() then
                M.query_data()
            end
        end, 10, -1, nil, true)
        _time_benefits_data:Start()
    end
end

function M.CheckDayIsChange()
    local cur = os.date("%d",os.time())
    local old = PlayerPrefs.GetString(M.key..MainModel.UserInfo.user_id.."change_day_mslb","-0")
    -- dump(cur,"cur----->")
    -- dump(old,"old----->")

    -- dump(cur~=old,"CheckDayIsChange:  ")
    if cur ~= old then
        return true
    end
    return false
end