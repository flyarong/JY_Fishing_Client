-- 创建时间:2020-11-11
--[[
prop_fishbowl_stars
  prop_fishbowl_feed
  prop_fishbowl_coin1
  prop_fishbowl_coin2
  prop_fishbowl_fry1
  prop_fishbowl_fry_fragment1
  prop_fishbowl_fish1

  obj_fishbowl_fish={
    fish_id = 1,
    hungry = 15321654, --饥饿目标时间点
    collect = 15321604, --收宝目标时间点
    level = 2, --等级
    jinbi = 2341, --已产出的金币
    stars = 2341, --已产出的星星
--]]
FishFarmManager = {}
local basefunc = require "Game/Common/basefunc"

local config = require "Game.CommonPrefab.Lua.fishbowl_config"
local fish3d_config = HotUpdateConfig("Game.CommonPrefab.Lua.fish3d_config")
local M = FishFarmManager
local this
local lister

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

    lister["fishbowl_info_response"] = M.fishbowl_info_response    
    lister["fishbowl_handbook_response"] = M.fishbowl_handbook_response
    lister["AssetChange"] = this.OnAssetChange
    lister["model_task_change_msg"] = this.on_task_change_msg
    lister["model_query_one_task_data_response"] = this.model_query_one_task_data_response
    lister["fishbowl_handbook_change"] = this.fishbowl_handbook_change

    lister["fishbowl_capture_response"] = M.fishbowl_capture_response
    lister["fishbowl_collect_response"] = M.fishbowl_collect_response
    lister["fishbowl_feed_response"] = M.fishbowl_feed_response
    lister["fishbowl_sale_obj_response"] = M.fishbowl_sale_obj_response
    lister["fishbowl_sale_prop_response"] = M.fishbowl_sale_prop_response
    lister["fishbowl_hatch_response"] = M.fishbowl_hatch_response
    lister["fishbowl_upgrade_response"] = M.fishbowl_upgrade_response
end

function M.Init()
	M.Exit()

	this = FishFarmManager
	this.m_data = {}
    this.m_data.book_task_id = 94
    this.m_data.fishbowl_task_map = {}
    this.m_data.fishbowl_task_map[94] = 1
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

    this.UIConfig.fishbowl_config = config.fishbowl_config

    this.UIConfig.salw_award_map = {}
    for k,v in ipairs(config.sale) do
        this.UIConfig.salw_award_map[v.sale_id] = this.UIConfig.salw_award_map[v.sale_id] or {}
        this.UIConfig.salw_award_map[v.sale_id][#this.UIConfig.salw_award_map[v.sale_id] + 1] = {asset_type=v.asset_type, value=v.asset_count}
    end

    this.UIConfig.feed_award_map = {}
    for k,v in ipairs(config.award) do
        this.UIConfig.feed_award_map[v.award_id] = this.UIConfig.feed_award_map[v.award_id] or {}
        this.UIConfig.feed_award_map[v.award_id][#this.UIConfig.feed_award_map[v.award_id] + 1] = {asset_type=v.asset_type, value=v.asset_count}
    end

    local fish_cfg = basefunc.deepcopy(config.fish)
    for k,v in ipairs(fish_cfg) do
        v.sum_stage = v.stage[#v.stage]
        v.sum_stage_list = {} -- 鱼的阶段数据整理
        for i = 1, #v.stage do
            local d = {}
            v.sum_stage_list[#v.sum_stage_list + 1] = d

            d.stage = v.stage[i]
            d.name = v.stage_name[i] or "nil"
            d.hunger_time = v.hunger_time[i]
            d.harvest_time = v.harvest_time[i]
            d.jb_produce_dec = v.produce_dec[2*i - 1]
            d.xx_produce_dec = v.produce_dec[2*i]
            d.feed_consume = v.feed_consume[i] or 666
            d.sale_award = this.UIConfig.salw_award_map[ v.sale[i] ]
            d.feed_award = this.UIConfig.feed_award_map[ v.award[i] ]
        end
    end
    this.UIConfig.fish_list = fish_cfg


    local list = {}
    local map = {}
    this.UIConfig.fish_type_list = list
    this.UIConfig.fish_type_map = map

    this.UIConfig.fish_map = {}
    for k,v in ipairs(fish_cfg) do
        this.UIConfig.fish_map[v.id] = v
        if not map[v.fish_type] then
            list[#list + 1] = {tag=v.fish_type, list={}}
            map[v.fish_type] = #list
        end
        list[ map[v.fish_type] ].list[ #list[ map[v.fish_type] ].list + 1 ] = v.id
    end

    -- prop
    this.UIConfig.fish_key_map = {}
    for k,v in ipairs(fish_cfg) do
        this.UIConfig.fish_key_map["prop_fishbowl_fry"..v.id] = {level=0, cfg=v}
        this.UIConfig.fish_key_map["prop_fishbowl_fish"..v.id] = {level=v.sum_stage, cfg=v}
        this.UIConfig.fish_key_map["prop_fishbowl_fry_fragment"..v.id] = {level=0, cfg=v}
    end

    this.UIConfig.item_sale_map = {}
    for k,v in ipairs(config.item) do
        this.UIConfig.item_sale_map[v.key] = this.UIConfig.item_sale_map[v.key] or {}
        this.UIConfig.item_sale_map[v.key].award = this.UIConfig.salw_award_map[ v.sale ]
    end

    this.UIConfig.fish3d_config = {}
    for k,v in ipairs(fish3d_config.config) do
        this.UIConfig.fish3d_config[v.id] = v
    end

    -- 图鉴
    this.UIConfig.book_list = {}
    for k,v in ipairs(config.book) do
        this.UIConfig.book_list[#this.UIConfig.book_list + 1] = v
    end

    -- 聊天、表情
    this.UIConfig.face_map = {}
    if config.face then
        for k,v in ipairs(config.face) do
            this.UIConfig.face_map[v.id] = v
        end
    end

    -- 移动
    this.UIConfig.move_map = {}
    if config.move then
        for k,v in ipairs(config.move) do
            this.UIConfig.move_map[v.id] = v
        end
    end

    -- 品类
    this.UIConfig.type_map = {}
    this.UIConfig.type_map[1] = {tag = 1, name="普通鱼"}
    this.UIConfig.type_map[2] = {tag = 2, name="珍惜鱼"}
    this.UIConfig.type_map[3] = {tag = 3, name="彩金鱼"}
    this.UIConfig.type_map[4] = {tag = 4, name="活动鱼"}
    this.UIConfig.type_map[5] = {tag = 5, name="海怪鱼"}
end

function M.OnLoginResponse(result)
	if result == 0 then
        M.InitLocalFishData()
	end
end
function M.OnReConnecteServerSucceed()
    M.InitLocalFishData()
end

function M.InitLocalFishData()
    local list = M.GetFishbowlOfFishList()
    this.m_data.cache_fish_map = {}
    for k,v in ipairs(list) do
        this.m_data.cache_fish_map[v.id] = basefunc.deepcopy(v)
    end
end

function M.IsExistTask(id)
    if this.m_data.fishbowl_task_map[id] then
        return true
    else
        return false
    end
end
function M.on_task_change_msg(data)
    if M.IsExistTask(data.id) then
        Event.Brocast("model_fishbowl_task_data")
    end
end
function M.model_query_one_task_data_response(data)
    if M.IsExistTask(data.id) then
        Event.Brocast("model_fishbowl_task_data")
    end
end
function M.GetBookTaskData()
    return GameTaskModel.GetTaskDataByID(this.m_data.book_task_id)
end
function M.GetBookTaskAwardData()
    local task = M.GetBookTaskData()
    if task then
        local b = basefunc.decode_task_award_status(task.award_get_status)
        b = basefunc.decode_all_task_award_status(b, task, #this.UIConfig.book_list)
        return b
    end
end
function M.GetBookTaskID()
    return this.m_data.book_task_id
end

function M.QueryBookTask(jh)
    if M.GetBookTaskData() then
        Event.Brocast("model_fishbowl_task_data")
    else
        Network.SendRequest("query_one_task_data", {task_id = this.m_data.book_task_id}, jh)
    end
end

-- todo
function M.OnAssetChange(data)
    if data.change_type then
        if basefunc.bit_and(data.tag, 16) > 0 then
            this.m_data.is_book_change = true
            dump(data, "<color=red><size=16> |||||||||| Fishbowl OnAssetChange </size></color>")
            Event.Brocast("model_fishbowl_backpack_change_msg", {change_type=data.change_type, obj_assets_list=data.obj_assets_list})
        end
    end
end
function M.GetObjToolData(obj_id)
    return MainModel.UserInfo.ToolMap[obj_id]
end
-- 水族馆Info数据
function M.QueryFishbowlInfo(jh)
    if this.m_data.fishbowl_info and (os.time() - this.m_data.fishbowl_info_query_time) < 5 then
        Event.Brocast("model_fishbowl_info", {result = 0})
    else
        Network.SendRequest("fishbowl_info", nil, jh)
    end
end
function M.fishbowl_info_response(_, data)
    if data.result == 0 then
        this.m_data.fishbowl_info = data
        this.m_data.fishbowl_info_query_time = os.time()
        Event.Brocast("model_fishbowl_info", {result = 0})
    else
        Event.Brocast("model_fishbowl_info", {result = data.result})
    end
end
function M.GetFishbowlInfo()
    return this.m_data.fishbowl_info
end

-- 图鉴Info数据
function M.fishbowl_handbook_change(_, data)
    dump(data, "<color=red>fishbowl_handbook_change</color>")
    if this.m_data.handbook_info
        and this.m_data.handbook_info.handbook
        and this.m_data.handbook_map
        and not this.m_data.handbook_map[data.id] then
        this.m_data.handbook_info.handbook[#this.m_data.handbook_info.handbook + 1] = data.id
        this.m_data.handbook_map[data.id] = 1
    end
end
function M.QueryHandbooklInfo(jh)
    if this.m_data.handbook_info and not this.m_data.is_book_change then
        Event.Brocast("model_fishbowl_handbook", {result = 0})
    else
        this.m_data.is_book_change = false
        Network.SendRequest("fishbowl_handbook", nil, jh)
    end
end
function M.fishbowl_handbook_response(_, data)
    if data.result == 0 then
        this.m_data.handbook_info = data
        this.m_data.handbook_map = {}
        for k,v in ipairs(data.handbook) do
            this.m_data.handbook_map[v] = 1
        end
        Event.Brocast("model_fishbowl_handbook", {result = 0})
    else
        Event.Brocast("model_fishbowl_handbook", {result = data.result})
    end
end
function M.GetHandbookInfo()
    return this.m_data.handbook_info or {}
end
function M.IsGetHandbookByID(id)
    if this.m_data.handbook_map and this.m_data.handbook_map[id] then
        return true
    end
end

function M.fishbowl_capture_response(_, data)
    dump(data, "<color=red>EEE fishbowl_capture_response </color>")
end
function M.fishbowl_collect_response(_, data)
    dump(data, "<color=red>EEE fishbowl_collect_response </color>")
    Event.Brocast("model_fishbowl_collect_msg", data)
end
function M.fishbowl_feed_response(_, data)
    dump(data, "<color=red>EEE fishbowl_feed_response </color>")
end
function M.fishbowl_sale_obj_response(_, data)
    dump(data, "<color=red>EEE fishbowl_sale_obj_response </color>")
end
function M.fishbowl_sale_prop_response(_, data)
    dump(data, "<color=red>EEE fishbowl_sale_prop_response </color>")
end
function M.fishbowl_hatch_response(_, data)
    dump(data, "<color=red>EEE fishbowl_hatch_response </color>")
end
function M.fishbowl_upgrade_response(_, data)
    dump(data, "<color=red>EEE fishbowl_upgrade_response </color>")
end

function M.GetFishing3DConfig(id)
    local cfg = M.GetFishConfig(id)
    if cfg then
        return this.UIConfig.fish3d_config[cfg.fish_id]
    end
    print("<color=red>鱼不存在</color>")
    dump(cfg)
    dump(this.UIConfig.fish3d_config)
    return this.UIConfig.fish3d_config[1]
end
function M.GetFishConfig(id)
    if not tonumber(id) then
        return this.UIConfig.fish_key_map[id].cfg
    else
        if this.UIConfig.fish_map[id] then
            return this.UIConfig.fish_map[id]
        end
    end
end

function M.GetFishByState(cfg, level)
    for k,v in ipairs(cfg.sum_stage_list) do
        if level <= v.stage then
            return k
        end
    end
    print("<color=red>阶段超出配置范围</color>")
    dump(cfg)
    dump(level)
    return 1
end

local sort_fish_up = function(v1,v2)
    if v1.fish_id > v2.fish_id then
        return true
    elseif v1.fish_id < v2.fish_id then
        return false
    else
        if v1.level > v2.level then
            return true
        elseif v1.level < v2.level then
            return false
        else
            if v1.hungry > v2.hungry then
                return false
            else
                return true
            end            
        end
    end
end
local sort_fish_down = function(v1,v2)
    return not sort_fish_up(v1, v2)
end
-- 鱼缸里养鱼 列表
    -- id = 服务器唯一ID，喂养，出售等需要用到
    -- asset_type = "obj_fishbowl_fish"
    -- fish_id = 1,
    -- hungry = 15321654, --饥饿目标时间点
    -- collect = 15321604, --收宝目标时间点
    -- level = 2, --等级
    -- jinbi = 2341, --已产出的金币
    -- stars = 2341, --已产出的星星
--sort_type : nil不排序 up升序 down降序
function M.GetFishbowlOfFishList(sort_type)
    M.test = false
    if M.test and not M.ia_add then -- 用于测试群鱼的游动效果
        M.ia_add = true
        for i = 1, 20 do
            local dd = {}
            dd.id = "obj_fishbowl_fish" .. math.random(10000000)
            dd.fish_id = 1
            dd.asset_type = "obj_fishbowl_fish"
            dd.hungry = 1606460161
            dd.collect = 1606460161
            dd.level = 1
            MainModel.UserInfo.ToolMap[dd.id] = dd
        end
    end
    local list = {}
    local mm = MainModel.UserInfo.ToolMap
    if mm then
        for k,v in pairs(mm) do
            if v.asset_type == "obj_fishbowl_fish" then
                list[#list + 1] = v
            end
        end
    end
    if sort_type then
        if sort_type == "up" then
            MathExtend.SortListCom(list, sort_fish_up)
        elseif sort_type == "down" then
            MathExtend.SortListCom(list, sort_fish_down)
        else
        end
    end
    return list
end
-- 鱼缸里养鱼 按fish_id分组
function M.GetFishbowlOfFishGroup()
    local group = {}
    local mm = MainModel.UserInfo.ToolMap
    if mm then
        for k,v in pairs(mm) do
            if v.asset_type == "obj_fishbowl_fish" then
                group[v.fish_id] = group[v.fish_id] or {}
                group[v.fish_id][#group[v.fish_id] + 1] = v
            end
        end
    end
    return group
end

-- tag: prop_fishbowl_fry  prop_fishbowl_fry_fragment  prop_fishbowl_fish
function M.GetBagKeyList(tag)
    if tag then
        local ll = {}
        for k,v in ipairs(this.UIConfig.fish_list) do
            ll[#ll + 1] = tag .. v.id
        end
        return ll
    else
        local list = {}
        local d = {"prop_fishbowl_fry", "prop_fishbowl_fry_fragment", "prop_fishbowl_fish"}
        for k,v in ipairs(d) do
            local ll = M.GetBagKeyList(v)
            for k1,v1 in ipairs(ll) do
                list[#list + 1] = v1
            end
        end
        return list
    end
end

function M.GetCurFishbowlFishNum()
    return #M.GetFishbowlOfFishList()
end

-- 水族馆容量上限
function M.GetFishbowlConfigByLevel(level)
    return this.UIConfig.fishbowl_config[level]
end
function M.GetFishbowlMaxCount()
    if this.m_data and this.m_data.fishbowl_info then
        return this.UIConfig.fishbowl_config[this.m_data.fishbowl_info.level].capacity
    else
        return 5
    end
end

function M.GetSaleAwardByFishID(id, level)
    local cfg = this.UIConfig.fish_map[id]
    local state = M.GetFishByState(cfg, level)
    return cfg.sum_stage_list[state].sale_award
end

-- Obj道具售卖价值
function M.GetSaleAwardByObjID(obj_id)
    local d = MainModel.UserInfo.ToolMap[obj_id]
    if d then
        return M.GetSaleAwardByFishID(d.fish_id, d.level)
    else
        return {}
    end
end
-- prop道具售卖价值
function M.GetSaleAwardByItemKey(key)
    local cfg = this.UIConfig.item_sale_map[key]
    if cfg then
        return cfg.award
    else
        return {}
    end
end

-- 获取鱼苗对应Tag的数量与售卖价值
function M.GetItemCountMoneyList(tag)
    if tag then
        local dd = {count = 0, award = {}}
        local i = this.UIConfig.fish_type_map[tag]
        local list = this.UIConfig.fish_type_list[i].list
        for k,v in ipairs(list) do
            local key = "prop_fishbowl_fry" .. v
            local count = GameItemModel.GetItemCount(key)
            if count > 0 then
                dd.count = dd.count + count

                local a = M.GetSaleAwardByItemKey(key)
                for kk,vv in ipairs(a) do
                    dd.award[vv.asset_type] = dd.award[vv.asset_type] or 0
                    dd.award[vv.asset_type] = dd.award[vv.asset_type] + count * vv.value
                end
            end
        end
        return dd
    else
        local list = {}
        for k,v in ipairs(this.UIConfig.fish_type_list) do
            list[#list + 1] = M.GetItemCountMoneyList(v.tag)
        end
        return list
    end
end

function M.GetFishTypeList()
    return this.UIConfig.fish_type_list
end

function M.GetMaxLevelFishBowl()
    return   #config.fishbowl_config or 10
end

function M.GetBookConfig()
    return this.UIConfig.book_list
end

function M.GetFaceConfigByID(id)
    return this.UIConfig.face_map[id]
end
function M.GetMoveConfigByID(id)
    return this.UIConfig.move_map[id]
end

function M.GetPLConfig(tag)
    return this.UIConfig.type_map[tag]
end
