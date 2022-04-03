-- 创建时间:2020-11-22
-- FishFarmBZZYManager 管理器

local basefunc = require "Game/Common/basefunc"
FishFarmBZZYManager = {}
local M = FishFarmBZZYManager
M.key = "sys_fishfarm_bzzy"


GameButtonManager.ExtLoadLua(M.key, "FishFarmBZZYEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "FishFarmBZZYPanel")
GameButtonManager.ExtLoadLua(M.key, "FishFarmBZZYItemPrefab")

local config_item = SysItemManager.item_config
local config_shop = GameButtonManager.ExtLoadLua(M.key, "fishbowl_shop")

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
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
    lister["EnterScene"] = this.OnEnterScene
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["fishbowl_shop_info_response"] = this.on_fishbowl_shop_info_response
end 

function M.Init()
	M.Exit()

	this = FishFarmBZZYManager
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
    this.UIConfig.award_map = {} 

    this.UIConfig.award_map_goods = {} 

    this.UIConfig.award_map_discounts = {} 

    for k,v in ipairs(config_item.config) do
        this.UIConfig.award_map[v.item_key] = v
    end

    for k,v in ipairs(config_shop.goods) do
        this.UIConfig.award_map_goods[k] = v
    end

   for k,v in ipairs(config_shop.discounts) do
        this.UIConfig.award_map_discounts[k] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.IsCanCreatEnter()
    local _time = {
        [1] = {8,10,},
        [2] = {14,18,},
        [3] = {20,22,},
    }
    for i=1,#_time do
        if tonumber(os.date("%H", os.time())) >= _time[i][1] and tonumber(os.date("%H", os.time())) < _time[i][2] then
            return true
        end
    end
    return false

    -- if (os.date("%H", os.time()) >= 8 and os.date("%H", os.time()) <= 11) or
    --     (os.date("%H", os.time()) >= 15 and os.date("%H", os.time()) <= 18) or
    --         (os.date("%H", os.time()) >= 20 and os.date("%H", os.time()) <= 22) then
    --             return true
    -- else
    --     return false
    -- end
end


function M.OnEnterScene()
    if MainModel.myLocation == "game_FishFarm" then 
        if M.IsCanCreatEnter() then 
            FishFarmBZZYEnterPrefab.Create()   
        end 
    end 
end


-- -     "bought_discounts" = { 已经购买了的折扣物品
-- -     }
-- -     "bought_goods" = { 已经购买了的普通物品
-- -     }
-- -     "discounts" = { 折扣物品
-- -         1 = 1
-- -     }
-- -     "goods" = { 普通物品
-- -         1 = 7
-- -         2 = 5
-- -         3 = 11
-- -         4 = 3
-- -         5 = 2
-- -         6 = 12
-- -     }
-- -     "result"           = 0
-- -     "time"             = "1605888000"
-- - }
function M.on_fishbowl_shop_info_response(_, data)
    dump(data,"<color=red>  EEEEEEE on_fishbowl_shop_info_response</color>")
    this.m_data.infor = {}
    --this.m_data.discounts = {}

    if data and data.result == 0 then
        this.m_data.infor = data
        this.m_data.bought_discounts_map = {}
        this.m_data.bought_goods_map = {}
        if data.bought_discounts then
            for k,v in ipairs(data.bought_discounts) do
                this.m_data.bought_discounts_map[v] = 1
            end
        end
        if data.bought_goods then
            for k,v in ipairs(data.bought_goods) do
                this.m_data.bought_goods_map[v] = 1
            end
        end

        this.m_data.fresh_need_infos = data.fresh_need_infos
        --this.m_data.discounts = data.discounts
        -- 1 是请求刷新 0 是自动刷新
        if data.fresh == 0 then
            Event.Brocast("fish_farm_bzzy_infor_msg")
        end
    else
        LittleTips.Create("当前资产不足，不能进行刷新！")
    end
end


function M.GetCurBzzyInfor()
    return this.m_data.infor
end


function M.GetFreshNeedInfors()
    return this.m_data.fresh_need_infos.asset_count[1] or 0
end

function M.GetGiftInforByConfig()
    if not table_is_null(this.m_data.infor) and this.m_data.infor then
        local cfg = {}
        for i,v in ipairs(this.m_data.infor.discounts) do
            cfg[i] = basefunc.deepcopy(this.UIConfig.award_map_discounts[v])
            cfg[i].ui = {}
            cfg[i].ui = basefunc.deepcopy(this.UIConfig.award_map[cfg[i].asset_type])
            cfg[i].type = 2
            if this.m_data.bought_discounts_map[v] then
                cfg[i].is_buy = true
            else
                cfg[i].is_buy = false
            end
        end
        for i,v in ipairs(this.m_data.infor.goods) do
            cfg[#cfg + 1] = basefunc.deepcopy(this.UIConfig.award_map_goods[v])
            cfg[#cfg].ui = {}
            cfg[#cfg].ui = basefunc.deepcopy(this.UIConfig.award_map[cfg[#cfg].asset_type])
            cfg[#cfg].type = 1
            if this.m_data.bought_goods_map[v] then
                cfg[#cfg].is_buy = true
            else
                cfg[#cfg].is_buy = false
            end
        end

        MathExtend.SortListCom(cfg, function (v1, v2)
            if not v1.is_buy and v2.is_buy then
                return false
            elseif v1.is_buy and not v2.is_buy then
                return true
            else
                if v1.type == 2 and v2.type == 1 then
                    return false
                elseif v1.type == 1 and v2.type == 2 then
                    return true
                else
                    if v1.id > v2.id then
                        return true
                    else
                        return false
                    end
                end
            end
        end)

        return cfg
    end
end