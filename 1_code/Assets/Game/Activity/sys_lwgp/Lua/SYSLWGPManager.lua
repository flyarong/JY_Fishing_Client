-- 创建时间:2021-03-04
-- SYSLWGPManager 管理器

local basefunc = require "Game/Common/basefunc"
SYSLWGPManager = {}
local M = SYSLWGPManager
M.key = "sys_lwgp"
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPStorePanel")
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPStoreItemBase")
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPPanel")
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPIntroducePanel")
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPHistoryPanel")
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPHistoryItemBase")
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPBuyPanel")
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPAcquisitionPanel")
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPAcquisitionItemBase")
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPHelpPanel") 
GameButtonManager.ExtLoadLua(M.key,"SYSLWGPSettlementPanel")

local config = GameButtonManager.ExtLoadLua(M.key,"syslwgp_config")  
local headConfig=GameButtonManager.ExtLoadLua(M.key,"head_image_server_lwgp")
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间

   if FishingModel and FishingModel.game_id == 3 then
       return true
   end
   return false
    -- local e_time
    -- local s_time
    -- if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
    --     return false
    -- end

    -- -- 对应权限的key
    -- local _permission_key
    -- if _permission_key then
    --     local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
    --     if a and not b then
    --         return false
    --     end
    --     return true
    -- else
    --     return true
    -- end
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
    if parm.goto_scene_parm=="enter" then
        return SYSLWGPEnterPrefab.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
    lister["lwgp_query_bet_data_response"]=this.on_lwgp_query_bet_data_response
    lister["lwgp_query_history_data_response"]=this.on_lwgp_query_history_data_response
    lister["lwgp_player_bet_change"]=this.on_lwgp_player_bet_change
    lister["lwgp_kaijiang_result"]=this.on_lwgp_kaijiang_result


    lister["game_fishing3dhall_init"]=this.on_game_fishing3dhall_init
    lister["game_fishing3dhall_gameid3_refresh"]=this.on_game_fishing3dhall_gameid3_refresh
    lister["EnterScene"] = this.OnEnterScene


end
function M.Init()
	M.Exit()

	this = SYSLWGPManager
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

function M.on_fishing_ready_finish()
    if  FishingModel.game_id ~= 3 then
        return
    end
    this.canOpenAward=true
    if (MainModel.myLocation == "game_Fishing3D") and this.JudgeTimeShowState() then
        PlayerPrefs.SetInt("SYSLWGP"..MainModel.UserInfo.user_id.."notip",0)
        SYSLWGPIntroducePanel.Create()
    end
end

--下注信息相关
function M.request_lwgp_query_bet_data()
    --dump("请求获取下注信息-------->")
    -- NetMsgSendManager.SendMsgQueue("lwgp_query_bet_data",{game_id=1})
	Network.SendRequest("lwgp_query_bet_data" ,{game_id=1})

end
function M.on_lwgp_query_bet_data_response(_,data)
    --dump(data,"---->请求后返回的下注信息:")
    if data and data.result==0 then 
        this.m_data.LwgpBetData=data
        Event.Brocast("refresh_Lwgp_store_item_num")
        Event.Brocast("refresh_Lwgp_buy_item_num")

    else
        dump(data,"<color=red>返回的下注信息出错！</color>")
    end

end
function M.GetLwgpBetItemData(_index)
    -- dump(this.m_data,"managerdata:  ")
    if this.m_data.LwgpBetData and this.m_data.LwgpBetData.bet_data then
        return this.m_data.LwgpBetData.bet_data[_index]
    end
    return {index=0,bet_data=100}
end

--历史开奖数据相关
function M.request_lwgp_query_history_data()
    if this.m_data.HistoryData==nil then
        --dump("------->请求获取历史开奖数据： ")
        NetMsgSendManager.SendMsgQueue("lwgp_query_history_data",{game_id=1})
    else
        Event.Brocast("refresh_lwgp_history_data")
    end
end
function M.on_lwgp_query_history_data_response(_,data)
    dump(data,"---->请求后返回开奖数据：  ")
    if data and data.result==0 then 
        this.m_data.HistoryData=data
        Event.Brocast("refresh_lwgp_history_data")
    else
        --dump(data,"<color=red>返回的历史开奖数据信息出错！</color>")

    end

end
function M.ActiveChangeHistoryData(data)
    dump(data,"主动插入历史数据：  ")
    if this.m_data.HistoryData and this.m_data.HistoryData.history_data then
        if #this.m_data.HistoryData.history_data<10 then
             table.insert(this.m_data.HistoryData.history_data,1,data)
        else
            table.insert(this.m_data.HistoryData.history_data,1,data)
            table.remove(this.m_data.HistoryData.history_data)
        end
    end
    Event.Brocast("refresh_lwgp_history_data")
end
function M.GetLwgpHistoryData()
    if this.m_data.HistoryData then
        return this.m_data.HistoryData.history_data
    end
end
--龙王 玩家下注数据改变：
function M.on_lwgp_player_bet_change(_,_data)
    if FishingModel and FishingModel.game_id ~= 3 then
        return
    end
    -- dump(_data,"<color=red>服务器主动龙王贡品  玩家下注数据改变： </color>")
    this.m_data.LwgpBetData=_data
    Event.Brocast("refresh_Lwgp_store_item_num")
    -- Event.Brocast("refresh_Lwgp_buy_item_num")
    Event.Brocast("bet_lwgp_success")

end
--龙王贡品开奖结果
function M.on_lwgp_kaijiang_result(_,data)
    if FishingModel and FishingModel.game_id ~= 3 then
        return
    end
    if MainModel.myLocation == "game_Fishing3D" and this.canOpenAward  then
        dump(data,"龙王贡品开奖结果：  ")
        this.m_data.LwgpKaiJiangData=data
        SYSLWGPAcquisitionPanel.Create()
        if data.current_history_data then
            M.ActiveChangeHistoryData(data.current_history_data)
        else
            dump(data,"<color=red>本次开奖结果无开奖历史数据！！！1<color>")
        end
    else
        dump(data,"<color=red>3D捕鱼场景未初始化完成，不能打开开奖界面！！！</color>")
        this.canOpenAward=false
    end
end

function M.GetLwgpKaiJiangData()
    if this.m_data.LwgpKaiJiangData then
        return this.m_data.LwgpKaiJiangData
    end
   dump(this.m_data.LwgpKaiJiangData,"<color=red>获取开奖数据出错！！！！</color>")
end
function M.JudgeTimeShowState()
    local lastOpenTime= PlayerPrefs.GetInt("SYSLWGP"..MainModel.UserInfo.user_id.."notip",0)
    -- dump(lastOpenTime,"<color=yellow>上次页面打开时间：  </color>")
    if lastOpenTime>0  then
        local lastOpenMondayTime=getThisWeekMonday(lastOpenTime)
        -- dump(lastOpenMondayTime,"上次页面打开周一时间：  ")
        if os.time()>lastOpenMondayTime+60*60*24*7 then
            return true
        else
            return false
        end
    end
    return true
  
end

-- 进入捕鱼场景的时候
function M.OnEnterScene()
    if MainModel.myLocation ~= "game_Fishing3D" then
       this.m_data.HistoryData=nil
    end
end

function M.OnCloseAcquisitionPanel()
    if   this.m_data.LwgpKaiJiangData and   this.m_data.LwgpKaiJiangData.total_award then
       local award_num=tonumber(  this.m_data.LwgpKaiJiangData.total_award)
       if award_num>0 then
        SYSLWGPSettlementPanel.Create(award_num)
       end
   
    end
end
-- --自动更新数据
-- function M.AutoUpdateData()
--     M.StopTime()
--     updateTimer = Timer.New(function ()
--         -- Network.SendRequest("query_level_data")
--         dump("sssssssss","<color=red>请龙王！！！！！！</color>")
--         SYSLWGPAcquisitionPanel.Create()
--     end,10)
--     updateTimer:Start()
-- end
-- function M.StopTime()
--     if updateTimer then
--         updateTimer:Stop()
--         updateTimer = nil
--     end
-- end
function M.GetJlbNum()
    -- return 1000000
    return GameItemModel.GetItemCount("prop_jinglongbi")
end

function M.GetStoreCfg()
    return config.store_item
end
--获取历史贡品数据时，有时服务器的发来的head_image字段不是一个链接，
--而是一个数字字符串，这时需要对应到表的url
function M.GetDefaltHeadUrl(_id)
    if headConfig then
        return headConfig.head_images[_id].url
    end
    --默认头像
	return "http://jydown.jyhd919.cn/head_images3/jy/girl/new_girl_head001.jpg"
end

function M.GetGPFlyPrefab()
    
end
local game_id3_obj=nil
function M.on_game_fishing3dhall_init(_node)
    dump(_node,"---node")
    -- local parent=_node:Find("by3d_hall_prefab2")
    -- dump(parent,"获取节点：")
    game_id3_obj = newObject("gameHallShow_lwgp", _node)
    game_id3_obj.transform.localPosition=Vector3(270,212,0)
end

function M.on_game_fishing3dhall_gameid3_refresh(_state)
    dump("刷新状态：  ",_state)
    if game_id3_obj then
        local yes=game_id3_obj.transform:Find("yes")
        local no=game_id3_obj.transform:Find("no")

        yes.gameObject:SetActive(_state)
        no.gameObject:SetActive(not _state)
    else

    end
end