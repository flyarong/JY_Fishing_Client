-- 创建时间:2
--05-06
-- Act_038_S12DHHLManager 管理器

local basefunc = require "Game/Common/basefunc"

Act_038_S12DHHLManager = {}
local M = Act_038_S12DHHLManager
M.key = "act_038_s12dhhl"
Act_038_S12DHHLManager.config = GameButtonManager.ExtLoadLua(M.key,"act_038_s12dhhl_config")
Act_038_S12DHHLManager.shop_icon_config = GameButtonManager.ExtLoadLua(M.key,"act_038_s12dhhl_shopicon_config")
Act_038_S12DHHLManager.goodsid_config = GameButtonManager.ExtLoadLua(M.key,"act_038_s12dhhl_shopid_config")
GameButtonManager.ExtLoadLua(M.key,"Act_038_S12DHHLItemBase")
GameButtonManager.ExtLoadLua(M.key,"Act_038_S12DHHLPanel")
local this
local lister
local gift_ids
local task_map_ids
local gift_data

M.now_level = 0
M.item_key = "prop_12_12_lh"
local start_time = 1607385600
local end_time = 1607961599
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = end_time
    local s_time = start_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

--[[    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_buy_gift_bag_class_031_gqfd_gift", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end--]]

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return M.now_level
        end
        return M.now_level
    else
        M.now_level = 1
        return M.now_level
    end
end

-- 创建入口按钮时调用
function M.CheckIsShow(cfg)
    if M.IsActive() then
        return true
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    dump(M.CheckIsShow(),"<color=yellow><size=15>++++++++++M.CheckIsShow()++++++++++</size></color>")
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            return Act_038_S12DHHLPanel.Create(parm.parent,parm.backcall)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) or not M.CheakIsShow(parm.condi_key) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if M.IsItemCanGet() then
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
        Event.Brocast("global_hint_state_change_msg", parm)
    end
end

function M.Refresh_Status()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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

    lister["client_system_variant_data_change_msg"] = this.on_client_system_variant_data_change_msg

    lister["query_activity_exchange_response"] = this.on_query_activity_exchange_response
    lister["activity_exchange_response"] = this.on_activity_exchange_response
    lister["AssetChange"] = this.on_AssetChange
    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
    lister["PayPanelClosed"] = this.on_PayPanelClosed
    lister["PayPanel_GoodsChangeToGift"] = this.on_PayPanel_GoodsChangeToGift
end

function M.Init()
    M.Exit()

    this = Act_038_S12DHHLManager
    this.m_data = {}
    MakeLister()
    AddLister()
    M.InitUIConfig()
end
function M.Exit()
    M.Stop_Query_data()
    if this then
        RemoveLister()
        this = nil
    end
end

function M.InitUIConfig()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cpl_notcjj", is_on_hint = true}, "CheckCondition")
    if a and b then
        M.type = 7
    else
        M.type = 8
    end

    gift_ids = {}
    task_map_ids = {}
    for i=1,#M.config.Info do
        gift_ids[i] = gift_ids[i] or {}
        for k1, v1 in ipairs(M.config.Info[i]) do
            gift_ids[i][#gift_ids[i] + 1] = v1.ID
            task_map_ids[v1.ID] = 1
        end
    end
end


function M.OnLoginResponse(result)
    if result == 0 then
        -- 数据初始化
        if M.IsActive() then
            Timer.New(function ()
                M.query_data()
            end, 1, 1):Start()
        end
    end
end
function M.OnReConnecteServerSucceed()
end

function M.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})--刷新enter
    Event.Brocast("model_wxhhl_data_change_msg")--刷新panel
end

function M.IsItemCanGet()
    local item = M.GetItemCount()
    for k,v in ipairs(gift_ids[M.now_level]) do
        if gift_data and gift_data[v] and gift_data[v] and gift_data[v] ~= 0 and item >= tonumber(M.config.Info[M.now_level][k].item_cost_text)  then
            return k
        end
    end
end

function M.GetItemCount()
    return GameItemModel.GetItemCount(M.item_key)
end

local CheckGiftDataFinish = function ()
    for k,v in ipairs(gift_ids) do
        if not gift_data[v] then
            return false
        end
    end
    return true
end


function M.QueryGiftData()
    if not this.m_data.time then
        this.m_data.time = 0
    end
    if gift_data and CheckGiftDataFinish() and (os.time() - this.m_data.time < 5) then
        Event.Brocast("model_wxhhl_data_change_msg")
    else
        M.query_data()
    end
end

function M.GetCurData()
    local _cur_data = {}
    for i=1,#M.config.Info[M.now_level] do
        _cur_data[i] = {}
        _cur_data[i].cfg = M.config.Info[M.now_level][i]

        _cur_data[i].ID = M.config.Info[M.now_level][i].ID--ID
        _cur_data[i].award_name = M.config.Info[M.now_level][i].award_name--奖励的名字
        _cur_data[i].award_image = M.config.Info[M.now_level][i].award_image--奖励的图片
        _cur_data[i].item_cost_text = M.config.Info[M.now_level][i].item_cost_text--道具消耗text
        _cur_data[i].type = M.config.Info[M.now_level][i].type--实物奖励为1,普通奖励为0       
        if M.config.Info[M.now_level][i].tips then
            _cur_data[i].tips = M.config.Info[M.now_level][i].tips--奖励特殊描述
        end

        if gift_data[_cur_data[i].ID] then
            --_cur_data[i].status = gift_data[_cur_data[i].gift_id].status
            _cur_data[i].remain_time = gift_data[_cur_data[i].ID]
        else
            --_cur_data[i].status = 0
            _cur_data[i].remain_time = 0
        end
    end
    return _cur_data
end


function M.on_client_system_variant_data_change_msg()
    M.IsActive()
    if M.now_level then
        M.query_data()
    end
end


function M.on_query_activity_exchange_response(_,data)
    dump(data,"<color=yellow><size=15>+++++++++//////////////+data++++++++++</size></color>")
    if data then
        if data.result == 0 then
            if data.type == M.type then
                this.m_data.time = os.time()
                gift_data = data.exchange_day_data
                --this.m_data.exchange_day_data = data.exchange_day_data
                M.Refresh_Status()
                Event.Brocast("model_wxhhl_data_change_msg")
            end
        else
            M.Query_data_timer(false)
            --HintPanel.ErrorMsg(data.result)
        end
    end
end

function M.query_data()
    if M.IsActive() then
        Network.SendRequest("query_activity_exchange",{type = M.type})
    end
end

function M.Query_data_timer(b)
    M.Stop_Query_data()
    if b then
        M.timer1 = Timer.New(function ()
                    M.query_data()
            end, 15, -1, false)
        M.timer1:Start()
    end
end

function M.Stop_Query_data()
    if M.timer1 then
        M.timer1:Stop()
        M.timer1 = nil
    end
end


function M.on_activity_exchange_response(_,data)
    if data then
        if data.result == 0 then
            M.query_data()
            Event.Brocast("WXHHL_sw_kfPanel_msg",data.id)
        else
            HintPanel.ErrorMsg(data.result)
        end
    end
end

function M.CheakIsShow(_permission_key)
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

function M.on_AssetChange(data)
    if data and data.change_type and data.change_type  == "fish_game_3" then
        for k,v in pairs(data.data) do
            if v.asset_type and v.asset_type == M.item_key then
                M.Refresh()
            end
        end
    end
end

function M.on_fishing_ready_finish()
    if  M.IsActive() then
        if MainModel.myLocation == "game_Fishing3D" or MainModel.myLocation == "game_Fishing" then
            GameButtonManager.GotoUI({gotoui = "sys_act_base",goto_scene_parm = "panel"})
        end
    end
end

local items = {}
items.jing_bi = {}
items.goods = {}

function M.on_PayPanel_GoodsChangeToGift(data)
    --dump(data,"<color=green>++++++++data+++++++++++</color>")
    if not data or table_is_null(data) then
        return
    end 
    if start_time < os.time() and os.time() < end_time and M.IsActive() then
        if not data or table_is_null(data) then
            return
        end
        --dump(data,"<color=yellow><size=15>++++++++++11111111111111111++++++++++</size></color>")
        for k,v in pairs(data.pay_data) do
            if v.data.gift_id and MainModel.GetGiftShopStatusByID(v.data.gift_id) == 1 then
                --dump({status = MainModel.GetGiftShopStatusByID(v.data.gift_id),id= v.data.gift_id},"<color=yellow><size=15>++++++++++000000000000++++++++++</size></color>")
            else
                --dump(data,"<color=yellow><size=15>++++++++++22222222222222222222222++++++++++</size></color>")
                local temp_ui = {}
                LuaHelper.GeneratingVar(v.obj.transform, temp_ui)
                if M.CheckIsShow() then
                    temp_ui.give_img.gameObject:SetActive(false)
                    local GoodsData = v.data
                    if GoodsData.id == 7 and  GoodsData.type == "jing_bi" then-- 剔除钻石换金币
                        return
                    end
                    --dump(data,"<color=yellow><size=15>++++++++++333333333333333333333++++++++++</size></color>")
                    local obj = newObject("Act_038_S12DHHLIconInShop", temp_ui.act_node)
                    obj.transform.localPosition = Vector3.New(0,144,0)
                    local obj_childs = {}
                    LuaHelper.GeneratingVar(obj.transform, obj_childs)           
                    local gift_id = M.GetTaskIDByGoodsID(GoodsData.goods_id)
                    --dump(gift_id,"<color=red>gift_id</color>")
                    if gift_id and M.shop_icon_config.Info[gift_id] then
                        obj_childs.Icon_number_txt.text = "×"..M.shop_icon_config.Info[gift_id].icon_txt
                        if GoodsData.type == "jing_bi" then 
                            items.jing_bi[gift_id] = obj
                        elseif GoodsData.type == "goods" then
                            items.goods[gift_id] = obj
                        end
                    else
                        obj.gameObject:SetActive(false)  
                    end
                    M.RefreshItems()
                end
            end
        end        
    end
end


function M.RefreshItems()
    --dump(items.jing_bi,"<color=yellow>+++++++999999999+++++++++</color>")
    for k ,v in pairs(items.jing_bi) do
        local data = GameTaskModel.GetTaskDataByID(k)
        --dump(data,"<color=yellow>++++++++++++++++</color>")
        v.gameObject:SetActive((data and data.now_process < 1))
    end
    for k ,v in pairs(items.goods) do
        v.gameObject:SetActive(false)
    end
end

function M.on_PayPanelClosed()
    items = {}
    items.jing_bi = {}
    items.goods = {}
end

function M.GetTaskIDByGoodsID(goods_id)
    for i = 1,#M.goodsid_config do
        if M.goodsid_config[i].shop_id == goods_id then 
            return M.goodsid_config[i].gift_id
        end
    end
end