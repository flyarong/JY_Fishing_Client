-- 创建时间:2021-02-08
-- Act_XRXSFLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_XRXSFLManager = {}
local M = Act_XRXSFLManager
M.key = "act_xrxsfl"
local config = GameButtonManager.ExtLoadLua(M.key, "act_xrxsfl_config")
GameButtonManager.ExtLoadLua(M.key, "Act_XRXSFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_XRXSFLPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_XRXSFLTaskItemBase")
local this
local lister

-- 是否有活动
function M.IsActive(condi_key)
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_notcjj", is_on_hint = true}, "CheckCondition")
    if a and b then
        if tonumber(MainModel.UserInfo.first_login_time) >= 1635811200 then--2021.11.2.8:00之后的玩家不参与这个活动
            return false
        end
    end

    -- 活动的开始与结束时间
    local e_time = M.GetEndTime()
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if not M.CheckIsNew() then
        return false
    end

    -- 对应权限的key
    local _permission_key = condi_key
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
    if parm.goto_scene_parm == "panel" or parm.goto_scene_parm == "enter" then      
        return M.IsActive(parm.condi_key)
    else
        return true
    end
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
        return Act_XRXSFLPanel.Create()
    elseif parm.goto_scene_parm == "enter" then
        return Act_XRXSFLEnterPrefab.Create(parm.parent)
    else
        local tab = M.GetObjKeyTab()
        for i=1,#tab do
            if parm.goto_scene_parm == tab[i] then
                local data = MainModel.GetObjInfoByKey(tab[i])[1]
                if not data then
                    return
                end
                -- dump(data,"data-------->")
                -- dump(tab[i],"<color=yellow><size=15>++++++++++tab[i]++++++++++</size></color>")
                -- dump(M.GetObjIdByKey(tab[i]),"<color=yellow><size=15>++++++++++M.GetObjIdByKey(tab[i])++++++++++</size></color>")
                if os.time() >= data.enable_time then
                    Network.SendRequest("box_exchange_new",{id = M.GetObjIdByKey(tab[i]),num = 1,is_merge_asset = 1 })
                    return
                else
                    LittleTips.Create(StringHelper.formatTimeDHMS5(data.enable_time - os.time()).."后可开启礼包")
                end
            end
        end
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

    lister["model_get_task_award_response"] = this.on_model_get_task_award_response
    lister["activity_exchange_response"] = this.on_activity_exchange_response
    lister["query_activity_exchange_response"] = this.on_query_activity_exchange_response
    lister["query_jbzk_info_response"] = this.on_query_jbzk_info_response
    lister["activate_jbzk_response"] = this.on_activate_jbzk_response
    lister["AssetChange"] = this.on_AssetChange
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["box_exchange_new_response"] = this.on_box_exchange_new_response
end

function M.Init()
	M.Exit()

	this = Act_XRXSFLManager
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
    this.UIConfig.task_IDconfig = {}
    this.UIConfig.cj_IDconfig = {}
    for k,v in pairs(config.permission) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.permission, is_on_hint = true}, "CheckCondition")
        if a and b then
            this.UIConfig.task_IDconfig = v.task
            this.UIConfig.cj_IDconfig = v.cj
            this.UIConfig.item_key = v.item_key
            this.UIConfig.activity_exchange_type = v.activity_exchange_type
        end
    end
    this.UIConfig.task_config = {}
    this.UIConfig.care_task_map = {}
    for i=1,#this.UIConfig.task_IDconfig do
        this.UIConfig.task_config[#this.UIConfig.task_config + 1] = config.task[this.UIConfig.task_IDconfig[i]]
        this.UIConfig.care_task_map[config.task[this.UIConfig.task_IDconfig[i]].task_id] = config.task[this.UIConfig.task_IDconfig[i]].task_id
    end
    this.UIConfig.cj_config = {}
    for i=1,#this.UIConfig.cj_IDconfig do
        this.UIConfig.cj_config[#this.UIConfig.cj_config + 1] = config.cj[this.UIConfig.cj_IDconfig[i]]
    end

    this.UIConfig.obj_item_key = {}
    this.UIConfig.obj_exchange_id_map = {}
    for i=1,#this.UIConfig.cj_config do
        if this.UIConfig.cj_config[i].obj_key then
            this.UIConfig.obj_item_key[#this.UIConfig.obj_item_key + 1] = this.UIConfig.cj_config[i].obj_key
            this.UIConfig.obj_exchange_id_map[this.UIConfig.cj_config[i].obj_key] = this.UIConfig.cj_config[i].obj_box_exchange_id
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.query_data()
        M.QueryJBZKData()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetTaskConfig()
    return this.UIConfig.task_config
end

function M.GetCjConfig()
    return this.UIConfig.cj_config
end

function M.GetTaskAward(task_id)
    Network.SendRequest("get_task_award",{id = task_id})
end

function M.on_model_get_task_award_response(data)
    --dump(data,"<color=yellow><size=15>++++++++++on_model_get_task_award_response++++++++++</size></color>")
    if data and data.result == 0 then
        if this.UIConfig.care_task_map[data.id] then
            Event.Brocast("xrxsfl_task_had_got_msg")
        end
    end
end

function M.IsCanGet()
    if M.GetCjTimes() > 0 then
        return true
    end
    for k,v in pairs(this.UIConfig.care_task_map) do
        local data = GameTaskModel.GetTaskDataByID(v)
        if data and data.award_status == 1 then
            return true
        end
    end
    local obj_table = M.GetObjKeyTab()
    for i=1,#obj_table do
        local data = MainModel.GetObjInfoByKey(obj_table[i])[1]
        if not table_is_null(data) then
            if data.enable_time and os.time() > data.enable_time then
                return true
            end
        end
    end

    return false
end

function M.GetCjTimes()
    return GameItemModel.GetItemCount(this.UIConfig.item_key)
end


function M.query_data()
    NetMsgSendManager.SendMsgQueue("query_activity_exchange",{type = this.UIConfig.activity_exchange_type})
end

function M.on_query_activity_exchange_response(_,data)
    --dump(data,"<color=yellow><size=15>++++++++++on_query_activity_exchange_response++++++++++</size></color>")
    if data and data.result == 0 then
        if data.type == this.UIConfig.activity_exchange_type then
            this.m_data.gift_data = data.exchange_day_data
            Event.Brocast("xrxsfl_query_activity_exchange_msg")
        end
    end
end

function M.GetAwardConfig()
    return this.UIConfig.cj_config
end

function M.GetObjKeyTab()
    return this.UIConfig.obj_item_key
end

function M.GetObjIdByKey(key)
    return this.UIConfig.obj_exchange_id_map[key]
end

function M.QueryJBZKData()
    --NetMsgSendManager.SendMsgQueue("query_jbzk_info")
end

function M.ActivieJBZK()
    --NetMsgSendManager.SendMsgQueue("activate_jbzk")
end

function M.on_query_jbzk_info_response(_,data)
    --dump(data,"<color=yellow><size=15>++++++++++on_query_jbzk_info_response++++++++++</size></color>")
    if data and data.result == 0 then
        if data.active_time ~= 0 then
            this.m_data.JBZK_is_active = true
        end
    end
end

function M.on_activate_jbzk_response(_,data)
    if data and data.result == 0 then
        this.m_data.JBZK_is_active = true
        Event.Brocast("xrxsfl_jbzk_is_active_msg")
    end
end

function M.CheckJBZKIsActive()
    return this.m_data.JBZK_is_active
end

--关心抽到奖励和使用礼包
function M.on_AssetChange(data)
    if data and data.change_type then
        if data.change_type == "activity_exchange_43" or data.change_type == "activity_exchange_44" then
            Event.Brocast("xrxsfl_cj_award_had_got_msg")
        end
    end
end

function M.on_model_task_change_msg(data)
    if not data then return end
    for i=1,#this.UIConfig.task_config do
        if this.UIConfig.task_config[i].task_id == data.id then
            Event.Brocast("xrxsfl_task_change_smg")
        end
    end
end

function M.GetExchangeType()
    return this.UIConfig.activity_exchange_type
end

function M.on_box_exchange_new_response(_,data)
    if data and data.result == 0 then
        local tab = M.GetObjKeyTab()
        for k,v in pairs(tab) do
            if M.GetObjIdByKey(v) == data.id then
                --dump(data,"<color=yellow><size=15>++++++++++on_box_exchange_new_response++++++++++</size></color>")
                Event.Brocast("xrxsfl_box_exchange_new_msg")
            end
        end
    end
end

function M.GetEndTime()
    local end_t = MainModel.UserInfo.first_login_time + 259200
    local obj_table = M.GetObjKeyTab()
    for i=1,#obj_table do
        if obj_table[i] ~= "obj_jbzk" then
            local data = MainModel.GetObjInfoByKey(obj_table[i])[1]
            if not table_is_null(data) then
                end_t = MainModel.UserInfo.first_login_time + 259200 + 172800
                break
            end
        end
    end
    return end_t
end

function M.CheckIsOverdue()
    if os.time() > (MainModel.UserInfo.first_login_time + 259200) then
        return true
    end
    return false
end

function M.CheckIsNew()
    return tonumber(MainModel.UserInfo.first_login_time) >= 1615248000
end