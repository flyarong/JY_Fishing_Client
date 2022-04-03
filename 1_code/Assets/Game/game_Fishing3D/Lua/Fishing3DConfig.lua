-- 创建时间:2020-02-10
-- 捕鱼配置初始化
local basefunc = require "Game/Common/basefunc"

local fish_config = HotUpdateConfig("Game.CommonPrefab.Lua.fish3d_config")
local fish_use_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_use_config")
local fish_cache_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_cache_config")
local fish_path_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_path_config")
local fish3d_gunfashion_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_gunfashion_config")
local fish3d_gun_barrel_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_gun_barrel_config")
local fish3d_gun_bed_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_gun_bed_config")
local fish_attr_config = HotUpdateConfig("Game.CommonPrefab.Lua.fish_attr_config")
local fish_shaixuan = HotUpdateConfig("Game.CommonPrefab.Lua.fish_shaixuan")
local fish_face_config = HotUpdateConfig("Game.CommonPrefab.Lua.fish_face_config")


Fishing3DConfig = {}

local Config = {}

local function parse_path(iid)
    local data = {}
    data.type = 1
    local buf = Config.path_map[iid]
    if not buf then
        print("<color=red>路径 path id 为空=" .. iid .. "</color>")
        return
    end
    for k,v in pairs(buf) do
        if k == "WayPoints" then
            data.WayPoints = {}
            local strs = StringHelper.Split(v, "#")
            local ii = 1
            for i=1, #strs, 2 do
                local x = tonumber(strs[i])
                local y = tonumber(strs[i+1])
                local pos = {x=x, y=y}
                if buf.WayPoints_Z then
                    pos.z = buf.WayPoints_Z[ii]
                end
                ii = ii + 1
                data.WayPoints[#data.WayPoints + 1] = pos
            end
        else
            data[k] = v
        end
    end
    return data
end
local function parse_circle(iid)
    local data = {}
    data.type = 2
    local buf = Config.circle_map[iid]
    if not buf then
        print("<color=red>路径 circle id 为空=" .. iid .. "</color>")
        return
    end
    for k,v in pairs(buf) do
        if k == "isPerp" then
            if v == 1 then
                data[k] = true
            else
                data[k] = false
            end
        else
            data[k] = v
        end
    end
    return data
end
local function parse_wait(iid)
    local data = {}
    data.type = 3
    local buf = Config.wait_map[iid]
    if not buf then
        print("<color=red>路径 wait id 为空=" .. iid .. "</color>")
        return
    end
    for k,v in pairs(buf) do
        data[k] = v
    end
    return data
end
function Fishing3DConfig.InitUIConfig()
    Config = {}
    
    Config.fish_hall_list = GameFishing3DManager.Config.hall_list
    Config.fish_hall_map = GameFishing3DManager.Config.hall_map

    -- 鱼
    Config.fish_list = {}
    for k,v in ipairs(fish_config.config) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.cond_key, is_on_hint = true}, "CheckCondition")
        if not a or b then
            Config.fish_list[#Config.fish_list + 1] = v
        end
    end
    Config.fish_map = {}
    for k,v in ipairs(fish_config.config) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.cond_key, is_on_hint = true}, "CheckCondition")
        if not a or b then
            Config.fish_map[v.id] = v
        end
    end
    Config.use_fish_map = {}
    for k,v in ipairs(fish_use_config.use_fish) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.cond_key, is_on_hint = true}, "CheckCondition")
        if not a or b then
            Config.use_fish_map[v.id] = v
        end
    end

    -- 新加一个鳄鱼，专门用于在下水道游泳 100
    Config.use_fish_map[-1] = {id=-1,fish_id=-1}
    local new_fish = {}
    for k,v in pairs(Config.fish_map[48]) do
        new_fish[k] = v
    end
    new_fish.id = -1
    new_fish.prefab = "Fish3D059_Nor"
    Config.fish_map[-1] = new_fish
    Config.fish_list[#Config.fish_list + 1] = new_fish

     --鱼表情
    Config.fish_face_map = {}
    for k,v in ipairs(fish_face_config.config) do
        Config.fish_face_map[v.id] = v
    end

    -- 缓存
    Config.fish_cache_list = {}
    for k,v in ipairs(fish_cache_config.config) do
        if v.isOnOff == 1 then
            Config.fish_cache_list[#Config.fish_cache_list + 1] = v
        end
    end

    -- 鱼属性
    Config.fish_attr_list = {}
    for k,v in ipairs(fish_attr_config.config) do
        Config.fish_attr_list[#Config.fish_list + 1] = v
    end
    Config.fish_attr_map = {}
    for k,v in ipairs(fish_attr_config.config) do
        Config.fish_attr_map[v.id] = v
    end

    -- 筛选规则
    Config.fish_shaixuan_map = {}
    for k,v in ipairs(fish_shaixuan.Sheet1) do
        Config.fish_shaixuan_map[v.type] = v
        v.multi_list = {}
        for i = 1, #v.multi, 2 do
            local buf = {}
            buf.min = v.multi[i]
            buf.max = v.multi[i+1]
            buf.num = v.num[(i+1)/2]
            v.multi_list[#v.multi_list + 1] = buf
        end
    end

-- 鱼的轨迹
    Config.path_map = {}
    Config.circle_map = {}
    Config.wait_map = {}
    for k,v in ipairs(fish_path_config.path) do
        Config.path_map[v.id] = v
    end
    for k,v in ipairs(fish_path_config.circle) do
        Config.circle_map[v.id] = v
    end
    for k,v in ipairs(fish_path_config.wait) do
        Config.wait_map[v.id] = v
    end

    local path = {}
    for k,v in ipairs(fish_path_config.config) do
        local buf = {}
        path[v.id] = buf
        buf.id = v.id
        buf.posX = v.posX
        buf.posY = v.posY
        buf.headX = v.headX
        buf.headY = v.headY
        
        buf.steer = {}
        local strs = StringHelper.Split(v.steer, "#")
        for k1,v1 in ipairs(strs) do
            local str2 = StringHelper.Split(v1, "+")
            local stelist = {}
            buf.steer[#buf.steer + 1] = stelist
            for i=1, #str2, 2 do
                local type = tonumber(str2[i])
                local iid = tonumber(str2[i+1])
                if type == 1 then
                    stelist[#stelist + 1] = parse_path(iid)
                    if not buf.posX then
                        buf.posX = stelist[#stelist].WayPoints[1].x
                        buf.posY = stelist[#stelist].WayPoints[1].y
                        local vv = Vec2DSub(stelist[#stelist].WayPoints[2], stelist[#stelist].WayPoints[1])
                        local vv1 = Vec2DNormalize(vv)
                        buf.headX = vv1.x
                        buf.headY = vv1.y
                    end
                elseif type == 2 then
                    stelist[#stelist + 1] = parse_circle(iid)
                elseif type == 3 then
                    stelist[#stelist + 1] = parse_wait(iid)
                else
                    print("类型不存在 type = " .. type)
                end
            end
        end
    end
    Config.steer_map = path


    -- 鱼的动作配置
    Config.fish_anim_map = {}
    Config.fish_anim_map[33] = {zhu_swim = {"swim"}, gl=30, fu_swim=true}
    Config.fish_anim_map[20] = {zhu_swim = {"swim"}, gl=30, fu_swim=true}
    Config.fish_anim_map[22] = {zhu_swim = {"swim"}, gl=30, fu_swim=true}
    Config.fish_anim_map[37] = {zhu_swim = {"swim"}, gl=30, fu_swim=true}
    Config.fish_anim_map[18] = {zhu_swim = {"swim"}, gl=30, fu_swim=true}
    Config.fish_anim_map[48] = {zhu_swim = {"swim"}, gl=30, fu_swim=true}
    

    -- 鱼枪
    Config.fish_gun_map = {}
    local hall_cfg = GameFishing3DManager.GetHallCfg()
    for k,v in ipairs(hall_cfg) do
        Config.fish_gun_map[v.game_id] = {}
        for i = 1, #v.gun_rate do
            Config.fish_gun_map[v.game_id][i] = {gun_rate=v.gun_rate[i]}
        end
    end

    -- 鱼枪皮肤
    Config.gun_style_map = {}
    -- 鱼枪对应技能(技能不同，每个等级的能量也可能不同)
    Config.gun_skill_map = {}
    -- 鱼枪对应能量(技能不同，每个等级的能量也可能不同)
    Config.gun_power_map = {}
    for k,v in ipairs(fish3d_gun_barrel_config.main) do

        for ii = 1, 4 do
            Config.gun_style_map[ii] = Config.gun_style_map[ii] or {}
            Config.gun_style_map[ii][v.id] = Config.gun_style_map[ii][v.id] or {}
            for k1,v1 in ipairs(fish3d_gun_barrel_config.skin) do
                if v1.skin_id == v.skin_id then
                    for i=v1.gun_index[1], v1.gun_index[2] do
                        Config.gun_style_map[ii][v.id][i] = basefunc.deepcopy(v1)
                    end
                end
            end
        end

        Config.gun_skill_map[v.skin_id] = Config.gun_skill_map[v.skin_id] or {}
        for k1,v1 in ipairs(fish3d_gun_barrel_config.skill) do
            if v1.id == v.skill_id then
                Config.gun_skill_map[v.skin_id] = v1
                break
            end
        end

        Config.gun_power_map[v.skin_id] = Config.gun_power_map[v.skin_id] or {}
        for k1,v1 in ipairs(fish3d_gun_barrel_config.power) do
            if v1.id == v.power_id then
                Config.gun_power_map[v.skin_id][v1.gun_rate] = v1
            end
        end
    end

    -- 鱼枪基座皮肤
    Config.gun_bed_style_map = {}
    for k,v in ipairs(fish3d_gun_bed_config.main) do
        Config.gun_bed_style_map[v.id] = Config.gun_bed_style_map[v.id] or {}

        for k1,v1 in ipairs(fish3d_gun_bed_config.skin) do
            if v1.skin_id == v.skin_id then
                Config.gun_bed_style_map[v.id].gunprefab = v1.gunprefab
            end
        end

    end

    Config.skill_money = {}
    Config.skill_money[#Config.skill_money + 1] = {prop_3d_fish_frozen=500, prop_3d_fish_lock=500, prop_3d_fish_summon_fish=10000, 
                                                    prop_3d_fish_accelerate=10000, prop_3d_fish_wild=10000, prop_3d_fish_doubled=10000}
    Config.skill_money[#Config.skill_money + 1] = {prop_3d_fish_frozen=500, prop_3d_fish_lock=500, prop_3d_fish_summon_fish=10000, 
                                                    prop_3d_fish_accelerate=10000, prop_3d_fish_wild=10000, prop_3d_fish_doubled=10000}
    Config.skill_money[#Config.skill_money + 1] = {prop_3d_fish_frozen=500, prop_3d_fish_lock=500, prop_3d_fish_summon_fish=10000, 
                                                    prop_3d_fish_accelerate=10000, prop_3d_fish_wild=10000, prop_3d_fish_doubled=10000}
    Config.skill_money[#Config.skill_money + 1] = {prop_3d_fish_frozen=500, prop_3d_fish_lock=500, prop_3d_fish_summon_fish=10000, 
                                                    prop_3d_fish_accelerate=10000, prop_3d_fish_wild=10000, prop_3d_fish_doubled=10000}
    Config.skill_money[#Config.skill_money + 1] = {prop_3d_fish_frozen=500, prop_3d_fish_lock=500, prop_3d_fish_summon_fish=10000, 
                                                    prop_3d_fish_accelerate=10000, prop_3d_fish_wild=10000, prop_3d_fish_doubled=10000}

    return Config
end

local fish_cache_configs = {}
function Fishing3DConfig.ReloadFishCacheConfig(gameid)
	print("----------------------------- ReloadFishCacheConfig:" .. gameid)

	--目前只针对苹果做优化
	if gameRuntimePlatform ~= "Ios" then return end

	gameid = gameid or 0
	
	local key = "fish3d_cache_config_scene" .. gameid
	if not fish_cache_configs[key] then
		fish_cache_configs[key] = HotUpdateConfig("Game.game_Fishing3D.Lua." .. key)
	end

	local config = fish_cache_configs[key].config or fish_cache_config.config
	if not config then return end

	print("select cache key:" .. key)

	Config.fish_cache_list = {}
	for k,v in ipairs(config) do
		if v.isOnOff == 1 then
		    Config.fish_cache_list[#Config.fish_cache_list + 1] = v
		end
	end
	FishingModel.Config.fish_cache_list = Config.fish_cache_list
end
