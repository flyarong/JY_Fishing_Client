-- 创建时间:2020-09-22
-- BY3DHDManager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DHDManager = {}
local M = BY3DHDManager
M.key = "by3d_hd"
GameButtonManager.ExtLoadLua(M.key, "BY3DHDEnterPrefab")

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
    if parm.goto_scene_parm == "hecheng" or (FishingModel and FishingModel.game_id ~= 1 and FishingModel.game_id ~= 2) then
        return M.IsActive()
    end
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

    if parm.goto_scene_parm == "enter" then
        return BY3DHDEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "hecheng" then
        local index = tonumber(parm.data)
        local cfg = M.GetHCConfigByIndex(tonumber(parm.data))
        local d = {}
        local sp_cfg = GameItemModel.GetItemToKey(cfg.sp)
        local dj_cfg = GameItemModel.GetItemToKey(cfg.item)
        d.sp_image = sp_cfg.image
        d.hc_image = dj_cfg.image

        local sp_num = GameItemModel.GetItemCount(cfg.sp)
        d.sp_num = sp_num
        d.hc_num = cfg.hc_num

        local hc_call = function (num)
            if num > 0 then
                Network.SendRequest("box_exchange",{ id = this.UIConfig.hc_config[index].hc_id , num = num }, "", function (data)
                    if data.result ~= 0 then
                        HintPanel.ErrorMsg(data.result)
                    end
                end)
            else
                LittleTips.Create("碎片数量不足")
            end            
        end
        return GameComHCPrefab.Create(d, hc_call)
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
end

function M.Init()
	M.Exit()

	this = BY3DHDManager
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

    this.UIConfig.hc_config = {}
    this.UIConfig.hc_config[1] = {hc_id=43, hc_num=100, sp="prop_3d_fish_nuclear_bomb_fragment_1", item="prop_3d_fish_nuclear_bomb_1"}
    this.UIConfig.hc_config[2] = {hc_id=44, hc_num=100, sp="prop_3d_fish_nuclear_bomb_fragment_2", item="prop_3d_fish_nuclear_bomb_2"}
    this.UIConfig.hc_config[3] = {hc_id=45, hc_num=100, sp="prop_3d_fish_nuclear_bomb_fragment_3", item="prop_3d_fish_nuclear_bomb_3"}
    this.UIConfig.hc_config[4] = {hc_id=61, hc_num=100, sp="prop_3d_fish_nuclear_bomb_fragment_4", item="prop_3d_fish_nuclear_bomb_4"}
    this.UIConfig.hc_config[5] = {hc_id=62, hc_num=100, sp="prop_3d_fish_nuclear_bomb_fragment_5", item="prop_3d_fish_nuclear_bomb_5"}

    this.UIConfig.item_map = {}
    this.UIConfig.item_map["prop_3d_fish_nuclear_bomb_1"] = 1
    this.UIConfig.item_map["prop_3d_fish_nuclear_bomb_2"] = 2
    this.UIConfig.item_map["prop_3d_fish_nuclear_bomb_3"] = 3
    this.UIConfig.item_map["prop_3d_fish_nuclear_bomb_4"] = 4
    this.UIConfig.item_map["prop_3d_fish_nuclear_bomb_5"] = 5

    this.UIConfig.item_map["prop_3d_fish_nuclear_bomb_give_1"] = 1
    this.UIConfig.item_map["prop_3d_fish_nuclear_bomb_give_2"] = 2
    this.UIConfig.item_map["prop_3d_fish_nuclear_bomb_give_3"] = 3
    this.UIConfig.item_map["prop_3d_fish_nuclear_bomb_give_4"] = 4
    this.UIConfig.item_map["prop_3d_fish_nuclear_bomb_give_5"] = 5
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetHCConfigByIndex(index)
    return this.UIConfig.hc_config[index]
end

function M.GetHDNumByIndex(index)
    local n1 = GameItemModel.GetItemCount("prop_3d_fish_nuclear_bomb_give_" .. index)
    local n2 = GameItemModel.GetItemCount("prop_3d_fish_nuclear_bomb_" .. index)
    return (n1 + n2)
end

function M.GetItemIndex(key)
    return this.UIConfig.item_map[key]
end
