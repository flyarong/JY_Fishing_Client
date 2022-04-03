-- 创建时间:2021-01-11
-- Act_Ty_QJD1Manager 管理器

local basefunc = require "Game/Common/basefunc"
Act_Ty_QJD1Manager = {}
local M = Act_Ty_QJD1Manager
M.key = "act_ty_fkqjd"
M.config = GameButtonManager.ExtLoadLua(M.key,"act_ty_fkqjd_config")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_QJD1Panel")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_QJD1EnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_QJD1GiftItemBase")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_QJD1HammerItemBase")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_QJD1KnockPanel")

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.GetActEndTime()
    local s_time = M.GetActStartTime()
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    dump(M.GetNowPerMiss(),"<color=red>敲金蛋模板类型1权限</color>")
    if M.GetNowPerMiss() then 
        return true
    end
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
    if parm.goto_scene_parm == "panel" then
        return Act_Ty_QJD1Panel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return Act_Ty_QJD1EnterPrefab.Create(parm.parent, parm.cfg)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsHaveHammer() then
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
    lister["finish_gift_shop"] = this.on_finish_gift_shop--完成礼包购买
end


function M.Init()
	M.Exit()

	this = Act_Ty_QJD1Manager
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
    M.UIConfig.Status = {
        None = "none",
        Knocking = "knocking",
    }
    M.show_asset_tip = false
    M.cur_satatus = M.UIConfig.Status.None
    M.UIConfig.help_info = M.config.other_data[1].help_txt
    M.UIConfig.btm_txt = M.config.other_data[1].btm_txt[1]

    M.permisstions = {}
    for i=1,#M.config.platform_or_channel_or_level do
        M.permisstions[#M.permisstions + 1] = M.config.platform_or_channel_or_level[i].permission
    end 
    M.GetNowPerMiss()
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.BuyGift(shopid)
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function M.GetActStartTime()
    return M.config.other_data[1].sta_t
end

function M.GetActEndTime()
    return M.config.other_data[1].end_t
end

function M.GetStart_t()
    return string.sub(os.date("%m月%d日%H:%M",M.GetActStartTime()),1,1) ~= "0" and os.date("%m月%d日%H:%M",M.GetActStartTime()) or string.sub(os.date("%m月%d日%H:%M",M.GetActStartTime()),2)
end

function M.GetEnd_t()
    return string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndTime()),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",M.GetActEndTime()) or string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndTime()),2)
end

function M.GetHelpInfo()
    return M.UIConfig.help_info
end

function M.GetBtmTxt()
    return M.UIConfig.btm_txt
end

function M.GetNowPerMiss()
    local cheak_fun = function (_permission_key)
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                return false
            end
            return true
        else
            return false
        end
        return true
    end
    M.now_level = nil
    for i = 1,#M.permisstions do 
        if cheak_fun(M.permisstions[i]) then
            dump(M.permisstions[i],"符合条件的权限")
            M.now_level = i  
            return i
        end
    end
end

function M.GetGiftCfg()
    local tab = {}
    local t = M.config.platform_or_channel_or_level[M.now_level].gift_config
    for i=1,#t do
        tab[#tab + 1] = M.config.gift_config[t[i]]
    end
    return tab
end

function M.GetEggsCfg()
    local tab = {}
    local t = M.config.platform_or_channel_or_level[M.now_level].eggs_config
    for i=1,#t do
        tab[#tab + 1] = M.config.eggs_config[t[i]]
    end
    return tab
end

function M.GetCurStatusIsKnocking()
    return M.cur_satatus == M.UIConfig.Status.Knocking
end

function M.SetCurStatusIsKnocking(b)
    M.cur_satatus = b and M.UIConfig.Status.Knocking or M.UIConfig.Status.None
end

function M.IsHaveHammer()
    local tab = M.GetEggsCfg()
    for k,v in pairs(tab) do
        if GameItemModel.GetItemCount(v.item_key) > 0 then
            return true
        end
    end
    return false
end

function M.GetHammerCount(index)
    local tab = M.GetEggsCfg()
    return GameItemModel.GetItemCount(tab[index].item_key)
end

function M.GetTJIndex()
    local tab = M.GetEggsCfg()
    for i=#tab ,1,-1 do
        if GameItemModel.GetItemCount(tab[i].item_key) > 0 then
            return i
        end
    end
    return 3
end

function M.KnockEgg(task_id)
    Network.SendRequest("get_task_award",{id = task_id})
end

function M.GetEggData(task_id)
    local data = GameTaskModel.GetTaskDataByID(task_id)
    if data == nil then return end
    local tab = {}
    if data.award_status == 2 then 
        tab.is_broken = true
    else
        tab.is_broken = false
    end
    --dump(data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
    local other_data = basefunc.parse_activity_data(data.other_data_str)
    tab.hit_num = other_data.now_hit_num
    tab.total_num = other_data.total_hit_num
    return tab
end

function M.on_model_get_task_award_response(data)
    local tab = M.GetEggsCfg()
    --dump(data,"<color=yellow><size=15>++++++++++on_model_get_task_award_response++++++++++</size></color>")
    if not data or table_is_null(tab) then return end
    for k,v in pairs(tab) do
        if v.task_id == data.id then
            local data = GameTaskModel.GetTaskDataByID(data.id)
            local other_data = basefunc.parse_activity_data(data.other_data_str)
            if other_data.now_hit_num == 0 then
                M.show_asset_tip = true
            end
            Event.Brocast("qjd1_get_task_award_msg")
        end
    end
end

function M.ShowAssetTip(index)
    if M.show_asset_tip then
        M.show_asset_tip = false 
        local tab = M.GetEggsCfg()
        Event.Brocast("AssetGet",{change_type = "task_p_hammer_by_myself",data = {[1] = {asset_type = "jing_bi",value = tab[index].award_txt}}})
    end
end

function M.on_finish_gift_shop(id)
    local tab = M.GetGiftCfg()
    if not id or table_is_null(tab) then return end
    for k,v in pairs(tab) do
        if v.gift_id == id then
            Event.Brocast("qjd1_finish_gift_msg")
        end
    end
end

