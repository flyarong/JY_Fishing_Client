-- 创建时间:2020-11-24
-- SYSFishFarmSimplicityManager 管理器

local basefunc = require "Game/Common/basefunc"
SYSFishFarmSimplicityManager = {}
local M = SYSFishFarmSimplicityManager
M.key = "sys_fishfarm_simplicity"
GameButtonManager.ExtLoadLua(M.key,"SYSFishFarmSimplicityGamePanel")
GameButtonManager.ExtLoadLua(M.key,"SYSFishFarmSimplicityEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"SYSFishFarmSimplicityFishFarmPanel")
GameButtonManager.ExtLoadLua(M.key,"SYSFishFarmSimplicityFishFarmItemBase")
GameButtonManager.ExtLoadLua(M.key,"SYSFishFarmSimplicityBagPanel")
GameButtonManager.ExtLoadLua(M.key,"SYSFishFarmSimplicityBagItemBase")
GameButtonManager.ExtLoadLua(M.key,"SYSFishFarmSimplicityOneKeySaleItemBase")
GameButtonManager.ExtLoadLua(M.key,"SYSFishFarmSimplicityOneKeySalePanel")
GameButtonManager.ExtLoadLua(M.key,"SYSFishFarmSimplicitySalePanel")
GameButtonManager.ExtLoadLua(M.key,"SYSFishFarmSimplicityLeftPage")
GameButtonManager.ExtLoadLua(M.key,"FishFarmFeedPanel")
GameButtonManager.ExtLoadLua(M.key,"FishFarmUpLevelPanel")
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
        return
    end
    if parm.goto_scene_parm == "panel" then
        return SYSFishFarmSimplicityGamePanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return SYSFishFarmSimplicityEnterPrefab.Create(parm.parent, parm.cfg)
    elseif parm.goto_scene_parm == "panel_sl" then
        return FishFarmFeedPanel.Create()
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["model_fishbowl_backpack_change_msg"] = this.on_model_fishbowl_backpack_change_msg

end

function M.Init()
	M.Exit()

	this = SYSFishFarmSimplicityManager
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
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()
end

function M.CheckIsShowOneKeySaleBtn()
    if MainModel.UserInfo.vip_level >= 3 then
        return true
    else
        return false
    end
end

function M.GetFishbowlOfFishList()
    this.m_data.fish_list = FishFarmManager.GetFishbowlOfFishList("up")
    return this.m_data.fish_list
end

function M.on_model_fishbowl_backpack_change_msg()
    -- 刷新
    Event.Brocast("on_model_fishbowl_backpack_change_msg")
end

function M.GetFishConfig(id)
    this.m_data.fish_config = this.m_data.fish_config or {}
    this.m_data.fish_config[id] = FishFarmManager.GetFishConfig(id)
    return this.m_data.fish_config[id]
end

function M.GetFishByState(cfg,level)
    return FishFarmManager.GetFishByState(cfg,level)
end


-- tag: prop_fishbowl_fry  prop_fishbowl_fry_fragment  prop_fishbowl_fish
function M.GetBagList(tag)
    local key_list = FishFarmManager.GetBagKeyList(tag)
    this.m_data["bag_"..tag.."_list"] = {}
    for k,v in pairs(key_list) do
        if GameItemModel.GetItemCount(v) > 0 then
            local len = string.len(tag)
            local id = tonumber(string.sub(v,len + 1))
            this.m_data["bag_"..tag.."_list"][#this.m_data["bag_"..tag.."_list"] + 1] = {key = v ,config = M.GetFishConfig(id),num = GameItemModel.GetItemCount(v)}
        end
    end
    local sort = function (v1,v2)
        if v1.config.id >= v2.config.id then
            return false
        else
            return true
        end
    end
    MathExtend.SortListCom(this.m_data["bag_"..tag.."_list"], sort)
    return this.m_data["bag_"..tag.."_list"]
end

function M.GetFishbowlMaxCount()
    this.m_data.capacity = FishFarmManager.GetFishbowlMaxCount()
    return this.m_data.capacity
end

--获取当前水缸中的鱼的数量
function M.GetCurFishbowlFishNum()
    return #M.GetFishbowlOfFishList()
end

function M.SaleObj(id)
    Network.SendRequest("fishbowl_sale_obj",{obj_id = id})
end

function M.SaleProp(props, num)
    dump(props,"<color=yellow><size=15>++++++++++key++++++++++</size></color>")
    dump(num)
    Network.SendRequest("fishbowl_sale_prop",{props = props, num=num})
end

function M.PutProp(prop)
    Network.SendRequest("fishbowl_hatch",{prop = prop})
end

function M.HarvestObj(id)
    Network.SendRequest("fishbowl_collect",{obj_id = id})
end

function M.GetStarsNum()
    return GameItemModel.GetItemCount("prop_fishbowl_stars")
end

function M.GetFeedNum()
    return GameItemModel.GetItemCount("prop_fishbowl_feed")
end

function M.FeedFish(id)
    if id then
        Network.SendRequest("fishbowl_feed",{obj_id = id})
    else
        Network.SendRequest("fishbowl_feed")
    end
end

function M.GetItemCountMoneyList(tag)
    return FishFarmManager.GetItemCountMoneyList(tag)
end

--根据鱼苗类型获取他对应的key
function M.GetItemKeyByFsihType(tag)
    local config = HotUpdateConfig("Game.CommonPrefab.Lua.fishbowl_config").fish
    dump(config,"<color=yellow><size=15>++++++++++FishFarmManager.UIConfig.fishbowl_config.fish++++++++++</size></color>")
    local tab = {}
    for k,v in pairs(config) do
        if tag == v.fish_type then
            tab[#tab + 1] = "prop_fishbowl_fry"..v.id
        end
    end
    return tab
end