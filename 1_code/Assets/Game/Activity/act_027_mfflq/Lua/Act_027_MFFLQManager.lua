-- 创建时间:2020-04-08
-- Act_027_MFFLQManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_027_MFFLQManager = {}
local M = Act_027_MFFLQManager
M.key = "act_027_mfflq"

GameButtonManager.ExtLoadLua(M.key, "Act_027_MFFLQPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_027_MFFLQEnterPrefab")
M.config = GameButtonManager.ExtLoadLua(M.key, "act_027_mfflq_config").data[1]
local this
local lister
M.shopid = M.config.gift_id
M.box_exchange_id = M.config.box_exchange_id
M.award_index = M.config.award_index
local task_id = 0

M.can_lottery = false
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.config.end_t
    local s_time = M.config.sta_t
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        dump(os.time(),"<color=red>免费礼包bug</color>")
        return false
    end

    -- 对应权限的key
    local _permission_key = M.config.permission
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
function M.CheckIsShow()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.IsActive() then
            return Act_027_MFFLQPanel.Create(parm.parent,parm.backcall)
        end
    end
    if parm.goto_scene_parm == "enter" then
        if parm.parent.parent.gameObject.name == "ActivityYearPanel" then
            local b = Act_027_MFFLQEnterPrefab.Create(parm.parent)
            CommonHuxiAnim.Start(b.gameObject)
        else
            return Act_027_MFFLQEnterPrefab.Create(parm.parent)
        end
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsAwardCanGet()   then
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
    lister["EnterScene"] = this.OnEnterScene
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["client_system_variant_data_change_msg"] = this.on_client_system_variant_data_change_msg
    lister["query_gift_bag_status_response"] = this.on_query_gift_bag_status_response
end

function M.Init()
	M.Exit()

	this = Act_027_MFFLQManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
        M.StopTimer()
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnEnterScene()
    local check_can_create = function()
        return M.IsActive() and not M.IsLotteryed()
    end
    --[[if MainModel.myLocation == "game_MiniGame" then
        if check_can_create() then 
            Act_027_MFFLQPanel.Create()
        end 
    end
    if MainModel.myLocation == "game_Free" then
        if check_can_create() then 
            Act_027_MFFLQPanel.Create()
        end 
    end
    if MainModel.myLocation == "game_Match" then
        if check_can_create() then 
            Act_027_MFFLQPanel.Create()
        end 
    end--]]
    --[[if MainModel.myLocation == "game_Fishing3D" then
        if check_can_create() then 
            Act_027_MFFLQPanel.Create()
        end 
    end--]]
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end


function M.IsAwardCanGet()
    if GameItemModel.GetItemCount("prop_mfcjq") > 0 then
        return true
    end
end

function M.BuyShop()
    local shopid = M.shopid 
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function M.IsLotteryed()
	local newtime = tonumber(os.date("%Y%m%d", os.time()))
	for i = 1,4 do
		local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id .. "award" .. i, 0))))
		if oldtime == newtime then
            return true
        end
	end
	return false
end

function M.GetEndTime()
    local gift_config =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, M.shopid)
    if gift_config then
        return gift_config.end_time
    end
    return os.time()
end

function M.GetStartTime()
    local gift_config =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, M.shopid)
    if gift_config then
        return gift_config.start_time
    end
    return os.time()
end


function M.on_client_system_variant_data_change_msg()
    if M.IsActive() then
        M.QueryShopData()
    end
end

function M.QueryShopData()
    Network.SendRequest("query_gift_bag_status", {gift_bag_id = M.shopid})
end

function M.Timer_to_refresh(b)
    M.StopTimer()
    if b then
        M.QueryShopData()
        this.m_data.timer = Timer.New(function ()
            if not M.GetShopStatus() or M.GetShopStatus() ~= 1 then
                M.QueryShopData()
            end
        end,10,-1)
        this.m_data.timer:Start()
    end  
end

function M.StopTimer()
    if this.m_data.timer then
        this.m_data.timer:Stop()
        this.m_data.tiemr = nil
    end
end

function M.GetShopStatus()
    return this.m_data.status
end

function M.GetShopRemaintime()
    return this.m_data.remain_time
end

function M.on_query_gift_bag_status_response(_,data)
    if data and data.result == 0 then
        dump(data,"<color=yellow>++++++++on_query_gift_bag_status_response++++++++</color>")
        if data.gift_bag_id == M.shopid then
            this.m_data.status = data.status
            this.m_data.remain_time = data.remain_time
            Event.Brocast("027MFFLQ_query_gift_bag_status_msg")
        end
    end
end