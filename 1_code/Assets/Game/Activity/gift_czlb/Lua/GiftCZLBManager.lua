-- 创建时间:2020-08-07
-- GiftCZLBManager 管理器

local basefunc = require "Game/Common/basefunc"
GiftCZLBManager = {}
local M = GiftCZLBManager
M.key = "gift_czlb"
GameButtonManager.ExtLoadLua(M.key, "GiftCZLBPanel")
GameButtonManager.ExtLoadLua(M.key, "GiftCZLBAwardPrefab")
GameButtonManager.ExtLoadLua(M.key, "GiftCZLBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "GiftCZLBTagPrefab")
local config = GameButtonManager.ExtLoadLua(M.key, "gift_czlb_config")

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
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not  M.CheckIsShow() then
        return
    end
    if parm.goto_scene_parm == "enter" then
        return GiftCZLBEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return GiftCZLBPanel.Create()
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsCanBuyGift() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Red
    end
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

    lister["main_change_gift_bag_data_msg"] = this.on_gift_bag_data_change_msg
    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg
    lister["finish_gift_shop"] = this.on_finish_gift_shop
end

function M.Init()
	M.Exit()

	this = GiftCZLBManager
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

    this.UIConfig.gift_map = {}
    this.UIConfig.grade_map = {}
    this.UIConfig.grade_list = {}
    for k,v in ipairs(config.base) do
        this.UIConfig.grade_map[v.id] = v
        this.UIConfig.grade_list[#this.UIConfig.grade_list + 1] = v
        for i,id in ipairs(v.gift_ids) do
            local j = (i - 1) * 3 + 1
            local bb = {}
            bb.award = {}
            bb.award[#bb.award + 1] = {pay_name=v.pay_name[j], icon_img=v.icon_img[j], tips=v.tips[j]}
            bb.award[#bb.award + 1] = {pay_name=v.pay_name[j+1], icon_img=v.icon_img[j+1], tips=v.tips[j+1]}
            bb.award[#bb.award + 1] = {pay_name=v.pay_name[j+2], icon_img=v.icon_img[j+2], tips=v.tips[j+2]}
            bb.gift_id = id
            this.UIConfig.gift_map[id] = bb
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryGiftBagData()
    if this.m_data.is_data_finish then
        Event.Brocast("gift_czlb_gift_bag_data_finish_msg")
    else
        local msg_list = {}
        for _,v in pairs(this.UIConfig.gift_map) do
            msg_list[#msg_list + 1] = {msg="query_gift_bag_status", data = {gift_bag_id = v.gift_id}}
        end
        GameManager.SendMsgList("gift_czlb_gift", msg_list)
    end
end

function M.GetGradeList()
    local cfg = {}
    for k,v in ipairs(this.UIConfig.grade_list) do
        cfg[#cfg + 1] = basefunc.copy(v)
        cfg[#cfg].sort_cur_day = M.GetTagBuyDay(k)
    end
    MathExtend.SortListCom(cfg, function (v1, v2)
        if v1.sort_cur_day > 1 and v2.sort_cur_day == 1 then
            return false
        elseif v1.sort_cur_day == 1 and v2.sort_cur_day > 1 then
            return true
        else
            if v1.sort_cur_day == 1 and v2.sort_cur_day == 1 then
                if v1.id < v2.id then
                    return false
                else
                    return true
                end
            else
                if v1.id < v2.id then
                    return true
                else
                    return false
                end
            end
        end
    end)
    return cfg
end

function M.GetGiftConfig(gift_id)
    return this.UIConfig.gift_map[gift_id]
end

function M.on_gift_bag_data_change_msg(gift_id)
    if this.UIConfig.gift_map[gift_id] then
        Event.Brocast("gift_czlb_gift_bag_data_change_msg")
    end
end
function M.on_query_send_list_fishing_msg(tag)
    if tag == "gift_czlb_gift" then
        this.m_data.is_data_finish = true
        Event.Brocast("gift_czlb_gift_bag_data_finish_msg")
    end
end
function M.on_finish_gift_shop(gift_id)
    if this.UIConfig.gift_map[gift_id] then
        Event.Brocast("gift_czlb_gift_bag_data_change_msg")
    end
end

-- 档次对应的礼包列表
function M.GetTagGiftList(tag)
    return this.UIConfig.grade_map[tag].gift_ids
end

-- 当前档次购买到第几天
function M.GetTagBuyDay(tag)
    local list = M.GetTagGiftList(tag)
    local gi = 1
    for i = #list, 2, -1 do
        local data = MainModel.GetGiftDataByID(list[i])
        if data then            
            local permit_start_time = tonumber(data.permit_start_time) or 0
            local time = tonumber(data.time) or 0

            local curtime = tonumber(os.date("%Y%m%d", MainModel.GetCurTime() ))
            permit_start_time = tonumber(os.date("%Y%m%d", permit_start_time ))
            time = tonumber(os.date("%Y%m%d", time ))
            
            if time == curtime or curtime == permit_start_time then
                return i
            end
        end        
    end
    return gi
end

-- 下一个可购买的礼包
function M.GetTagNextBuyDay(tag)
    local list = M.GetTagGiftList(tag)
    local day = M.GetTagBuyDay(tag)
    if not MainModel.IsCanBuyGiftByID(list[day]) then
        day = day + 1
    end
    return day
end

-- 当前档次能不能购买，能购买就返回礼包ID
function M.GetTagCanBuyGiftID(tag)
    local list = M.GetTagGiftList(tag)
    local day = M.GetTagBuyDay(tag)
    if MainModel.IsCanBuyGiftByID(list[day]) then
        return list[day]
    end
end
-- 有没有礼包可以购买
function M.IsCanBuyGift()
    for i = 1, #this.UIConfig.grade_list do
        local id = M.GetTagCanBuyGiftID(i)
        if id then
            return true
        end
    end
    return false
end
function M.SetRedByKey(key)
    local red_key = M.key .. "_" .. key .. "_" .. MainModel.UserInfo.user_id
    PlayerPrefs.SetString(red_key, MainModel.GetCurTime())
end
function M.IsRedByKey(key)
    local red_key = M.key .. "_" .. key .. "_" .. MainModel.UserInfo.user_id
    local old_t = PlayerPrefs.GetString(red_key, "0")

    local newtime = tonumber( os.date("%Y%m%d", MainModel.GetCurTime()) )
    local oldtime = tonumber( os.date("%Y%m%d", tonumber(old_t)) )

    if oldtime ~= newtime then
        return true
    else
        return false
    end
end
