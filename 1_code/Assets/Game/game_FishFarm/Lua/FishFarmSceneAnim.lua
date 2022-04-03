-- 创建时间:2020-12-08

FishFarmSceneAnim = {}

local lister
local m_data
local function MakeLister()
    lister = {}

    lister["EnterForeGround"] = M.on_backgroundReturn_msg
    lister["EnterBackGround"] = M.on_background_msg
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

--游戏前台消息
function M.on_backgroundReturn_msg()
end
--游戏后台消息
function M.on_background_msg()
end
function M.Init(_fishNodeTran)
	M.data = {}
	m_data = M.data
    M.InitData()
    MakeLister()
    AddMsgListener()

	m_data.FishNode = _fishNodeTran
    m_data.time = Timer.New(function ()
        M.FrameUpdate()
    end, 1, -1,false,true)
end
function M.Exit()
    if M then
        RemoveMsgListener()
        M.StopTime()
        time = nil

        FishFarmSceneAnim = nil
    end
end

function M.InitData()

end
function M.StopTime()
	if m_data.time then
		m_data.time:Stop()
		m_data.time = nil
	end
end

function M.FrameUpdate(time_elapsed)
	for k,v in pairs(m_data.fish_map) do
		v.fish:FrameUpdate(time_elapsed)
	end
end

function M.AddFish(data)
	local fish
	local swim
	local cfg = M.GetFishConfig(data.fish_id)

	local pos = SwimManager.GetRandomPos()
	if cfg.move_id and M.GetMoveConfigByID(cfg.move_id) then
		local move_cfg = M.GetMoveConfigByID(cfg.move_id)
		local parm = SwimManager.GetSwimParm(move_cfg, cfg)
		pos = parm.pos or pos
		if move_cfg.style == "queue" then
			swim = SwimManager.CreateSwimVehicle({key=data.id, pos=pos, move_style="queue", queue_key=parm.key})
			fish = FishFarm3DBase.Create( self.FishNodeTran, self.fishui_node, {obj_id=data.id, id=data.fish_id, is_add=is_add, pos=pos})
		else
			swim = SwimManager.CreateSwimVehicle({key=data.id, pos=pos, move_style="group", group_key=parm.key})
			fish = FishFarm3DBase.Create( self.FishNodeTran, self.fishui_node, {obj_id=data.id, id=data.fish_id, is_add=is_add, pos=pos})
		end
	else
		swim = SwimManager.CreateSwimVehicle({key=data.id, pos=pos})
		fish = FishFarm3DBase.Create( self.FishNodeTran, self.fishui_node, {obj_id=data.id, id=data.fish_id, is_add=is_add, pos=pos})
	end

	fish:SetVehicle(swim)
	self.fish_map[data.id] = {fish = fish}
end

