-- 创建时间:2020-09-14
-- Act_Ty_ZP1Manager 管理器
--功能变化记录：畅玩礼包 -> 重阳福利 ->双11狂欢
                                                                                            
local basefunc = require "Game/Common/basefunc"
Act_Ty_ZP1Manager = {}
local M = Act_Ty_ZP1Manager
M.key = "act_ty_zp1"
local config = GameButtonManager.ExtLoadLua(M.key, "act_ty_zp1_config")
GameButtonManager.ExtLoadLua(M.key, "Act_Ty_ZP1Panel")
GameButtonManager.ExtLoadLua(M.key, "Act_Ty_ZP1EnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_Ty_ZP1GiftPrefab")

local permisstions = {}
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
    end
    if not table_is_null(permisstions) then
        for i = 1,#permisstions do 
            if cheak_fun(permisstions[i]) then
                dump(permisstions[i],"符合条件的权限")
                return i
            end
        end
        return
    else
        return 1
    end

end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end

    if parm.goto_scene_parm == "panel" then
        return Act_Ty_ZP1Panel.Create()
    elseif parm.goto_scene_parm == "enter" then
        return Act_Ty_ZP1EnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    local n = GameItemModel.GetItemCount(M.cjq_item)
    if n>0 then
        -- body
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
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

    lister["shop_info_get"] = this.on_shop_info_get
end

function M.Init()
	M.Exit()

	this = Act_Ty_ZP1Manager
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
    for i=1,#config.platform_channel do
        permisstions[#permisstions + 1] = config.platform_channel[i].permission
    end
    local index = M.GetNowPerMiss() or 1

    this.UIConfig = {}
    M.cjq_item = config.platform_channel[index].item_key
    M.box_exchange_id = config.platform_channel[index].box_exchange_id


    local temp_config = config[config.platform_channel[index].config]
    local temp_gift = config[config.platform_channel[index].gift]
    this.UIConfig.award_list = {}
    this.UIConfig.award_map = {}   
    for k,v in ipairs(temp_config) do
        this.UIConfig.award_list[k] = v
        if v.award_id then
            this.UIConfig.award_map[v.award_id] = v
        end
    end
    this.UIConfig.gift_list = {}
    this.UIConfig.gift_map = {}
    for k,v in ipairs(temp_gift) do
        this.UIConfig.gift_list[k] = v
        this.UIConfig.gift_map[v.gift_id] = v
    end
    this.UIConfig.help_info = config.other_data[index].help_info
    this.UIConfig.xg_desc = config.other_data[index].xg_desc
    this.UIConfig.Issort = config.other_data[index].sort == 1
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.QueryData()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryData()
    local list = {}
    for k,v in ipairs(this.UIConfig.gift_list) do
        list[#list + 1] = v.gift_id
    end
    NetMsgSendManager.SendMsgQueue("query_gift_bag_status_by_ids", {gift_bag_ids = list})
end

function M.on_shop_info_get(list)
    dump(list, "<color=red>EEE shop_info_get </color>")
    if this.UIConfig.gift_map[ list[1] ] then
        Event.Brocast("act_ty_zp1_data_finish_msg")
    end
end

function M.GetAwardConfig()
    return this.UIConfig.award_list
end

--获取礼包config
function M.GetGiftConfig()
    return this.UIConfig.gift_list
end


--获取排序后的礼包config
function M.GetGiftConfigAndSort()
    local list = {}
    for k,v in ipairs(this.UIConfig.gift_list) do
        list[#list + 1] = v
    end

    MathExtend.SortListCom(list, function (v1, v2)
        local n1 = MainModel.GetRemainTimeByShopID(v1.gift_id)
        local n2 = MainModel.GetRemainTimeByShopID(v2.gift_id)
        if n1 < n2 then
            return true
        elseif n1 > n2 then
            return false
        else
            if v1.order > v2.order then
                return false
            else
                return true
            end
        end
    end)

    return list
end

--获取礼包config
function M.GetGiftConfigById(gift_id)
    return this.UIConfig.gift_map[gift_id]
end

--获取奖励config
function M.GetAwardConfigByAwardID(award_id)
    return this.UIConfig.award_map[award_id]
end

--获取帮助界面内容
function M.GetHelpInfo()
    return this.UIConfig.help_info
end

--获取时间展示方式  固定时间显示或者倒计时
function M.GetActTimeShowType()
    local index = M.GetNowPerMiss() or 1
    return config.other_data[index].act_time
end

--获取当前皮肤设置
function M.GetActCurPath()
    local index = M.GetNowPerMiss() or 1
    if config.other_data[index].cur_path then
        return config.other_data[index].cur_path
    end
end
--获取活动开始时间戳
function M.GetActStartTime()
    local index = M.GetNowPerMiss() or 1
    return config.other_data[index].sta_t
end

--获取活动结束时间戳
function M.GetActEndTime()
    local index = M.GetNowPerMiss() or 1
    return config.other_data[index].end_t
end

--获取限购描述
function M.GetXg_Desc()
    return this.UIConfig.xg_desc
end

--获取是否需要排序
function M.GetIsSort()
    return this.UIConfig.Issort
end

--请求某个礼包的剩余次数
function M.QueryRemainTimeById(id)
    local ids = {}
    ids[#ids + 1] = id
    Network.SendRequest("query_gift_bag_status_by_ids", {gift_bag_ids=ids})
end
local gift_buy_Time
function M.ChargeBuyTime()
    if gift_buy_Time then
        -- body
        if gift_buy_Time>(os.time()-7) then
            -- body
            LittleTips.Create("你的操作太频繁，请5秒后再操作！")
            return false
        else
            gift_buy_Time=os.time()
            return  true
        end
    else
        gift_buy_Time=os.time()
        return true
    end
end