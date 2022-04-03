-- 创建时间:2020-04-27
-- SYSByPmsManager 管理器

local basefunc = require "Game/Common/basefunc"
SYSByPmsManager = {}
local M = SYSByPmsManager
M.key = "sys_by_pms"
local pms_rank_config = GameButtonManager.ExtLoadLua(M.key,"sysbypms_rank_config")
local pms_rules_config = GameButtonManager.ExtLoadLua(M.key,"sysbypms_rules_config")
local pms_sign_time_congfig = GameButtonManager.ExtLoadLua(M.key,"sysbypms_sign_time_congfig")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGamePanel")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsBeginHintPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameInfoPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameRankPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameRankItem_jf")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameRankItem_pm")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameRankPanel_JFPM")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameEndPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameOutTimePanel")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameExitPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameSharePanel")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameJLTSPanel")

GameButtonManager.ExtLoadLua(M.key, "FishingMatchHallPMSPanel")
GameButtonManager.ExtLoadLua(M.key, "FishingMatchHallPMSItem")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsHallRankPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsHallRankItem")
GameButtonManager.ExtLoadLua(M.key, "FishingMatchHallBSXQPanel")

GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameRulesPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameRulesLeftPrefab")

GameButtonManager.ExtLoadLua(M.key, "SYSByPmsHallYesterdayRankItem")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsHallYesterdayRankPanel")

GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameSignUpPrefab")


--vip4回馈赛(回馈赛之所以和排名赛放一起,是因为两种赛大致差不多,vip4回馈赛在排名赛的基础上改)
GameButtonManager.ExtLoadLua(M.key, "FishingMatchHallHKSPanel")
local hks_rules_config = GameButtonManager.ExtLoadLua(M.key,"sysbyhks_rules_config")
local hks_rank_config = GameButtonManager.ExtLoadLua(M.key,"sysbyhks_rank_config")
GameButtonManager.ExtLoadLua(M.key, "SYSBYHKSGiftPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSBYHKSGameRankPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSByHKSGameEndPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSByHKSGamePanel")
GameButtonManager.ExtLoadLua(M.key, "SYSByHKSGameSignUpPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSByHKSGameInfoPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSByPmsGameRankPanel_PM")

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
    if parm.goto_scene_parm == "bytop_area" then
        if FishingModel.game_id == 1 or (not M.IsInCanSignTime() and not this.data.is_matching) or (not this.data.is_matching and (not M.QueryPMSnum() or M.QueryPMSnum() <= 0)) or (this.data.is_matching and this.data.cur_signup_id == 5) then
            return false
        end
    end
    if  parm.goto_scene_parm == "bytop_hks" then
        if this.data.is_matching and this.data.cur_signup_id ~= 5 then
            return false
        end
        if not this.data.is_matching then
            local tab = os.date("*t")
            local target_month
            local target_year
            if tab.month + 1 <= 12 then
                target_month = tab.month + 1
                target_year = tab.year
            else
                target_month = 1
                target_year = tab.year + 1
            end
            local temp = {year = target_year,month = target_month,day = 1,hour = 0,min = 0,sec = 0,isdst = false}
            local begin_time = os.time(temp) - 86400
            local end_time = os.time(temp)
            if (os.time() >= begin_time) and (os.time() <= end_time) then
                if MainModel.UserInfo.vip_level >= 4 then
                    if M.QueryHKSnum() <= 0 then
                        return false
                    end
                else
                    return false
                end
            else
                return false
            end
        end
    end
    --dump({parm=parm,data = this.data},"<color>+++++++++++++++++</color>")
    --[[if parm.goto_scene_parm == "bytop_area" then 
        if this.data.is_matching and this.data and this.data.is_anim_finish and M.IsActive() then
        else
            return false
        end
    elseif parm.goto_scene_parm == "bytop_area1" then 
        if not this.data.is_matching and this.data and FishingModel.game_id ~= 1 and M.IsActive() and M.IsInCanSignTime() then
        else
            return false
        end
    end--]]
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
--[[    if parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return SYSByPmsGameRankPrefab_JFPM.Create(parm.parent)
        end
    else--]]
    if parm.goto_scene_parm == "bytop_area" then
        return SYSByPmsGamePanel.Create(parm.parent)
    --[[elseif parm.goto_scene_parm == "bytop_area1" then
        return SYSByPmsGameSignUpPrefab.Create(parm.parent)--]]
    elseif parm.goto_scene_parm == "bytop_hks" then
        return SYSByHKSGamePanel.Create(parm.parent)
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

    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
    lister["EnterScene"] = this.on_EnterScene
    lister["ExitScene"] = this.OnExitScene
    --lister["model_shoot"] = this.on_bullet_change
    lister["query_bullet_cur_bullet_num_response"] = this.on_query_bullet_cur_bullet_num_response

    lister["bullet_rank_match_signup_response"] = this.on_bullet_rank_match_signup_response
    lister["bullet_rank_score_change_info"] = this.on_bullet_rank_score_change_info
    lister["bullet_rank_all_info_response"] = this.on_bullet_rank_all_info_response

    lister["query_bullet_rank_info_response"] = this.on_query_bullet_rank_info_response
    lister["bullet_rank_settlement"] = this.on_bullet_rank_settlement
    lister["bullet_rank_match_discard_response"] = this.on_bullet_rank_match_discard

    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg

    lister["query_bullet_rank_data_response"] = this.on_query_bullet_rank_data_response

    lister["SYSByPmsBeginHint_exit"] = this.SYSByPmsBeginHint_exit
    lister["AssetChange"] = this.AssetChange

    lister["query_bullet_rank_history_data_response"] = this.on_query_bullet_rank_history_data_response
end

function M.Init()
	M.Exit()

	this = SYSByPmsManager
	this.data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
    --
    M.StopUpdataBulletChange()
    M.StopUpdateTime_query_PMS_Info()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    this.pms_rank_map = {}
    for k,v in ipairs(pms_rank_config.config) do
        this.pms_rank_map[v.game_id] = this.pms_rank_map[v.game_id] or {}
        local dd = {}
        dd.min_rank = v.rank_range[1]
        dd.max_rank = v.rank_range[2]
        dd.award_list = {}
        for i = 1, #v.award_type do
            local cc = {}
            cc.type = v.award_type[i]
            cc.icon = v.award_icon[i]
            cc.num = v.award_num[i]
            dd.award_list[#dd.award_list + 1] = cc
        end
        this.pms_rank_map[v.game_id][#this.pms_rank_map[v.game_id] + 1] = dd
    end

    this.hks_rank_map = {}
    for k,v in ipairs(hks_rank_config.config) do
        local dd = {}
        dd.min_rank = v.rank_range[1]
        dd.max_rank = v.rank_range[2]
        dd.award_list = {}
        for i = 1, #v.award_type do
            local cc = {}
            cc.type = v.award_type[i]
            cc.icon = v.award_icon[i]
            cc.num = v.award_num[i]
            dd.award_list[#dd.award_list + 1] = cc
        end
        this.hks_rank_map[#this.hks_rank_map + 1] = dd
    end

    -- 排名赛
    this.UIConfig.fish_match_pms_map = {}
    this.UIConfig.fish_match_pms_list = {}
    this.UIConfig.fish_match_pms_award = {}
    for k,v in ipairs(pms_rank_config.pms_config) do
        this.UIConfig.fish_match_pms_list[#this.UIConfig.fish_match_pms_list + 1] = v
        this.UIConfig.fish_match_pms_map[v.id] = v
    end
    for k,v in ipairs(pms_rank_config.pms_award) do
        if not this.UIConfig.fish_match_pms_award[v.award_id] then
            this.UIConfig.fish_match_pms_award[v.award_id] = {}
        end
        this.UIConfig.fish_match_pms_award[v.award_id][#this.UIConfig.fish_match_pms_award[v.award_id] + 1] = v
    end

end

--切到后台
function M.on_background_msg()
    Event.Brocast("SYSByPms_on_background_msg")
end

--切回前台
function M.on_backgroundReturn_msg()
    Event.Brocast("SYSByPms_on_backgroundReturn_msg")
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        Network.SendRequest("query_gift_bag_status",{gift_bag_id = M.GetHKSGiftID()})
        Network.SendRequest("query_bullet_rank_info", {id = 5})
	end
end
function M.OnReConnecteServerSucceed()
end

function M.SYSByPmsBeginHint_exit()
    this.data.is_anim_finish = true
    --Event.Brocast("ui_button_state_change_msg")
    Event.Brocast("SYSBYPMS_is_anim_finish_msg")
end
function M.on_bullet_rank_all_info_response(_,data)
    dump(data,"<color=blue>UUUUUUUUUUUUUUUUUUUUUUU</color>")
    if data.result == 0 then
        this.data.is_matching = true
        this.data.max_bullet = data.match_info.bullet_count
        this.data.cur_bullet = data.match_info.bullet_count - data.match_info.bullet_num
        this.data.rank = data.match_info.cur_rank
        this.data.max_count = 20
        this.data.end_time = data.match_info.end_time
        this.data.cur_score = data.match_info.score
        this.data.part_data = data.part_data
        this.data.cur_signup_id = data.match_info.id
        if this.data.max_bullet ~= this.data.cur_bullet then
            this.data.is_enter_fishing = false
        end
        this.data.is_anim_finish = false
        if data.match_info.id >= 1 and data.match_info.id <= 4 then
            if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."pms") == 0 then--非重连
                this.data.timer = Timer.New(function ()
                    SYSByPmsBeginHintPrefab.Create()
                    end, 0.5, 1, false)
                this.data.timer:Start()
            else
                this.data.is_anim_finish = true
                Event.Brocast("ui_button_state_change_msg")
            end
            Event.Brocast("SYSByPms_enter_scene",false)
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."pms",os.time()) 
        elseif data.match_info.id == 5 then
            if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."hks") == 0 then--非重连
                this.data.timer = Timer.New(function ()
                    SYSByPmsBeginHintPrefab.Create()
                    end, 0.5, 1, false)
                this.data.timer:Start()
            else
                this.data.is_anim_finish = true
                Event.Brocast("ui_button_state_change_msg")
            end
            Event.Brocast("SYSByPms_enter_scene",false)
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."hks",os.time()) 
        end 
    else
        this.data.is_matching = false
    end
    dump(this.data.cur_signup_id,"<color=blue>UUUUUUUUUUUUUUUUUUUUUUU</color>")
    Event.Brocast("SYSBYPMS_signup_is_success_msg")
end

function M.signup_hks(parm)
    local data = parm.data
    local call = function ()
        if this.data.hks_game_info.num > 0 then
            Network.SendRequest("bullet_rank_match_signup", {id=5}, "", function (data)
                dump(data, "<color=red>EEEEEEEEEE signup</color>")
                if data.result == 0 then
                    if MainModel.myLocation ~= "game_Fishing3D" then
                        Network.SendRequest("fsg_3d_signup", {id = 3}, "请求报名", function (data)
                            if data.result == 0 then
                                GameManager.GotoSceneName("game_Fishing3D", {game_id = 3})
                            else
                                HintPanel.ErrorMsg(data.result)
                            end
                        end)
                    else
                        if FishingModel.game_id == 3 then
                            Network.SendRequest("bullet_rank_all_info")
                        else
                            FishingModel.GotoFishingByID(3,true)
                        end
                    end
                    -- 当前参赛的ID
                    this.data.cur_signup_id = data.id
                else
                    HintPanel.ErrorMsg(data.result)
                end
            end)
        end
    end
    if this.data.hks_game_info then
        call()
    else
        Network.SendRequest("query_bullet_rank_info", {id = 5}, "", function (data)
            if #data.my_rank_data == 4 then
            else
                this.data.hks_game_info = data
                call()
            end
        end)
    end
end


function M.signup(parm)
    dump(parm)
    local data = parm.data
    local call = function ()
        if this.data.pms_game_info.num > 0 then
            local item_index = M.CheckPMSIsCanSignup(data.id)
            dump(item_index)
            if item_index.result == -1 then--报名物品均不足,"提示金币不足"，并弹出商城界面
                HintPanel.Create(2,"报名费不足!需要报名费"..item_index.txt.."金币,是否前往充值?", function ()
                    PayPanel.Create("jing_bi", "pc")         
                end)
            else
                if item_index.type and item_index.type == "Too_much" then--至少满足一种报名物品,但玩家"太富有了请进行更高级场的比赛"
                    HintPanel.Create(1,item_index.txt)
                elseif item_index.type and item_index.type == "Too_little" then--不满足入场下限,"提示金币不足,至少需要XXX金币"，并弹出商城界面
                    HintPanel.Create(2,item_index.txt, function ()
                        PayPanel.Create("jing_bi", "pc")                    
                    end)
                elseif item_index.type and item_index.type == "Level_NoEnough" then--等级不足
                    HintPanel.Create(1,item_index.txt)
                else
                    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing3d_"..(data.id + 1)}, "CheckCondition")
                    if a and not b then
                        return
                    end
                    dump(GameItemModel.GetItemCount("prop_gns_ticket"),"<color>+++++++++++++++++++++++++++</color>")
                    M.set_signup(data)--至少满足一种报名物品,且满足上下限要求,可以报名
                end
            end
        else
            HintPanel.Create(1,"今日可报名次数不足,报名失败")
        end
    end
    if this.data.pms_game_info then
        call()
    else
        Network.SendRequest("query_bullet_rank_info", nil, "", function (data)
            if #data.my_rank_data == 4 then
                this.data.pms_game_info = data
                call()
            end
        end)
    end
end
function M.set_signup(data)
    local call = function ()
        if MainModel.myLocation ~= "game_Fishing3D" then
            local cfg = M.GetPMSGameIDToConfig(data.id)
            dump(cfg.game_id)
            Network.SendRequest("fsg_3d_signup", {id = cfg.game_id}, "请求报名", function (data)
                if data.result == 0 then
                    GameManager.GotoSceneName("game_Fishing3D", {game_id = cfg.game_id})
                else
                    HintPanel.ErrorMsg(data.result)
                end
            end)
        else
            this.data.is_enter_fishing = true
            Network.SendRequest("bullet_rank_all_info")
        end
        -- 当前参赛的ID
        this.data.cur_signup_id = data.id
    end
    Network.SendRequest("bullet_rank_match_signup", {id=data.id}, "", function (data)
        dump(data, "<color=red>EEEEEEEEEE signup</color>")
        if data.result == 0 then
            call()
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end


function M.on_EnterScene()
    if MainModel.myLocation == "game_Fishing3D" then
        this.data.is_enter_fishing = true
    else
        this.data.is_enter_fishing = false
    end
end

function M.OnExitScene()

end

function M.on_fishing_ready_finish()
    if MainModel.myLocation == "game_Fishing3D" then
        Network.SendRequest("bullet_rank_all_info")
        if this.data.is_enter_fishing then
            --SYSByPmsGamePanel.Create()
        end
        this.data.is_enter_fishing = false
    end
end

function M.RequestGameData()
    -- todo
--[[    this.data.cur_bullet = 1000
    this.data.max_bullet = 1000
    this.data.rank = 8
    this.data.max_count = 20
    this.data.cur_time = os.time() + 666
    this.data.cur_score = 123456
    Event.Brocast("model_sys_by_pms_game_data")--]]
end

function M.GetSignupData()
    return this.data.cur_signup_id
end

function M.get_pms_state()
    
end

-- 当前排名
function M.GetCurRank()
    return this.data.rank
end
--[[-- 当前历史最好排名
function M.()
    -- body
end--]]


function M.GetMaxRank()
    return this.data.max_count
end
function M.on_rank_change()
    Event.Brocast("model_sys_by_pms_rank_change")
end

-- 当前分数
function M.GetCurScore()
    return this.data.cur_score
end
-- 当前段位
function M.GetCurDotLv()
    local award_config = M.GetPMSAwardByID(M.GetSignupData())
    for i=1,#award_config do
        if M.GetCurScore() >= tonumber(award_config[i].min_score) then
            return i
        end
    end
end
function M.on_score_change()
    Event.Brocast("model_sys_by_pms_score_change")
end
-- 获取当前段位人数
function M.GetCurDotNum(id)
    dump(this.data.part_data,"<color=blue>++++++++++++++this.data.part_data++++++++++++++</color>")
    dump(id,"<color=blue>+++++++++++++id+++++++++++++++</color>")
    if this.data.part_data and this.data.part_data[id] then
        return this.data.part_data[id]
    else
        return 0
    end
end

-- 当前子弹数
function M.GetCurBullet()
    return this.data.cur_bullet
end
function M.GetMaxBullet()
    return this.data.max_bullet
end
--[[function M.on_bullet_change(data)
    if M.IsMatching() and FishingModel and FishingModel.GetPlayerSeat and data and data.seat_num == FishingModel.GetPlayerSeat() then
        if this.data.cur_bullet > 0 then
            this.data.cur_bullet = this.data.cur_bullet - 1
        end
        Event.Brocast("model_sys_by_pms_bullet_change")
    end
end--]]

function M.on_query_bullet_cur_bullet_num_response(_,data)
    if data.result == 0 then
        if M.IsMatching() then
            this.data.cur_bullet = M.GetMaxBullet() - data.bullet_num 
            Event.Brocast("model_sys_by_pms_bullet_change")
        end
    end
end

function M.StopUpdataBulletChange()
    if M.timer then
        M.timer:Stop()
        M.timer = nil
    end
end

function M.UpdataBulletChange(b)
    M.StopUpdataBulletChange()
    if b then
        M.timer = Timer.New(function ()
                M.query_bullet_num()
        end,1,-1,false,true)
        M.timer:Start()
    end
end

function M.query_bullet_num()
    Network.SendRequest("query_bullet_cur_bullet_num",{id = M.GetSignupData()})
end

function M.on_bullet_rank_settlement(_,data)
    dump(data,"<color=red>+++++++++++++on_bullet_rank_settlement+++++++++++</color>")
    this.data.is_matching = false
    Event.Brocast("ui_button_state_change_msg")

    if data.id == 5 then
        if this.data.hks_game_info then
            this.data.hks_game_info.num = data.num
        end
        SYSByHKSGameEndPanel.Create(data)
    elseif data.id >= 1 and data.id <= 4 then
        if this.data.pms_game_info then
            this.data.pms_game_info.num = data.num
        end
        SYSByPmsGameEndPanel.Create(data)
    end
    
    --[[if data.reason == "bullet_out" then--子弹用完
        SYSByPmsGameEndPanel.Create(data)
    elseif data.reason == "time_out" then--超时
        SYSByPmsGameOutTimePanel.Create(data)
    elseif data.reason == "discard" then--退赛
        SYSByPmsGameEndPanel.Create(data)
    end--]]
    Event.Brocast("ui_button_state_change_msg")
    Event.Brocast("SYSBYPMS_the_match_is_exit_msg")
    Event.Brocast("SYSByPms_enter_scene",true)
end

-- 当前时间
function M.GetCurTime()
    local tt = this.data.end_time - os.time()
    return tt
end

function M.on_bullet_rank_score_change_info(_,data)
    this.data.cur_score = data.score
    M.on_score_change()
end

function M.GetRankConfig()
    return M.rank_config
end


function M.GetPMSGameInfo()
    Network.SendRequest("query_bullet_rank_info")
end

function M.GetHKSGameInfo()
    Network.SendRequest("query_bullet_rank_info", {id = 5}, "")
end

function M.on_query_bullet_rank_info_response(_,data)
    dump(data,"<color=yellow>+++++++++++++++++++++</color>")
    if data.result == 0 then
        if #data.my_rank_data == 4 then
            this.data.pms_game_info = data
        else
            this.data.hks_game_info = data
        end
        
        Event.Brocast("model_pms_game_info_change_msg")
    end
end

function M.QueryCurPMSGameInfo()
    if this.data.pms_game_info then
        Event.Brocast("model_pms_game_info_change_msg")
    else
        Network.SendRequest("query_bullet_rank_info", nil, "")
    end
end

function M.QueryCurHKSGameInfo()
    if this.data.hks_game_info then
        Event.Brocast("model_pms_game_info_change_msg")
    else
        Network.SendRequest("query_bullet_rank_info", {id = 5}, "")
    end
end

function M.GetCurPMSGameInfo()
    return this.data.pms_game_info
end

function M.StopUpdateTime_query_PMS_Info()
    if _time then
        _time:Stop()
        _time = nil
    end
end
function M.update_time_query_PMS_Info()
    --[[M.StopUpdateTime_query_PMS_Info()
    if b then
        _time = Timer.New(function ()
            Network.SendRequest("query_bullet_rank_info")
            Network.SendRequest("query_bullet_rank_info",{id = 5})
        end, 60, -1, nil, true)
        _time:Start()
    end--]]
end

--获取当前场次配置信息
function M.GetCurBSData()   
    local config = M.GetFishingPMSListAndSort()
    return config[this.data.cur_signup_id]
end

function M.IsMatching()
    return this.data.is_matching
end

function M.on_bullet_rank_match_discard(_,data)
    if data.result == 0 then
        this.data.is_matching = false
        dump(this.data,"<color=red><size=35>退赛成功</size></color>")
    else
        dump("<color=red><size=35>退赛失败</size></color>")
    end
end

function M.GetHallRank_data(type, id, page)
    print(debug.traceback())
    dump(type,"<color=yellow><size=15>++++++++++type++++++++++</size></color>")
    dump(id,"<color=yellow><size=15>++++++++++id++++++++++</size></color>")
    dump(page,"<color=yellow><size=15>++++++++++page++++++++++</size></color>")
    if type == "pms" then
        if this.data.hall_rank_data and this.data.hall_rank_data[id] and this.data.hall_rank_data[id].tot_rank_data[page] and (os.time() - this.data.hall_rank_data[id].time <= 10) then
            Event.Brocast("SYSByPms_query_bullet_rank_data", this.data.hall_rank_data[id].tot_rank_data[page],"pms")
            Event.Brocast("SYSByPms_query_bullet_myrank_data", this.data.hall_rank_data[id].my_rank_data,"pms")
        else
            Network.SendRequest("query_bullet_rank_data",{id = id,page_index = page})
        end
    elseif type == "hks" then
        if this.data.hall_rank_data and this.data.hall_rank_data[id] and this.data.hall_rank_data[id].tot_rank_data[page] and (os.time() - this.data.hall_rank_data[id].time <= 10) then
            Event.Brocast("SYSByPms_query_bullet_rank_data", this.data.hall_rank_data[id].tot_rank_data[page],"hks")
            Event.Brocast("SYSByPms_query_bullet_myrank_data", this.data.hall_rank_data[id].my_rank_data,"hks")
        else
            Network.SendRequest("query_bullet_rank_data",{id = id,page_index = page})
        end
    end
end


function M.on_query_bullet_rank_data_response(_,data)
    dump(data,"<color=yellow>UUUUUUUUUUUUUUUUUUUUUUUUUUU</color>")
    if data.result == 0 then
        local id = data.id
        local page = data.page
        this.data.hall_rank_data = this.data.hall_rank_data or {}
        this.data.hall_rank_data[id] = this.data.hall_rank_data[id] or {}

        this.data.hall_rank_data[id].time = os.time()
        this.data.hall_rank_data[id].my_rank_data = data.my_rank_data
        this.data.hall_rank_data[id].tot_rank_data = this.data.hall_rank_data[id].tot_rank_data or {}
        if not data.tot_rank_data then
            this.data.hall_rank_data[id].tot_rank_data[page] = data.tot_rank_data
        end
        if data.id >= 1 and data.id <= 4 then
            Event.Brocast("SYSByPms_query_bullet_rank_data", data.tot_rank_data,"pms")
            Event.Brocast("SYSByPms_query_bullet_myrank_data", data.my_rank_data,"pms")
        else
            Event.Brocast("SYSByPms_query_bullet_rank_data", data.tot_rank_data,"hks")
            Event.Brocast("SYSByPms_query_bullet_myrank_data", data.my_rank_data,"hks")
        end
    end
end


function M.CloseRankData(type,id)
    -- 清除缓存数据
    if type == "pms" then
        if this.data.hall_rank_data and this.data.hall_rank_data[id] then
            this.data.hall_rank_data[id] = nil
        end
    elseif type == "hks" then
        if this.data.hall_rank_data and this.data.hall_rank_data[id] then
            this.data.hall_rank_data[id] = nil
        end
    end
end

-- 排名赛段位奖励 
function M.GetPMSAwardCfgByRank(id, rank,type)
    if type == "pms" then
        dump({id = id ,map = this.pms_rank_map},"<color=red>+++++++++++++++////+++++++++</color>")
        if this.pms_rank_map[id] then
            for k,v in ipairs(this.pms_rank_map[id]) do
                if v.min_rank <= rank and rank <= v.max_rank then
                    return v.award_list
                end
            end
        end
    elseif type == "hks" then
        for k,v in ipairs(this.hks_rank_map) do
            if (v.min_rank <= rank and (v.max_rank == -1 or rank <= v.max_rank)) or (rank == -1 and rank == v.max_rank) then
                return v.award_list
            end
        end
    end
end


-- 排名赛列表
function M.GetFishingPMSListAndSort()
    local cfg = M.UIConfig.fish_match_pms_list
    dump(cfg,"<color=yellow>++++++++++++++++++++cfg++++++++++++++++++++</color>")
    MathExtend.SortList(cfg, "ui_order", true)
    return cfg
end

function M.GetFishingPMSAwardListAndSort()
    local cfg = M.UIConfig.fish_match_pms_award
    return cfg
end
function M.GetPMSAwardByID(id)
    local cfg = M.GetPMSGameIDToConfig(id)
    return M.UIConfig.fish_match_pms_award[cfg.award_id]
end
function M.GetPMSGameIDToConfig(id)
    if M.UIConfig.fish_match_pms_map[id] then
        return M.UIConfig.fish_match_pms_map[id]
    end
    dump(id, "<color=red>EEEEEEEEEEEEEEEEEEE id</color>")
end

-- 检查排名赛
function M.CheckPMSIsCanSignup(id)
    local config = M.GetPMSGameIDToConfig(id)
    local data = {}
    if not config or not config.enter_condi_itemkey or not config.enter_condi_item_count then
        data.result = 0 
        return data--免费报名类型
    end
    local itemKeys = config.enter_condi_itemkey
    local itemCost = config.enter_condi_item_count
    for i = 1, #itemKeys do
        if GameItemModel.GetItemCount(itemKeys[i]) >= itemCost[i] then
            -- 处理金币报名后钱不足的情况
            if itemKeys[i] == "jing_bi" then
                local jb = 0
                jb = itemCost[i]
                dump(jb,"<color=red>--------------------</color>")
                local can_sign = GameFishing3DManager.CheckCanBeginGameIDByGold2(config.game_id, GameFishing3DManager.GetFishCoinAndJingBi() - jb)
                if can_sign == 0 then
                    data.result = i                
                    return data--至少满足一种报名物品,且满足上下限要求,可以报名
                elseif can_sign == -1 then
                    local cfg = GameFishing3DManager.GetGameIDToConfig(config.game_id)
                    data.result = i
                    data.type = "Too_little"
                    dump(cfg.enter_min,"<color=red>+++++++++++++++++</color>")
                    data.txt = "该场次需要携带" .. (cfg.enter_min + jb) .. "以上金币才可进入,是否前往购买金币?"
                    return data--不满足入场下限,"提示金币不足,至少需要XXX金币"，并弹出商城界面    
                elseif can_sign == 4 then
                    data.result = i
                    data.type = "Level_NoEnough" 
                    data.txt = "等级不足" 
                    return data--等级不足
                else
                    data.result = i
                    data.type = "Too_much"
                    data.txt = "您太富有了,请进行更高级场的比赛"
                    return data--至少满足一种报名物品,但玩家"太富有了请进行更高级场的比赛"
                end
            else--如果票够
                local cfg = GameFishing3DManager.GetGameIDToConfig(config.game_id)
                data.result = i
                if ((not cfg.enter_min) or (MainModel.UserInfo.jing_bi >= cfg.enter_min)) and ((not cfg.enter_max) or (MainModel.UserInfo.jing_bi <= cfg.enter_max)) then
                    return data
                elseif cfg.enter_min and (MainModel.UserInfo.jing_bi < cfg.enter_min) then
                    data.type = "Too_little"
                    data.txt = "该场次需要携带" .. (cfg.enter_min) .. "以上金币才可进入,是否前往购买金币?"   
                    return data
                elseif cfg.enter_max and (MainModel.UserInfo.jing_bi > cfg.enter_max) then
                    data.type = "Too_much"
                    data.txt = "您太富有了,请进行更高级场的比赛"
                    return data
                end               
            end 
        end
    end
    data.result = -1
    local qian
    for i=1,#itemKeys do
        if itemKeys[i] == "jing_bi" then
            qian = itemCost[i]
        end
    end
    data.txt = qian
    return data--报名物品均不足,"提示金币不足"，并弹出商城界面
end


function M.AssetChange(data)
    if data.change_type and string.sub(data.change_type,1,24) == "bullet_rank_award_settle" then
        this.data.asset_tab = this.data.asset_tab or {}
        if data.change_type == "bullet_rank_award_settle_1" then
            this.data.asset_tab[1] = data
        elseif data.change_type == "bullet_rank_award_settle_2" then
            this.data.asset_tab[2] = data
        elseif data.change_type == "bullet_rank_award_settle_3" then
            this.data.asset_tab[3] = data
        end
        Event.Brocast("SYSByPmsManager_RefreshAssetTab_msg")
    end
end

function M.GetAssetTab()
    return this.data.asset_tab
end

function M.DeletAssetTab(index)
    if index then
        this.data.asset_tab[index] = nil
    else
        this.data.asset_tab = nil
    end
end

function M.GetRulseConfig(type)
    if type then
        if type == "hks" then
            return hks_rules_config
        elseif type == "pms" then
            return pms_rules_config
        end
    end
end

function M.GetTJGameID()
    return GameFishing3DManager.GetTJGameID()
end

function M.GetHallYesterdayRank_data(type, id, page)
    if type == "pms" then
        if this.data.hall_yesterday_rank_data and this.data.hall_yesterday_rank_data[id] and this.data.hall_yesterday_rank_data[id].his_rank_data[page] and (os.time() - this.data.hall_yesterday_rank_data[id].time <= 10) then
            Event.Brocast("SYSByPms_query_bullet_rank_history_data", this.data.hall_yesterday_rank_data[id].his_rank_data[page])
            Event.Brocast("SYSByPms_query_bullet_history_myrank_data", this.data.hall_yesterday_rank_data[id].my_rank_data)
        else
            Network.SendRequest("query_bullet_rank_history_data",{id = id,page_index = page})
        end
    elseif type == "hks" then
        if this.data.hall_yesterday_rank_data and this.data.hall_yesterday_rank_data[id] and this.data.hall_yesterday_rank_data[id].his_rank_data[page] and (os.time() - this.data.hall_yesterday_rank_data[id].time <= 10) then
            Event.Brocast("SYSByPms_query_bullet_rank_history_data", this.data.hall_yesterday_rank_data[id].his_rank_data[page],"hks")
            Event.Brocast("SYSByPms_query_bullet_history_myrank_data", this.data.hall_yesterday_rank_data[id].my_rank_data,"hks")
        else
            Network.SendRequest("query_bullet_rank_history_data",{id = id,page_index = page})
        end
    end
end


function M.on_query_bullet_rank_history_data_response(_,data)
    dump(data,"<color=yellow>UUUUUUUUUUUUUUUUUUUUUUUUUUU</color>")
    if data.result == 0 then
        local id = data.id
        local page = data.page
        this.data.hall_yesterday_rank_data = this.data.hall_yesterday_rank_data or {}
        this.data.hall_yesterday_rank_data[id] = this.data.hall_yesterday_rank_data[id] or {}

        this.data.hall_yesterday_rank_data[id].time = os.time()
        this.data.hall_yesterday_rank_data[id].my_rank_data = data.my_rank_data
        this.data.hall_yesterday_rank_data[id].his_rank_data = this.data.hall_yesterday_rank_data[id].his_rank_data or {}
        if not data.his_rank_data then
            this.data.hall_yesterday_rank_data[id].his_rank_data[page] = data.his_rank_data
        end
        if data.id >= 1 and data.id <= 4 then
            Event.Brocast("SYSByPms_query_bullet_rank_history_data", data.his_rank_data,"pms")
            Event.Brocast("SYSByPms_query_bullet_history_myrank_data", data.my_rank_data,"pms")
        else
            Event.Brocast("SYSByPms_query_bullet_rank_history_data", data.his_rank_data,"hks")
            Event.Brocast("SYSByPms_query_bullet_history_myrank_data", data.my_rank_data,"hks")
        end
    end
end


function M.GetSignTimeConfig()
    return pms_sign_time_congfig
end

--是否在可报名时间内
function M.IsInCanSignTime()
    local sign_time_config = M.GetSignTimeConfig()
    local h = os.date("%H", os.time())
    local f = os.date("%M", os.time())
    local m = os.date("%S", os.time())
    local cur_all = h*3600 + f*60 + m
    if cur_all >= sign_time_config[#sign_time_config].timestamp_max and cur_all <= 86400 then--明日开赛
        this.data.time_status = "tomorrow"
        return false
    end
    for i=1,#sign_time_config do
        if sign_time_config[i].timestamp_min >= cur_all then--倒计时
            this.data.time_status = "time"
            return false
        elseif sign_time_config[i].timestamp_min < cur_all and sign_time_config[i].timestamp_max > cur_all then--立刻参赛
            this.data.time_status = "now"
            return true
        end
    end
end


function M.CheckCreateWho()
    if not this.data.is_matching and this.data and M.IsActive() and M.IsInCanSignTime() then
        return 2
    elseif this.data.is_matching and this.data and this.data.is_anim_finish and M.IsActive() then
        return 1 
    end
end


function M.QueryPMSnum()
    if this.data.pms_game_info then
        return this.data.pms_game_info.num
    else
        Network.SendRequest("query_bullet_rank_info",nil,"",function (data)
            if data.result == 0 then
                if #data.my_rank_data == 4 then
                    this.data.pms_game_info = data
                    return this.data.pms_game_info.num
                end
            else
                return -1
            end
        end)
    end
end


function M.QueryHKSnum()
    if this.data.hks_game_info then
        return this.data.hks_game_info.num
    else
        Network.SendRequest("query_bullet_rank_info",{id = 5},"",function (data)
            if data.result == 0 then
                if #data.my_rank_data == 4 then
                else
                    this.data.hks_game_info = data
                    return this.data.hks_game_info.num
                end
            else
                return -1
            end
        end)
    end
end

--检查当前是否在月末那一天(在是5,不在是6)
function M.CheckCurIsInHKSDay()
    local tab = os.date("*t")
    local target_month
    local target_year
    if tab.month + 1 <= 12 then
        target_month = tab.month + 1
        target_year = tab.year
    else
        target_month = 1
        target_year = tab.year + 1
    end
    local temp = {year = target_year,month = target_month,day = 1,hour = 0,min = 0,sec = 0,isdst = false}
    local begin_time = os.time(temp) - 86400
    local end_time = os.time(temp)
    if (os.time() >= begin_time) and (os.time() <= end_time) then
        return 5
    else
        return 6
    end
end

function M.GetCanSignHKSTimes()
    local num = M.QueryHKSnum()
    --dump(num,"<color=yellow><size=15>++++++++++num++++++++++</size></color>")
    --dump(M.CheckHKSGiftIsBought(),"<color=yellow><size=15>++++++++++M.CheckHKSGiftIsBought()++++++++++</size></color>")
    if num then
        if M.CheckHKSGiftIsBought() then
            return {free = 0,no_free = num}
        else
            return {free = num - 10,no_free = 0}
        end
    else
        return false
    end
end

function M.CheckHKSGiftIsBought()
    if MainModel.IsHadBuyGiftByID(M.GetHKSGiftID()) then
        return true
    else
        return false
    end
end

function M.GetHKSGiftID()
    return 10666
end

function M.CheckCreateWhoHKS()
    if not this.data.is_matching and this.data and M.IsActive() and M.CheckCurIsInHKSDay() == 5 then
        return 2
    elseif this.data.is_matching and this.data and this.data.is_anim_finish and M.IsActive() then
        return 1 
    end
end
