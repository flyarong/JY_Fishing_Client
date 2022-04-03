-- 创建时间:2020-07-17
-- Act_022_QFLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_022_QFLBManager = {}
local M = Act_022_QFLBManager
M.key = "act_022_qflb"
M.config = GameButtonManager.ExtLoadLua(M.key,"act_022_qflb_config")
GameButtonManager.ExtLoadLua(M.key,"Act_022_QFLBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_022_QFLBPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_022_QFLBHelpPanel")
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

    if MainModel.myLocation == "game_Fishing3D" and FishingModel.game_id ~= 2 then
        return false
    end

    for i=1,#M.config.config_key do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= M.config.config_key[i].permission, is_on_hint = true}, "CheckCondition")
        if a and b then
            return true
        end
    end
    return false
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
        dump(parm,"qufanlibao  parm--->")
        return Act_022_QFLBPanel.Create(parm)
    elseif parm.goto_scene_parm == "enter" then
        return Act_022_QFLBEnterPrefab.Create(parm.parent, parm.cfg)
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

    lister["main_change_gift_bag_data_msg"] = this.on_gift_bag_status_change_msg
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response

    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg
    lister["query_one_task_data_response"] = this.on_query_one_task_data_response
    lister["query_all_return_lb_info_response"] = this.query_all_return_lb_info_response
    lister["finish_gift_shop"] = this.on_finish_gift_shop
    lister["all_return_lb_change_msg"] = this.on_all_return_lb_change_msg
    lister["AssetChange"] = this.AssetChange
end

function M.Init()
	M.Exit()

	this = Act_022_QFLBManager
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
    local config = {}
    local index = 1--如果渠道或平台需要区分,就走权限来判断index该是多少
    for i=1,#M.config.config_key do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= M.config.config_key[i].permission, is_on_hint = true}, "CheckCondition")
        if a and b then
            index = i
            break
        end
    end
    
    config.week_return = M.config.config_value[M.config.config_key[index].week_return]
    config.month_return = M.config.config_value[M.config.config_key[index].month_return]
    config.quarter_return = M.config.config_value[M.config.config_key[index].quarter_return]
    this.UIConfig.config = config
    config.help_info = M.config.help_info[M.config.config_key[index].help_info]
    this.UIConfig.task_id_map = {}
    this.UIConfig.gift_id_map = {}
    for k,v in pairs(this.UIConfig.config) do
        if v.task_id then
            this.UIConfig.task_id_map[v.task_id] = v
        end
        if v.gift_id then
            this.UIConfig.gift_id_map[v.gift_id] = v
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.QueryTaskData()
        M.QueryAllGiftInfo()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetConfig()
   return this.UIConfig.config
end

function M.GetTaskAward(id)
    --[[if not MainModel.IsWeChatChannel() then
        --检查支付宝
        MainModel.GetBindZFB(function(  )
            if table_is_null(MainModel.UserInfo.zfbData) or MainModel.UserInfo.zfbData.name == "" then
                LittleTips.Create("请先绑定支付宝")
                GameManager.GotoUI({gotoui = "sys_binding_zfb",goto_scene_parm = "panel"})
            else
                Network.SendRequest("get_task_award", {id = id}, "领取")
            end
        end)
        return
    end--]]
    Network.SendRequest("get_task_award", {id = id}, "领取")
end

function M.QueryAllGiftInfo()
    NetMsgSendManager.SendMsgQueue("query_all_return_lb_info", nil)
end

function M.QueryTaskData()
    for k,v in pairs(this.UIConfig.task_id_map) do
        if not GameTaskModel.GetTaskDataByID(k) then
            NetMsgSendManager.SendMsgQueue("query_one_task_data", {task_id = k})
        end
    end
end

function M.on_gift_bag_status_change_msg(gift_id)
    if this.UIConfig.gift_id_map[gift_id] then
        Event.Brocast("QFLBManager_on_gift_bag_status_change_msg")
    end
end

function M.on_model_task_change_msg(data)
    if data and this.UIConfig.task_id_map[data.id] then
        Event.Brocast("QFLBManager_on_model_task_change_msg")
    end
end
function M.on_model_query_one_task_data_response(data)
    if data and this.UIConfig.task_id_map[data.id] then
        Event.Brocast("QFLBManager_on_model_task_change_msg")
    end
end



function M.CheckAwardCanGet()
    for k,v in pairs(this.UIConfig.task_id_map) do
        if GameTaskModel.GetTaskDataByID(k) and GameTaskModel.GetTaskDataByID(k).award_status == 1 then
            return true
        end
    end
    return false
end

function M.on_query_send_list_fishing_msg(tag)
    if tag == "qflb" then
        Event.Brocast("QFLB_Task_Data_is_Query_msg")
    end
end

function M.query_all_return_lb_info_response(_,data)
    if data and data.result == 0 then
        this.m_data.all_return_lb_info = {}
        this.m_data.all_return_lb_info = data
        Event.Brocast("QFLBManager_on_query_all_return_lb_info_msg")
    end
end

function M.GetGiftAllInfo()
    return this.m_data.all_return_lb_info
end

function M.GetQuaterGiftBuyState()
    local datainfo = M.GetGiftAllInfo()
	local data = datainfo["all_return_lb_3"]
	dump(data,"<color=yellow>++++++++/////++++quarter++++++++++++</color>")
	if data then
        return data.is_buy==1
    end
end

function M.on_query_one_task_data_response(_,data)
end

function M.on_finish_gift_shop(id)
    if id and this.UIConfig.gift_id_map[id] then 
    end
end

function M.on_all_return_lb_change_msg(_,data)
    this.m_data.all_return_lb_info = this.m_data.all_return_lb_info or {}
    this.m_data.all_return_lb_info[data.lb_type] = data.all_return_lb
    Event.Brocast("QFLBManager_on_query_all_return_lb_info_msg")
end

function M.AssetChange(data)
    local model = {
        shop_gold_sum=5,
        jing_bi=4,
        prop_3d_fish_lock=3,
    }


    --dump(data,"<color=yellow>++++++++++++++555++++++++++</color>")
    if data.change_type == "all_return_lb_overtime_award" then
        for i = 1,#data.data do
            data.data[i].sort = model[data.data[i].asset_type] or 1
        end
        table.sort( data.data, function (v1, v2)
            if v1.sort > v2.sort then
                return true
            end
        end )

        Event.Brocast("AssetGet",data)
    end
end

function M.QueryData(b)
    local msg_list = {}
    for k,v in pairs(M.config) do
        if v.task_id then
            if not GameTaskModel.GetTaskDataByID(v.task_id) then
                msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = v.task_id}, is_close_jh = b}
            end
        end
    end
    if #msg_list > 0 then
        --dump(msg_list, "<color=red><size=15>EEE QueryData</size></color>")
        GameManager.SendMsgList(M.key, msg_list)
    else
        Event.Brocast("qflb_task_msg_finish_msg")
    end
end
function M.on_query_send_list_fishing_msg(tag)
    if tag == M.key then
        Event.Brocast("qflb_task_msg_finish_msg")
    end
end
