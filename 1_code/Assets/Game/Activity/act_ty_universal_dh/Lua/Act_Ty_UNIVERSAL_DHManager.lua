-- Act_Ty_UNIVERSAL_DHManager 管理器

local basefunc = require "Game/Common/basefunc"

Act_Ty_UNIVERSAL_DHManager = {}
local M = Act_Ty_UNIVERSAL_DHManager
M.key = "act_ty_universal_dh"

M.config = GameButtonManager.ExtLoadLua(M.key,"act_ty_universal_dh_config")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_UNIVERSAL_DHItemBase")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_UNIVERSAL_DHPanel")

local this
local lister

local gift_data

-- 是否有活动
function M.IsActive()
    return M.CheckPermission()
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
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            return Act_Ty_UNIVERSAL_DHPanel.Create(parm.parent,parm.backcall)
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
    lister["PayPanelClosed"] = this.on_PayPanelClosed
    lister["PayPanel_GoodsChangeToGift"] = this.on_PayPanel_GoodsChangeToGift
    lister["activity_all_exchange_response"] = this.on_activity_all_exchange_response
    lister["box_exchange_new_response"] = this.on_box_exchange_new_response
end

function M.Init()
    M.Exit()

    this = Act_Ty_UNIVERSAL_DHManager
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

function M.GetCurPath()
    return M.cur_path
end

function M.CheckPermission()
    local cur_t = os.time()
    M.config_infors = basefunc.deepcopy(M.config)
    for i,v in ipairs(M.config_infors.config_infor) do
        if cur_t >= v.beginTime and cur_t <= v.endTime then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condiy_key, is_on_hint = true}, "CheckCondition")
            if a and b then
                M.type = v.change_type
                M.item_keys = v.item_key
                this.UIConfig.sta_t = v.beginTime
                this.UIConfig.end_t = v.endTime
                this.UIConfig.Info = v.config
                this.UIConfig.shop = v.shop_config
                this.UIConfig.goto_ui = v.GotoUI[1]
                M.cur_path = v.cur_path
                M.universal_item_key = v.universal_item_key
                M.item_tips = v.item_tips
                M.btm_tip = v.btm_tip
                M.fudai_key = v.fudai_key
                M.fudai_ex_change_id = v.fudai_ex_change_id
                M.help_content = M.config_infors.help[v.help]
                M.InitData()
                return true
            end
        end
    end
    return false
end

function M.InitData()
    this.UIConfig.Info_config = {}
    for i=1,#this.UIConfig.Info do
        this.UIConfig.Info_config[#this.UIConfig.Info_config + 1] = M.config_infors.config[this.UIConfig.Info[i]]
    end
    this.UIConfig.shop_config = {}
    for i=1,#this.UIConfig.shop do
        this.UIConfig.shop_config[M.config_infors.shop_config[this.UIConfig.shop[i]].task_id] = M.config_infors.shop_config[this.UIConfig.shop[i]]
    end

    this.UIConfig.gift_ids = {}
    for i=1,#this.UIConfig.Info_config do
        this.UIConfig.gift_ids[i] = this.UIConfig.gift_ids[i] or {}
        for k1, v1 in ipairs(this.UIConfig.Info_config ) do
            this.UIConfig.gift_ids[i] = this.UIConfig.Info_config[i].ID
        end
    end

    this.goodsid_config_map = {}
    for k,v in pairs(this.UIConfig.shop_config) do
        for i=1,#v.shop_id do
            this.goodsid_config_map[v.shop_id[i]] = v.task_id
        end
    end
    
    this.care_activity_exchange_ids_map = {}--关心的activity_exchange_ids
    for k,v in pairs(this.UIConfig.Info_config) do
        this.care_activity_exchange_ids_map[v.ID] = v.ID
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
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
    Event.Brocast("model_universal_data_change_msg")--刷新panel
end

function M.IsItemCanGet()
    if not M.IsActive() then return end    
    for k,v in ipairs(this.UIConfig.gift_ids) do
        if gift_data and gift_data[v] and gift_data[v] and gift_data[v] ~= 0 and M.CheckItemIsEnough(this.UIConfig.Info_config[k].ID) then
            return k
        end
    end
end

function M.CheckItemIsEnough(ID)
    local tab_all = M.GetCurData()
    local tab = {}
    for i=1,#tab_all do
        if tab_all[i].ID == ID then
            tab = tab_all[i]
            break
        end
    end
    local need = 0
    for i=1,#tab.cost_item_num do
        if tab.cost_item_num[i] - GameItemModel.GetItemCount(tab.cost_item_key[i]) > 0 then
            need = need + tab.cost_item_num[i] - GameItemModel.GetItemCount(tab.cost_item_key[i])
        end
    end
    local universal_count = GameItemModel.GetItemCount(M.GetUniversalKey())
    return (universal_count >= need)
end

local CheckGiftDataFinish = function ()
    for k,v in ipairs(this.UIConfig.gift_ids) do
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
        Event.Brocast("model_universal_data_change_msg")
    else
        M.query_data()
    end
end

function M.GetCurData()
    local _cur_data = {}
    if table_is_null(this.UIConfig) or table_is_null(this.UIConfig.Info_config) then return end
    for i=1,#this.UIConfig.Info_config do
        _cur_data[i] = {}
        _cur_data[i].cfg = this.UIConfig.Info_config[i]

        _cur_data[i].ID = this.UIConfig.Info_config[i].ID
        _cur_data[i].line = this.UIConfig.Info_config[i].line
        _cur_data[i].award_name = this.UIConfig.Info_config[i].award_name--奖励的名字
        _cur_data[i].award_image = this.UIConfig.Info_config[i].award_image--奖励的图片
        _cur_data[i].cost_item_key = this.UIConfig.Info_config[i].cost_item_key
        _cur_data[i].cost_item_num = this.UIConfig.Info_config[i].cost_item_num--道具消耗text
        _cur_data[i].type = this.UIConfig.Info_config[i].type--实物奖励为1,普通奖励为0       
        if this.UIConfig.Info_config[i].tips then
            _cur_data[i].tips = this.UIConfig.Info_config[i].tips--奖励特殊描述
        end

        if gift_data[_cur_data[i].ID] then
            _cur_data[i].remain_time = gift_data[_cur_data[i].ID]
        else
            _cur_data[i].remain_time = 0
        end
    end
    return _cur_data
end

function M.on_client_system_variant_data_change_msg()
    M.IsActive()
    M.query_data()
end

function M.on_query_activity_exchange_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_query_activity_exchange_response++++++++++</size></color>")
    if data then
        if data.result == 0 then
            if data.type == M.type then
                M.old_time = os.date("%d",os.time())
                this.m_data.time = os.time()
                gift_data = data.exchange_day_data
                M.Refresh_Status()
                Event.Brocast("model_universal_data_change_msg")
            end
        end
    end
end

function M.query_data()
    if M.IsActive() then
        dump(M.type,"<color=yellow><size=15>++++++++++M.type++++++++++</size></color>")
        Network.SendRequest("query_activity_exchange",{type = M.type})
    end
end

function M.on_activity_exchange_response(_,data)
    --dump(data,"<color=yellow><size=15>++++++++++on_activity_exchange_response++++++++++</size></color>")
    if data then
        if data.result == 0 and this.care_activity_exchange_ids_map and this.care_activity_exchange_ids_map[data.id] == data.id and data.type == M.type then
            M.query_data()
            Event.Brocast("universal_sw_kfpanel_msg",data.id)
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
    if not M.IsActive() then return end
    if data and data.change_type and data.change_type  == "fish_game_3" then
        for k,v in pairs(data.data) do
            for i,n in pairs(M.item_keys) do
                if v.asset_type and v.asset_type == n then
                    M.Refresh()
                end
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
                local obj = newObject("Act_TY_UNIVERSAL_DHIconInShop", temp_ui.act_node)
                obj.transform.localPosition = Vector3.New(80,70,0)
                local obj_childs = {}
                LuaHelper.GeneratingVar(obj.transform, obj_childs)           
                local task_id = M.GetTaskIDByGoodsID(GoodsData.goods_id)
                obj_childs.item_img.sprite = GetTexture(M.GetInforByItemConfig().image)
                if task_id and GameTaskModel.GetTaskDataByID(task_id) and GameTaskModel.GetTaskDataByID(task_id).award_status ~= 1 then
                    obj_childs.Icon_number_txt.text = "×"..this.UIConfig.shop_config[task_id].icon_txt
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

function M.GetCurHelpInfor()
    local help_desc = M.help_content.content
    local sta_t = M.GetStart_t()
    local end_t = M.GetEnd_t()
    help_desc[1] = "1.活动时间：".. sta_t .."-".. end_t
    return help_desc
end

function M.GetInforByItemConfig()
    for i,v in pairs(SysItemManager.item_config.config) do
        for k,n in pairs(M.fudai_key) do
            if v.item_key == n then
                return v
            end
        end
    end
end


function M.GetCurGotoUI()
    return this.UIConfig.goto_ui
end

function M.GetStart_t()
    return string.sub(os.date("%m月%d日%H:%M",M.GetActStartTime()),1,1) ~= "0" and os.date("%m月%d日%H:%M",M.GetActStartTime()) or string.sub(os.date("%m月%d日%H:%M",M.GetActStartTime()),2)
end

function M.GetEnd_t()
    return string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndTime()),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",M.GetActEndTime()) or string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndTime()),2)
end

function M.GetActStartTime()
    return this.UIConfig.sta_t
end

function M.GetActEndTime()
    return this.UIConfig.end_t
end

function M.GetCurBG()
    return M.cur_path.."xnhl_bg_4"
end

function M.GetItemKeys()
    local tab = basefunc.deepcopy(M.item_keys)
    return tab
end

function M.GetUniversalKey()
    return M.universal_item_key
end

function M.GetItemTips()
    return M.item_tips
end

function M.GetBtmTip()
    return M.btm_tip
end

function M.GetFuDaiExchangeKeys()
    return M.fudai_key
end

function M.GetFuDaiExchangeIds()
    return M.fudai_ex_change_id
end

--检查是否可以一键兑换
function M.CheckIsCanExchangeByOneKey()
    local tab = M.GetCurData()
    local temp = 0--缺的道具数量
    local need = 999999999999--缺的道具数量
    for i=1,#tab do
        if tab[i].remain_time ~= 0 then
            temp = 0
            for j=1,#tab[i].cost_item_key do
                if GameItemModel.GetItemCount(tab[i].cost_item_key[j]) < tab[i].cost_item_num[j] then
                    temp = temp + tab[i].cost_item_num[j] - GameItemModel.GetItemCount(tab[i].cost_item_key[j])
                end
            end
            need = math.min(need,temp)
        end
    end
    return GameItemModel.GetItemCount(M.GetUniversalKey()) >= need
end

function M.on_activity_all_exchange_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
    if data and data.result == 0 and data.type == M.type then
        M.query_data()
        local have_sw = false
        local ids = data.award_ids
        local tab = M.GetCurData()
        local asset_tab = {}
        for i=1,#ids do
            for j=1,#tab do
                if ids[i] == tab[j].ID then
                    if tab[j].type == 1 then
                        have_sw = true
                    else
                        dump(tab[j],"<color=yellow><size=15>++++++++++tab[j]++++++++++</size></color>")
                        for n=1,#tab[j].cfg.award_key do
                            asset_tab[#asset_tab + 1] = {asset_type = tab[j].cfg.award_key[n] ,value = tab[j].cfg.award_num[n]}
                        end  
                    end
                end
            end
        end
        --[[if not table_is_null(asset_tab) then
            Event.Brocast("AssetGet",{change_type = "universal_bymyself",data = asset_tab})
        end--]]
        if have_sw then
            local string1
            string1 = "实物奖励请关注公众号《"..Global_GZH.."》联系在线客服领取。"
            print(debug.traceback())
            local pre = HintCopyPanel.Create({desc=string1, isQQ=false,copy_value = Global_GZH})
            pre:SetCopyBtnText("复制公众号")
        end
        Event.Brocast("universal_activity_all_exchange_msg")
    end
end

function M.on_box_exchange_new_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
    if data and data.result == 0 then
        local tabs = M.GetFuDaiExchangeIds()
        if table_is_null(tabs) then return end
        for i=1,#tabs do
            if tabs[i] == data.id then
                M.Refresh()
                Event.Brocast("universal_box_exchange_msg")
                return
            end
        end
    end
end