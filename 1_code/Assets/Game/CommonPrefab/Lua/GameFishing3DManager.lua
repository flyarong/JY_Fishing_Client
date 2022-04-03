-- 创建时间:2020-04-30
-- 3D捕鱼 匹配场管理器

GameFishing3DManager = {}
local M = GameFishing3DManager
local fish3d_hall_config = HotUpdateConfig("Game.CommonPrefab.Lua.fish3d_hall_config")
local fish_map_config = HotUpdateConfig("Game.CommonPrefab.Lua.fish3d_map_config")

local lister
local this

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
end

function M.Init()
	M.Exit()
	print("<color=red>初始化 3D捕鱼 匹配场管理器</color>")
    this = M
    MakeLister()
    AddLister()
    M.InitConfig()
end
function M.Exit()
	if this then
    RemoveLister()
		this = nil
	end
end

function M.InitConfig()
	this.Config = {}

    local list = {}
    local map = {}
    for k,v in ipairs(fish3d_hall_config.game) do
        if v.is_on and v.is_on == 1 then
            map[v.game_id] = v
            list[#list + 1] = v
        end
    end
	this.Config.hall_list = list
	this.Config.hall_map = map

    this.Config.fish_list = fish_map_config.config
end
function M.is_show(cfg, game_id)
    if cfg.game_id then
        for k,v in ipairs(cfg.game_id) do
            if game_id == v then
                return true
            end
        end
    end
end

-- function
function M.GetFishCoinAndJingBi()
    if MainModel.UserInfo.jing_bi and MainModel.UserInfo.fish_coin then
        return MainModel.UserInfo.jing_bi + MainModel.UserInfo.fish_coin
    end
    return MainModel.UserInfo.jing_bi
end
function M.CheckRecommend(min, max, gold)
    dump({min=min,max=max,gold=gold},"<color=yellow>++++++++++++++++++</color>")
    if min and max then
        if (min == -1 or gold >= min) and (max == -1 or gold <= max) then
            return 0
        elseif min == -1 or gold < min then
            return -1
        elseif max == -1 or gold > max then
            return 1
        end
    elseif min and not max then
        if min == -1 or gold >= min then
            return 0
        else
            return -1
        end
    elseif not min and max then
        if max == -1 or gold <= max then
            return 0
        else
            return 1
        end
    end
    return 0
end
function M.GetHallCfg()
	return this.Config.hall_list
end
function M.GetGameIDToConfig(game_id)
	return this.Config.hall_map[game_id]
end

-- 是否锁住
function M.IsGameLockByID(game_id)
    local cfg = M.GetGameIDToConfig(game_id)
    local a,b = GameButtonManager.RunFun({gotoui="sys_by_level"}, "GetLevel")
    if a and b and cfg.lvevl > b then
        return true
    end
end

function M.CheckCanBeginGameIDByGold(game_id)
    return M.CheckCanBeginGameIDByGold2(game_id, M.GetFishCoinAndJingBi())
end
function M.CheckCanBeginGameIDByGold2(game_id, gold)
    local cfg = M.GetGameIDToConfig(game_id)
    if M.IsGameLockByID(game_id) then
        return 4
    else
        return M.CheckRecommend(cfg.enter_min, cfg.enter_max, gold)
    end
end

-- 判断推荐档次条件
function M.CheckCanTJGameBYGlod(game_id, gold)
    local cfg = M.GetGameIDToConfig(game_id)
    if M.IsGameLockByID(game_id) then
        return 4
    else
        return M.CheckRecommend(cfg.recommend_min, cfg.recommend_max, gold)
    end
end
-- 获取推荐的游戏ID
function M.GetTJGameID()
    if M.CheckCanTJGameBYGlod(1, M.GetFishCoinAndJingBi()) == 0 then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing3d_1", is_on_hint=true}, "CheckCondition")
        if not a or b then
            return 1
        end
    end


    for i = 5, 1, -1 do -- 6 7 8是boss场
        local v = this.Config.hall_list[i]
        local a = M.CheckCanTJGameBYGlod(v.game_id, M.GetFishCoinAndJingBi())
        if a == 0 then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing3d_"..v.game_id, is_on_hint=true}, "CheckCondition")
            if not a or b then
                return v.game_id
            end
        end
    end

    --[[
    -- 没有推荐的就找一个能进入的 程序自己加的逻辑
    for i = 2, 5 do -- 6 7 8是boss场
        local v = this.Config.hall_list[i]
        local a = M.CheckCanBeginGameIDByGold2(v.game_id, M.GetFishCoinAndJingBi())
        if a == 0 then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing3d_"..v.game_id, is_on_hint=true}, "CheckCondition")
            if not a or b then
                return v.game_id
            end
        end
    end
    --]]

    return this.Config.hall_list[1].game_id
end

-- 获取推荐的游戏ID
function M.GetTJGameIDbyJB()
    for i = 5, 1, -1 do -- 6 7 8是boss场
        local v = this.Config.hall_list[i]
        local a = M.CheckCanTJGameBYGlod(v.game_id, M.GetFishCoinAndJingBi())
        if a == 0 then
            return v.game_id
        end
    end

    --[[
    -- 没有推荐的就找一个能进入的 程序自己加的逻辑
    for i = 2, 5 do -- 6 7 8是boss场
        local v = this.Config.hall_list[i]
        local a = M.CheckCanBeginGameIDByGold2(v.game_id, M.GetFishCoinAndJingBi())
        if a == 0 then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing3d_"..v.game_id, is_on_hint=true}, "CheckCondition")
            if not a or b then
                return v.game_id
            end
        end
    end
    --]]

    return this.Config.hall_list[1].game_id
end
-- 获取Enter的游戏ID
function M.GetEnterGameID()
    for i = 5, 1, -1 do -- 6 7 8是boss场
        local v = this.Config.hall_list[i]
        local a = M.CheckCanBeginGameIDByGold2(v.game_id, M.GetFishCoinAndJingBi())
        if a == 0 then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing3d_"..v.game_id, is_on_hint=true}, "CheckCondition")
            if not a or b then
                return v.game_id
            end
        end
    end
    return this.Config.hall_list[1].game_id
end

function M.GetAllFishByGameID(game_id)
    local map = {}
    for k,v in ipairs(this.Config.fish_list) do
        if M.is_show(v, game_id) then
            map[v.prefab] = 1
        end
    end
    return map
end

function M.GetFishInfoByID(_fishID)
    if this.Config.fish_list and this.Config.fish_list[_fishID] then
        -- body
        return this.Config.fish_list[_fishID]
    end
end

function M.GetCurMaxGunIndex()
    return #fish3d_hall_config.game[FishingModel.game_id].gun_rate
end