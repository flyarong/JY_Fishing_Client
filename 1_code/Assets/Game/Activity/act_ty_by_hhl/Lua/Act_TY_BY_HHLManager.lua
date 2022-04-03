-- 创建时间:2
--05-06
-- Act_TY_BY_HHLManager 管理器

local basefunc = require "Game/Common/basefunc"

Act_TY_BY_HHLManager = {}
local M = Act_TY_BY_HHLManager
M.key = "act_ty_by_hhl"

local config = GameButtonManager.ExtLoadLua(M.key,"act_hhl_ty_config")
GameButtonManager.ExtLoadLua(M.key,"Act_TY_BY_HHLItemBase")
GameButtonManager.ExtLoadLua(M.key,"Act_TY_BY_HHLPanel")

local this
local lister

-- 是否有活动
function M.IsActive()
    local cfg = M.GetCurConfig()
    if cfg then
        return true
    else
        return false
    end
end


-- 创建入口按钮时调用
function M.CheckIsShow(cfg)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    dump(parm,"<color=red>创建入口按钮时调用！！！！！</color>")
    if not M.CheckIsShow() then return end
    if parm.goto_scene_parm == "panel" then
        return Act_TY_BY_HHLPanel.Create(parm.parent, parm.backcall, M.GetCurConfig())
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    local cfg = M.GetCurConfig()
	if cfg and parm and parm.gotoui == M.key then 
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
    lister["PayPanelClosed"] = this.on_PayPanelClosed
    lister["PayPanel_GoodsChangeToGift"] = this.on_PayPanel_GoodsChangeToGift
end

function M.Init()
	M.Exit()

	this = Act_TY_BY_HHLManager
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
    this.UIConfig.item_map = {}

    this.UIConfig.config_info = config.config_infor
    for k,v in ipairs(config.config_infor) do
        this.UIConfig.item_map[v.item_key] = v
    end

    this.UIConfig.award_map = {}
    for k,v in ipairs(config.config) do
        this.UIConfig.award_map[v.line] = v
    end

    this.UIConfig.task_map = {}
    this.UIConfig.shop_map = {}
    this.goodsid_config_map = {}
    for k,v in ipairs(config.shop_config) do
        this.UIConfig.shop_map[v.ID] = v
        this.UIConfig.task_map[v.task_id] = v
        for i=1, #v.shop_id do
            this.goodsid_config_map[v.shop_id[i]] = v.task_id
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.query_data()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})--刷新enter
    Event.Brocast("model_hhl_data_change_msg")--刷新panel
end

function M.IsItemCanGet()
    local item = M.GetItemCount()
    local cfg = M.GetCurConfig()
    for i=1, #cfg.config do
        local award = M.GetAwardByID(cfg.config[i])
        if this.m_data.gift_data
            and this.m_data.gift_data[i]
            and this.m_data.gift_data[i]
            and this.m_data.gift_data[i] ~= 0
            and item >= tonumber(award.item_cost_text) then
            return i
        end
    end
end

function M.GetCurConfig()
    local cur_t = os.time()
    for i,v in ipairs(M.UIConfig.config_info) do
        if cur_t >= v.beginTime and cur_t <= v.endTime then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condiy_key, is_on_hint = true}, "CheckCondition")
            if a and b then
                return v
            end
        end
    end
    return
end

function M.GetItemCount()
    local cfg = M.GetCurConfig()
    if cfg then
        return GameItemModel.GetItemCount(cfg.item_key)
    end
    return 0
end

function M.GetActivityConfig()
    local cfg = M.GetCurConfig()
    if cfg then
        return cfg
    end
end
function M.QueryGiftData()
    if not this.m_data.time then
        this.m_data.time = 0
    end
    if this.m_data.gift_data and (os.time() - this.m_data.time < 5) then
        Event.Brocast("model_hhl_data_change_msg")
    else
        M.query_data()
    end
end

function M.GetAwardByID(ID)
    return this.UIConfig.award_map[ID]
end
function M.GetCurData()
    if not this.m_data.gift_data then
        return
    end
    local min_cost_id
    local min_cost_value
    local _cur_data = {}
    for k,v in ipairs(this.m_data.gift_data) do
        _cur_data[#_cur_data + 1] = {}
        _cur_data[#_cur_data].ID = k
        _cur_data[#_cur_data].remain_time = v
        local cfg = M.GetAwardByID(k)

        if M.GetItemCount() >= cfg.item_cost_text and v ~= 0 then
            if not min_cost_id or min_cost_value > cfg.item_cost_text then
                min_cost_id = k
                min_cost_value = cfg.item_cost_text
            end
        end
    end
    if min_cost_id then
        _cur_data[min_cost_id].is_min_cost = true
    end
    return _cur_data
end


function M.on_client_system_variant_data_change_msg()
    M.query_data()
end

function M.on_query_activity_exchange_response(_,data)
    local cfg = M.GetCurConfig()
    if cfg and data.result == 0 then
        if data.type == cfg.change_type then
            M.old_time = os.date("%d",os.time())
            this.m_data.time = os.time()
            this.m_data.gift_data = data.exchange_day_data
            for i=1,#data.exchange_data do
                if data.exchange_data[i] == 0 or this.m_data.gift_data[i] == 0 then
                    this.m_data.gift_data[i] = 0
                else
                    this.m_data.gift_data[i] = math.max(this.m_data.gift_data[i],data.exchange_data[i])
                end
            end
            M.Refresh_Status()
            Event.Brocast("model_hhl_data_change_msg")
        end
    end
end

function M.query_data()
    if M.IsActive() then
        local cfg = M.GetCurConfig()
        NetMsgSendManager.SendMsgQueue("query_activity_exchange",{type = cfg.change_type})
    end
end

function M.on_activity_exchange_response(_,data)
    --dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
    local cfg = M.GetCurConfig()
    if data and cfg then
        if data.result == 0 and data.type == cfg.change_type then
            M.query_data()
            Event.Brocast("hhl_sw_kfpanel_msg",data.id)
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
            if v.asset_type and this.UIConfig.item_map[v.asset_type] then
                M.Refresh()
                break
            end
        end
    end
end

local items = {}
items.jing_bi = {}
items.goods = {}

function M.on_PayPanel_GoodsChangeToGift(data)
    if not data or table_is_null(data) then
        return
    end 
    if M.IsActive() then
        if not data or table_is_null(data) then
            return
        end
        for k,v in pairs(data.pay_data) do
            local temp_ui = {}
            LuaHelper.GeneratingVar(v.obj.transform, temp_ui)
            if M.CheckIsShow() then
                local GoodsData = v.data
                if GoodsData.id == 7 and  GoodsData.type == "jing_bi" then-- 剔除钻石换金币
                    return
                end
                local obj = newObject("Act_TY_BY_HHLIconInShop", temp_ui.act_node)
                obj.transform.localPosition = Vector3.New(80,70,0)
                local obj_childs = {}
                LuaHelper.GeneratingVar(obj.transform, obj_childs)           
                local task_id = M.GetTaskIDByGoodsID(GoodsData.goods_id)
                local item_cfg = M.GetInforByItemConfig()
                if item_cfg then
                    obj_childs.item_img.sprite = GetTexture(item_cfg.image)
                end
                if task_id and GameTaskModel.GetTaskDataByID(task_id) and GameTaskModel.GetTaskDataByID(task_id).award_status ~= 1 then
                    obj_childs.Icon_number_txt.text = "×"..this.UIConfig.task_map[task_id].icon_txt
                    if GoodsData.type == "jing_bi" then 
                        items.jing_bi[task_id] = obj
                    elseif GoodsData.type == "goods" then
                        items.goods[task_id] = obj
                    end
                else
                    obj.gameObject:SetActive(false)  
                end
                M.RefreshItems()
            end
        end        
    end
end


function M.RefreshItems()
    for k ,v in pairs(items.jing_bi) do
        local data = GameTaskModel.GetTaskDataByID(k)
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
    return this.goodsid_config_map[goods_id]
end

function M.GetInforByItemConfig()
    local cfg = M.GetCurConfig()
    if cfg then
        return GameItemModel.GetItemToKey(cfg.item_key)
    end
end

