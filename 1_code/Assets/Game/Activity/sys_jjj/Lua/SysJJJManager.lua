local basefunc = require "Game/Common/basefunc"
SysJJJManager = {}
local M = SysJJJManager
M.key = "sys_jjj" -- 救济金
M.config = GameButtonManager.ExtLoadLua(M.key,"sysjjj_config")
GameButtonManager.ExtLoadLua(M.key, "SYSJJJ_JYFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSJJJPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSJJJOnePanel")

local lister
local send_time
function M.CheckIsShow()
    return true
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "jyfl_enter" then 
        return SYSJJJ_JYFLEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then 
        return SYSJJJPanel.Create()
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg, cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister = nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = M.OnLoginResponse
    lister["ReConnecteServerResponse"] = M.OnReConnecteServerSucceed
    lister["AssetChange"] =  M.RefreshJYFLEnter
    lister["free_broke_subsidy_response"] =  M.RefreshJYFLEnter
    lister["share_count_change_msg"] = M.RefreshJYFLEnter

    lister["query_send_list_fishing_msg"] = M.on_query_send_list_fishing_msg
    lister["query_broke_subsidy_num_response"] = M.on_query_broke_subsidy_num_response
    lister["query_free_broke_subsidy_num_response"] = M.on_query_free_broke_subsidy_num_response

    lister["ExitScene"] = M.OnExitScene
end

function M.Init()
    M.Exit()
    m_data = {}
    MakeLister()
    AddLister()
    
    for k,v in pairs(M.config.config) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.permission, is_on_hint = true}, "CheckCondition")
        if a and b then
            GAME_Di_Bao_JB = v.GAME_Di_Bao_JB
            GAME_Di_Bao_JB_HH = v.GAME_Di_Bao_JB_HH
            GAME_Di_Bao_limit = v.GAME_Di_Bao_limit
            M.HH_btn_desc = v.HH_btn_desc
            M.HH_tips = v.HH_tips
            M.goto_ui_condikey = v.goto_ui_condikey
            M.goto_ui = v.goto_ui
            M.goto_ui_tip = v.goto_ui_tip
            break
        end
    end

end

function M.Exit()
    if M then
        M.check_time = nil
        M.StopTime()
        RemoveLister()
    end
end
function M.OnExitScene()
    M.check_time = nil
end
function M.StopTime()
    if send_time then
        send_time:Stop()
        send_time = nil
    end
end
function M.OnLoginResponse(result)
    if result == 0 then
        send_time = Timer.New(function ()
            M.StopTime()
            M.SentQ()
        end, 2, 1)
        send_time:Start()
    end
end
function M.OnReConnecteServerSucceed()
    send_time = Timer.New(function ()
        M.StopTime()
        M.SentQ()
    end, 2, 1)
    send_time:Start()
end
function M.SentQ()
    if not MainModel.UserInfo.shareCount or not MainModel.UserInfo.freeSubsidyNum then
        local msg_list = {}
        msg_list[#msg_list + 1] = {msg="query_broke_subsidy_num"}
        msg_list[#msg_list + 1] = {msg="query_free_broke_subsidy_num"}
        GameManager.SendMsgList("jjj_num", msg_list)
    end
end
function M.on_query_send_list_fishing_msg(tag)
    if tag == "jjj_num" then
        M.RefreshJYFLEnter()
        if MainModel.myLocation == "game_Hall" then
            M.CheckAndRunJJJ({type="ldb"})
        end
    end
end

function M.GetHintState(parm)
    if M.CheakNumAndJB() then 
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end
end

function M.RefreshJYFLEnter() 
    Event.Brocast("global_hint_state_change_msg", {gotoui = M.key})
end

function M.CheakNumAndJB()
    if M.GetCurCount() <= 0 or MainModel.UserInfo.jing_bi >= GAME_Di_Bao_limit then
		return false
	else
		return true
	end 
end

function M.on_query_broke_subsidy_num_response(_,data)
    dump(data,"<color=red>分享救济金数据</color>")
    if data.result == 0 then
        MainModel.UserInfo.shareCount = data.num
        MainModel.UserInfo.shareAllNum = data.all_num

        Event.Brocast("global_hint_state_change_msg", {gotoui = M.key})
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_query_free_broke_subsidy_num_response(_,data)
    dump(data,"<color=red>免费救济金数据</color>")
    if data.result == 0 then
        MainModel.UserInfo.freeSubsidyNum = data.num
        MainModel.UserInfo.freeSubsidyAllNum = data.all_num

        Event.Brocast("global_hint_state_change_msg", {gotoui = M.key})
    else
        HintPanel.ErrorMsg(data.result)
    end
end
local open_jjj = function (call)
    if MainModel.UserInfo.freeSubsidyNum and MainModel.UserInfo.freeSubsidyNum > 0 then
        
        local a,b = GameButtonManager.RunFunExt("sys_011_yueka_new", "IsBuySmallYueKa")
        local c,d = GameButtonManager.RunFunExt("sys_act_czzk", "CheckIsBoughtZK")
        --dump({a=a,b=b,c=c,d=d},"<color=yellow><size=15>++++++++++open_jjj++++++++++</size></color>")
        if (a and not b) and (c and not d) then
            SYSJJJOnePanel.Create(call)
        else
            Network.SendRequest("free_broke_subsidy", nil, "请求数据",function(data)
                dump(data, "<color=white>free_broke_subsidy</color>")
                if data.result == 0 then
                    MainModel.UserInfo.freeSubsidyNum = MainModel.UserInfo.freeSubsidyNum - 1
                    M.RefreshJYFLEnter()
                    Event.Brocast("sys_exit_ask_refresh_msg")
                else
                    HintPanel.ErrorMsg(data.result)
                end
            end)
        end
    else
        SYSJJJPanel.Create(call)
    end
end
function M.CheckAndRunJJJ(parm)
    if M.check_time and (M.check_time + 1) > os.time() then
        return
    end
    M.check_time = os.time()
    if parm.type and parm.type == "ldb" then
        print("<color=red>检查低保</color>")
        if M.CheakNumAndJB() then
            open_jjj()
        else
            if parm.no_run_call then
                parm.no_run_call()
            end
        end
    else
        if MainModel.myLocation == "game_Fishing3D" and (FishingModel.game_id == 3 or FishingModel.game_id == 4 or FishingModel.game_id == 5) then
            --2021.11.16运营需求(时来运转礼包需求)
            --3d捕鱼后三个场的破产单独做,因为他存在已经无法满足开炮的钱,但还没低于低保线的情况
            local a,config = GameButtonManager.RunFunExt("act_064_slyz", "GetCurConfig")
            if a and not table_is_null(config) then
                if MainModel.IsCanBuyGiftByID(config.gift_id) then
                    Event.Brocast("ui_button_data_change_msg", { key = "act_064_slyz" })
                    GameManager.CommonGotoScence({gotoui = "act_064_slyz",goto_scene_parm = "panel",callback = function ()
                    end})
                else
                    Event.Brocast("show_gift_panel")
                end
            end
        else
            print("<color=red>破产流程</color>")
            if M.CheakNumAndJB() then
                local status1yuan = MainModel.GetGiftShopStatusByID(10)
                if status1yuan == 0 and MainModel.UserInfo.freeSubsidyNum <= 0 and MainModel.UserInfo.shareCount <= 0 then
                    Event.Brocast("show_gift_panel")
                else
                    if status1yuan == 1 then
                        GameShop1YuanPanel.Create(nil, function ()
                            status1yuan = MainModel.GetGiftShopStatusByID(10)
                            if status1yuan == 1 then
                                open_jjj(function ()
                                    Event.Brocast("show_gift_panel")
                                end)
                            end
                        end)
                    else
                        open_jjj(function ()
                            Event.Brocast("show_gift_panel")
                        end)
                    end
                end
            else
                if parm and parm.show_gift_panel then
                    Event.Brocast("show_gift_panel", parm.show_gift_panel)
                else
                    Event.Brocast("show_gift_panel")
                end
            end
        end
    end
end

-- 获取当前剩余领取次数
function M.GetCurCount()
    local m_share = MainModel.UserInfo.shareCount or 0
    local m_free = MainModel.UserInfo.freeSubsidyNum or 0
    return (m_share + m_free)
end
-- 获取总领取次数
function M.GetAllCount()
    local m_share = MainModel.UserInfo.shareAllNum or 0
    local m_free = MainModel.UserInfo.freeSubsidyAllNum or 0
    return (m_share + m_free)
end


function M.CheckShowExitAsk()
    local data1 = (SysJJJManager.GetCurCount() > 0)
    local data2 = GAME_Di_Bao_JB .. "x" .. SysJJJManager.GetCurCount()
    local data3 = function ()
        JYFLPanel.Create(GameObject.Find("Canvas/LayerLv4").transform)
    end
    return data1,data2,data3
end