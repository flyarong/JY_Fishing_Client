-- 创建时间:2020-02-04
-- YCS_CSSLManager 1 管理器

local basefunc = require "Game/Common/basefunc"
YCS_CSSLManager = {}
local M = YCS_CSSLManager
M.key = "act_ycs_cssl"
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_ycs_cssl_config") 
GameButtonManager.ExtLoadLua(M.key, "YCS_CSSLListPanel")
GameButtonManager.ExtLoadLua(M.key, "YCS_CSSLMorePanel")
GameButtonManager.ExtLoadLua(M.key, "YCS_CSSLPanel")
GameButtonManager.ExtLoadLua(M.key, "YCS_CSSLMyListPanel") 
local this
local lister

-- 是否有活动
function M.IsActive()
    if os.time() >= 1613433600 and os.time() <= 1614009599 then
        return true
    else
        return false
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return true
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return YCS_CSSLPanel.Create(parm.parent)
    end 
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if  GameItemModel.GetItemCount("prop_fish_drop_act_1") >= 50 or M.IsAwardCanGet()then
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
    lister["AssetChange"] = this.Refresh
    lister["PayPanel_GoodsChangeToGift"] = this.on_PayPanel_GoodsChangeToGift
    lister["PayPanelClosed"] = this.on_PayPanelClosed
end

function M.Init()
	M.Exit()
	this = YCS_CSSLManager
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
    this.UIConfig={
    }

    this.UIConfig.goodsid_config_map = {}
    this.UIConfig.task_list = {}
    for k,v in pairs(M.config.shop_config) do
        for i=1,#v.shop_id do
            this.UIConfig.goodsid_config_map[v.shop_id[i]] = v.task_id
            this.UIConfig.task_list[v.task_id] = v
        end
    end

end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
        Event.Brocast("global_hint_state_change_msg", parm)
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
end

function M.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
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
                local obj = newObject("YCS_LIconInShop", temp_ui.act_node)
                obj.transform.localPosition = Vector3.New(80,70,0)
                local obj_childs = {}
                LuaHelper.GeneratingVar(obj.transform, obj_childs)           
                local task_id = M.GetTaskIDByGoodsID(GoodsData.goods_id)
                --obj_childs.item_img.sprite = GetTexture(M.GetInforByItemConfig().image)
                if task_id and GameTaskModel.GetTaskDataByID(task_id) and GameTaskModel.GetTaskDataByID(task_id).award_status ~= 1 then
                    obj_childs.Icon_number_txt.text = "×"..this.UIConfig.task_list[task_id].icon_txt
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
    return this.UIConfig.goodsid_config_map[goods_id]
end
function M.GetCurTipsInfor()
    return M.config.tips
end

function M.GetAwardIndex(_award_id)
    for i,v in ipairs(M.config.Award) do
        if _award_id == v.server_award_id then
            return i
        end
    end
end

function M.IsAwardCanGet()
    local all_task_award_status = M.GetAllTaskAwardStatus(1000320)
    if table_is_null(all_task_award_status) then return end
    for i,v in ipairs(all_task_award_status) do
        if v == 1 then
            return true
        end
    end
    return false
end


function M.GetAllTaskAwardStatus(task_id)
   if not task_id then return end 
   local td = GameTaskModel.GetTaskDataByID(task_id)
   if table_is_null(td) then return end
   local all_task_award_status = basefunc.decode_task_award_status(td.award_get_status)
   all_task_award_status = basefunc.decode_all_task_award_status(all_task_award_status, td,5)
   return all_task_award_status
end
