-- 创建时间:2020-03-23

local basefunc = require "Game/Common/basefunc"
Fishing3DSceneAnim = {}

local M = Fishing3DSceneAnim

local FishNode1
local FishNode2
local pilotID = -1
local time

local lister
local function MakeLister()
    lister = {}

    lister["EnterForeGround"] = M.on_backgroundReturn_msg
    lister["EnterBackGround"] = M.on_background_msg

    lister["fishing_ready_finish"] = M.ReadyFinish
    lister["ui_boss_wave_msg"] = M.on_model_fish_wave
end
local function AddMsgListener()
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end
local function RemoveMsgListener()
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end
function M.GetID()
    pilotID = pilotID - 1
    if pilotID > 0 then
    	pilotID = -1
    end
    return pilotID
end
--游戏前台消息
function M.on_backgroundReturn_msg()
end
--游戏后台消息
function M.on_background_msg()
	M.StopTime()
end
function M.ReadyFinish()
	if time then
		time:Start()
	end
	M.begin_time = os.time()

	for k,v in pairs(M.fish_map) do
        v.fish_base.root_scale = v.fish_base.old_root_scale
		v:MyExit()
	end
	M.fish_map = {}
	M.fish_data_create_log = {}
end
function M.Init(_fishNodeTran, _fishGroupNodeTran)
	FishNode1 = _fishNodeTran
    FishNode2 = _fishGroupNodeTran
    M.InitData()
    MakeLister()
    AddMsgListener()

    time = Timer.New(function ()
        M.FrameUpdate()
    end, 1, -1,false,true)
end
function M.Exit()
    if M then
        RemoveMsgListener()
        M.StopTime()
        time = nil

        Fishing3DSceneAnim = nil
    end
end
function M.StopTime()
	if time then
		time:Stop()
	end
end
function M.InitData()
    M.fish_map = {}
    M.fish_data_map = {}
    M.fish_data_index = {}
    M.fish_data_create_log = {}

    local var = {}
    var.fish_id = -1
    var.fish_type = 47
    var.path = 98
    var.time = 0
    var.speed = 1500
    var.clear_level = 10
    var.rate = 100
    var.local_scale = 2
    var.cd = 10
    var.sc_cd = 10
    var.cur_z_val = 9600

    M.fish_data_map[var.fish_id] = var
    M.fish_data_index[#M.fish_data_index + 1] = var.fish_id

    var = {}
    var.fish_id = -2
    var.fish_type = 47
    var.path = 94
    var.time = 0
    var.speed = 500
    var.clear_level = 10
    var.rate = 100
    var.local_scale = 2
    var.cd = 20
    var.sc_cd = 10
    var.cur_z_val = 9900

    M.fish_data_map[var.fish_id] = var
    M.fish_data_index[#M.fish_data_index + 1] = var.fish_id

    var = {}
    var.fish_id = -3
    var.fish_type = -1
    var.path = 96
    var.time = 0
    var.speed = 300
    var.clear_level = 10
    var.rate = 100
    var.local_scale = 1
    var.cd = 20
    var.sc_cd = 10
    var.cur_z_val = 9900

    M.fish_data_map[var.fish_id] = var
    M.fish_data_index[#M.fish_data_index + 1] = var.fish_id
end

function M.FrameUpdate()
    -- 场景3
    if FishingModel.data and FishingModel.GetSceneID() == 3 and FishingModel.GetBossType() == 0 then
        local cur_t = os.time()
        local beg_t = M.begin_time
        local cha = cur_t - beg_t
        if not M.fish_map[-2] then
            local v = M.fish_data_map[-2]
            local log = M.fish_data_create_log[-2]
            if (not log and (not v.sc_cd or cha > v.sc_cd) ) or (log and cur_t > (log.create_t + v.cd) ) then
                M.CreateFish(v)
            end
        end
    end

    -- 场景4
    if FishingModel.data and FishingModel.GetSceneID() == 4 and FishingModel.GetBossType() == 0 then
        local cur_t = os.time()
        local beg_t = M.begin_time
        local cha = cur_t - beg_t
        if not M.fish_map[-3] then
            local v = M.fish_data_map[-3]
            local log = M.fish_data_create_log[-3]
            if (not log and (not v.sc_cd or cha > v.sc_cd) ) or (log and cur_t > (log.create_t + v.cd) ) then
                M.CreateFish(v)
            end
        end
    end

end
-- 根据ID清除鱼
function M.FishMoveFinish(_fishID)
    if M.fish_map[_fishID] then
    	local data = M.fish_data_map[_fishID]
	    if data.fish_type == 24 then
	    	local shuibo = M.fish_map[_fishID].transform:Find("shuibo")
	    	if IsEquals(shuibo) then
	    		shuibo.gameObject:SetActive(true)
	    	end
	    end
        M.fish_map[_fishID].fish_base.root_scale = M.fish_map[_fishID].fish_base.old_root_scale
        M.fish_map[_fishID]:MyExit()
        M.fish_map[_fishID] = nil
    end
end
function M.CreateFish(data)
	-- 创建领航员
	local id = M.GetID()
	local cfg = FishingModel.Config.steer_map[data.path]
    local m_vPos = {x=cfg.posX, y=cfg.posY}
    local m_vHeading = {x=cfg.headX, y=cfg.headY}
    m_vHeading = Vec2DNormalize(m_vHeading)
    local m_vSide = Vec2DPerp(m_vHeading)

    local pilot = VehicleManager.Create(FishNode2, {ID=id, m_vPos=m_vPos, m_vHeading=m_vHeading, m_vSide=m_vSide})
    for k,v in ipairs(cfg.steer) do
        VehicleManager.AddSteerings(pilot, v)
    end
    local speed
    if data.speed then
        speed = data.speed / 100
    else
        speed = fish_cfg.max_speed or 1
    end
    pilot:SetMaxSpeed(speed)
    pilot:Start()

    local scale = data.local_scale or 1
    local fish = Fish.Create(FishNode2, data)
    fish.fish_base.old_root_scale = fish.fish_base.root_scale
    fish.fish_base.root_scale = scale
    fish.fish_base.cur_z_val = data.cur_z_val or 9600

    if IsEquals(fish.fish_base.fish_yz) then
        fish.fish_base.fish_yz.gameObject:SetActive(false)
    end

    fish:SetFeignDead(true)
    fish.fish_base.anim_pay.speed = 0.4
    VehicleManager.SetInstantiate(id, fish)

    if M.fish_map[data.fish_id] then
        M.fish_map[data.fish_id].fish_base.root_scale = M.fish_map[data.fish_id].fish_base.old_root_scale
    	M.fish_map[data.fish_id]:MyExit()
    end
    M.fish_map[data.fish_id] = fish
    M.fish_data_create_log[data.fish_id] = {create_t = os.time()}
end

function M.on_model_fish_wave()
    if FishingModel.data and FishingModel.GetSceneID() == 3 and FishingModel.GetBossType() ~= 0 then
        M.FishMoveFinish(-2)
        M.CreateFish(M.fish_data_map[M.fish_data_index[1]])
        Event.Brocast("ui_shake_screen_msg", 3.5, 0.3)
        ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bossBchuchang.audio_name)
    end
end

