local basefunc = require "Game.Common.basefunc"
local match_hall_config = SysMatchManager.match_hall_config
local match_game_config = SysMatchManager.match_game_config
local match_game_type_config = SysMatchManager.match_game_type_config
local match_game_award_config = SysMatchManager.match_game_award_config

GameMatchModel = {}
GameMatchModel.last_hbs_type_key = "last_hbs_type_key"
GameMatchModel.MatchType = {
    -- hbs = "hbs",
    -- gms = "gms",
    -- djs = "djs",
    -- jyb = "jyb",
    -- fps = "fps",
    -- qys = "qys",
    -- sws = "sws",
    -- mxb = "mxb",
    -- ges = "ges",
}

GameMatchModel.GameType = {
    -- game_DdzMatch = "game_DdzMatch",
    -- game_DdzMatchNaming = "game_DdzMatchNaming",
    -- game_DdzMillion = "game_DdzMillion",
    -- game_CityMatch = "game_CityMatch",
    -- game_MjXzMatch3D = "game_MjXzMatch3D",
    -- game_MjMatchNaming = "game_MjMatchNaming",
}

local this
local m_data
local lister
local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg, cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister = nil
end
local function MakeLister()
    lister = {}
end

-- 初始化Data
local function InitMatchData()
    GameMatchModel.data = {}
    m_data = GameMatchModel.data
end

function GameMatchModel.Init()
    this = GameMatchModel
    InitMatchData()
    MakeLister()
    AddLister()
    this.InitUIConfig()
    return this
end

function GameMatchModel.Exit()
    if this then
        RemoveLister()
        lister = nil
        this = nil
    end
end

function GameMatchModel.InitUIConfig()
    this.macthUIConfig = {
        hall = {},
        hall_map = {},
        config = {},
        award = {},
        config_type = {},
        award_type = {},
    }

    GameMatchModel.MatchType = {}
    GameMatchModel.GameType = {}
    if match_hall_config.game then
        for i,v in pairs(match_hall_config.game) do
            if v.game_tag and not GameMatchModel.MatchType[v.game_tag] then
                GameMatchModel.MatchType[v.game_tag] = v.game_tag
            end
            if v.game_type then
                if type(v.game_type) == "table" then
                    for k,v1 in pairs(v.game_type) do
                        if not GameMatchModel.GameType[v1] then
                            GameMatchModel.GameType[v1] = v1
                        end
                    end
                else
                    if not GameMatchModel.GameType[v.game_type] then
                        GameMatchModel.GameType[v.game_type] = v.game_type
                    end
                end
            end

            --大厅配置
            this.macthUIConfig.hall[v.id] = this.macthUIConfig.hall[v.id] or {}
            this.macthUIConfig.hall[v.id] = v
            this.macthUIConfig.hall_map[v.game_tag] = this.macthUIConfig.hall_map[v.game_tag] or {}
            this.macthUIConfig.hall_map[v.game_tag] = v
        end
    end

    local get_game_type_value_by_type_id = function(game_tge,type_id)
        if match_game_type_config[game_tge] then
           for i,v in ipairs(match_game_type_config[game_tge]) do
                if type_id == v.type_id then
                    return v
                end
           end    
        end
    end

    local get_game_award_value_by_award_id = function(game_tge,award_id)
        local award = {}
        if match_game_award_config[game_tge] then
           for i,v in ipairs(match_game_award_config[game_tge]) do
                if award_id == v.award_id then
                    table.insert( award,v)
                end
           end    
           return award
        end
    end

    local cfg = {}
    for k1,v1 in pairs(match_game_config) do
        for k2,v2 in pairs(v1) do
            this.macthUIConfig.config[v2.game_id] = this.macthUIConfig.config[v2.game_id] or {}
            this.macthUIConfig.config[v2.game_id] = v2

            this.macthUIConfig.config_type[k1] = this.macthUIConfig.config_type[k1] or {}
            this.macthUIConfig.config_type[k1][v2.game_id] = this.macthUIConfig.config_type[k1][v2.game_id] or {}
            this.macthUIConfig.config_type[k1][v2.game_id] = v2

            if match_game_type_config[k1] then
                cfg = get_game_type_value_by_type_id(k1,v2.type_id)
                if not table_is_null(cfg) then
                    for k3,v3 in pairs(cfg) do
                        if not v2[v3] then
                            -- v2[k3] = v3
                            this.macthUIConfig.config[v2.game_id][k3] = v3
                            this.macthUIConfig.config_type[k1][v2.game_id][k3] = v3
                        end
                    end
                    -- this.macthUIConfig.config_type[k1][v2.game_id].enter_condi_count = 0
                    if cfg.enter_condi_itemkey and cfg.enter_condi_itemkey[#cfg.enter_condi_itemkey] == "jing_bi" and cfg.enter_condi_item_count then
                        if cfg.enter_condi_item_count then
                            if type(cfg.enter_condi_item_count) == "table" then
                                this.macthUIConfig.config_type[k1][v2.game_id].enter_condi_count = cfg.enter_condi_item_count[#cfg.enter_condi_item_count] or 0
                            elseif type(cfg.enter_condi_item_count) == "number" then
                                this.macthUIConfig.config_type[k1][v2.game_id].enter_condi_count = cfg.enter_condi_item_count
                            end
                        end
                    end
                    cfg = {}
                end
            end

            if match_game_award_config[k1] then
                cfg = get_game_award_value_by_award_id(k1,v2.award_id)
                if not table_is_null(cfg) then
                    this.macthUIConfig.award[v2.game_id] = this.macthUIConfig.award[v2.game_id] or {}
                    this.macthUIConfig.award[v2.game_id] = cfg

                    this.macthUIConfig.award_type[k1] = this.macthUIConfig.award_type[k1] or {}
                    this.macthUIConfig.award_type[k1][v2.game_id] = this.macthUIConfig.award_type[k1][v2.game_id] or {}
                    this.macthUIConfig.award_type[k1][v2.game_id] = cfg
                end
            end
        end
    end
    -- for k,v in pairs(this.macthUIConfig) do
    --     dump(v, "<color=yellow>比赛场配置》》》》》》》》》》》》》》》》》》》》</color>" .. k)
    -- end
end

--比赛类型
function GameMatchModel.GetHall()
    return this.macthUIConfig.hall
end

function GameMatchModel.GetHallConfigByGameID(id)
    return this.macthUIConfig.hall[id]
end

function GameMatchModel.SetCurMatchType(id)
    this.data.match_type_id = id
end

function GameMatchModel.GetCurMatchType()
    return this.data.match_type_id
end

function GameMatchModel.GetHallMap()
    return this.macthUIConfig.hall_map
end

function GameMatchModel.GetHallMapConfigByGameTge(tge)
    return this.macthUIConfig.hall_map[tge]
end

function GameMatchModel.SetCurMatchTypeByTge(tge)
    this.data.match_type_tge = tge
end

function GameMatchModel.GetCurMatchTypeByTge()
    return this.data.match_type_tge
end

-- 上次的比赛场游戏类型
function GameMatchModel.GetLastGameType()
    local mr = GLC.match_moren_gametype or "ddz"
    return PlayerPrefs.GetString(GameMatchModel.last_hbs_type_key .. MainModel.UserInfo.user_id, mr)
end

--比赛场
function GameMatchModel.SetCurrGameID(game_id)
    this.data.game_id = game_id
    if this.macthUIConfig.config[game_id] then
        if this.macthUIConfig.config[game_id].game_type == "game_DdzPDKMatch" then
            PlayerPrefs.SetString(GameMatchModel.last_hbs_type_key .. MainModel.UserInfo.user_id, "ddz_pdk_match")
        else
            local gt = MainModel.GetLocalType(this.macthUIConfig.config[game_id].game_type)
            if gt == "mj" then
                PlayerPrefs.SetString(GameMatchModel.last_hbs_type_key .. MainModel.UserInfo.user_id, "mj")
            else
                PlayerPrefs.SetString(GameMatchModel.last_hbs_type_key .. MainModel.UserInfo.user_id, "ddz")
            end
        end
    end
end

function GameMatchModel.GetCurrGameID()
    return this.data.game_id
end

function GameMatchModel.GetConfig()
    return this.macthUIConfig.config
end

function GameMatchModel.GetConfigByType(config_type)
    if not this then return end
    if config_type then
        return this.macthUIConfig.config_type[config_type]
    end
    return this.macthUIConfig.config_type
end

function GameMatchModel.GetGameIDToConfig(game_id)
    game_id = game_id or this.data.game_id 
    if game_id then
        return this.macthUIConfig.config[game_id]
    else
        return this.macthUIConfig.config[2]
    end
end

function GameMatchModel.GetGameIDToAward(game_id)
    game_id = game_id or this.data.game_id 
    if game_id then
        return this.macthUIConfig.award[game_id]
    else
        return this.macthUIConfig.award[2]
    end
end

-- 获取对应排名的奖励
function GameMatchModel.GetAwardByRank(game_id, rank)
    game_id = game_id or this.data.game_id 
    local cfg
    if game_id then
        cfg = this.macthUIConfig.award[game_id]
    else
        cfg = this.macthUIConfig.award[2]
    end
    for k,v in ipairs(cfg) do
        if (v.min_rank == -1 or rank >= v.min_rank) and (v.max_rank == -1 or rank <= v.max_rank) then
            return v.award_desc, v.award_icon
        end
    end
end

function GameMatchModel.GetGameIDToScene(game_id)
    game_id = game_id or this.data.game_id 
    if game_id then
        return GameConfigToSceneCfg[this.macthUIConfig.config[game_id].game_type].ID
    else
        return GameConfigToSceneCfg.game_CityMatch.ID
    end
end

function GameMatchModel.GetGameIDToGameType(game_id)
    game_id = game_id or this.data.game_id 
    if game_id then
        return this.macthUIConfig.config[game_id].game_type
    else
        return "game_DdzMatch"
    end
end

-- 返回比赛消耗满足的道具
function GameMatchModel.GetMatchCanUseTool(itemkey, item_count)
    if not itemkey then
        return
    end
    for k,v in ipairs(itemkey) do
        --if MainModel.UserInfo[v] and item_count[k] <= MainModel.UserInfo[v] then
        if GameItemModel.GetItemTotalCount({v}) >= item_count[math.min(#item_count, k)] then
            return itemkey[k], item_count[k]
        end
    end
end

function GameMatchModel.CheckIsQYSByGameID(game_id)
    for k,v in pairs(this.macthUIConfig.config_type.qys) do
        if v.game_id == game_id then
            return true
        end
    end
    return false
end

function GameMatchModel.CheckIsMXBByGameID(game_id)
    for k,v in pairs(this.macthUIConfig.config_type.mxb) do
        if v.game_id == game_id then
            return true
        end
    end
    return false
end

function GameMatchModel.CheckIsGESByGameID(game_id)
    for k,v in pairs(this.macthUIConfig.config_type.ges) do
        if v.game_id == game_id then
            return true
        end
    end
    return false
end

function GameMatchModel.CheckIsSWSByGameID(game_id)
    if table_is_null(this.macthUIConfig.config_type.sws) then return end
    for k,v in pairs(this.macthUIConfig.config_type.sws) do
        if v.game_id == game_id then
            return true
        end
    end
    return false
end

function GameMatchModel.IsGMS(gameId)
    local ret = false
    for k, v in pairs(this.macthUIConfig.config_type.gms) do
        if v.game_id == gameId then
            ret = true
            break
        end
    end
    return ret
end

-- 根据游戏ID获取游戏类型
function GameMatchModel.GetGameIDByType(gameId)
    if not gameId then
        return GameMatchModel.MatchType.hbs
    else
        for k,v in pairs(this.macthUIConfig.config_type) do
            if v[gameId] then
                return k
            end
        end
        return GameMatchModel.MatchType.hbs
    end
end

-- 是否能报名
function GameMatchModel.CheckIsCanSignup(config)
    if config.enter_condi_count and MainModel.UserInfo.jing_bi >= config.enter_condi_count then
        return true
    end
    local itemKeys = config.enter_condi_itemkey
    local itemCost = config.enter_condi_item_count
    if itemKeys and itemCost and #itemKeys > 0 and #itemKeys <= #itemCost then
        for i = 1, #itemKeys do
            if GameItemModel.GetItemCount(itemKeys[i]) >= itemCost[i] then
                return true
            end
        end
    end
    return false
end

-- 是否能报名
function GameMatchModel.CheckIsCanSignupByTicket(config)
    local itemKeys = config.enter_condi_itemkey
    local itemCost = config.enter_condi_item_count
    if itemKeys and itemCost and #itemKeys > 0 and #itemKeys <= #itemCost then
        for i = 1, #itemKeys do
            if itemKeys[i] ~= "jing_bi" and GameItemModel.GetItemCount(itemKeys[i]) >= itemCost[i] then
                return true
            end
        end
    end
    return false
end

-- 获取最近的千元赛比赛 ID
function GameMatchModel.GetRecentlyGameID()
    local now = os.time()
    local s_i = 10000000
    local e_i = 0
    for k,v in pairs(this.macthUIConfig.config_type[GameMatchModel.MatchType.gms]) do
        if s_i >= v.game_id then
            s_i = v.game_id
        end
        if e_i <= v.game_id then
            e_i = v.game_id
        end
    end
    local v
    for i=s_i,e_i do
        v = this.macthUIConfig.config_type[GameMatchModel.MatchType.gms][i]
        if v then
            if now >= v.start_time and now <= v.over_time then
                return v.game_id
            elseif now < v.start_time then
                return v.game_id
            end
        end
    end
    print("<color=red>EEEEEEEEEEE GameMatchModel  GetRecentlyGameID </color>")
end
-- 千元赛比赛 配置
function GameMatchModel.GetQYSConfigByID(id)
    return this.macthUIConfig.config_type[GameMatchModel.MatchType.gms][id]
end
-- 今天是否有千元赛比赛
function GameMatchModel.IsTodayHaveMatch()
    local id = GameMatchModel.GetRecentlyGameID()
    if id then
        local cur_t = os.time()
        local game_cfg = GameMatchModel.GetQYSConfigByID(id)
        local newtime = tonumber(os.date("%Y%m%d", cur_t))
        local oldtime = tonumber(os.date("%Y%m%d", game_cfg.start_time))
        if newtime == oldtime and cur_t <= game_cfg.over_time then
            return true
        else
            return false
        end
    else
        return false
    end
end

--获取指定类型最近的比赛配置
function GameMatchModel.GetRecentlyCFGByType(t)
    local now = os.time()
    if this.macthUIConfig.config_type[t] then
        local cfg_list = {}
        for i,v in pairs(this.macthUIConfig.config_type[t]) do
            table.insert( cfg_list,v)
        end
        table.sort( cfg_list,function(a, b)
            return a.game_id < b.game_id
        end )
        
        for i,v in ipairs(cfg_list) do
            if now >= v.show_time and now <= v.over_time then
                return v
            elseif now < v.show_time then
                return v
            end
        end
    end
    print("<color=red>EEEEEEEEEEE GameMatchModel  GetRecentlyGameID </color>")
end

--今天是否有指定类型的比赛
function GameMatchModel.IsTodayHaveMatchByType(t)
    local game_cfg = GameMatchModel.GetRecentlyCFGByType(t)
    if game_cfg then
        local cur_t = os.time()
        local newtime = tonumber(os.date("%Y%m%d", cur_t))
        local oldtime = tonumber(os.date("%Y%m%d", game_cfg.start_time))
        if newtime == oldtime and cur_t <= game_cfg.over_time then
            return true
        else
            return false
        end
    else
        return false
    end
end