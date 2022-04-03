-- 创建时间:2020-11-25
--[[
智能体游动管理

--]]
SwimManager = {}
local M = SwimManager
M.swim_map = {}
M.swim_queue_map = {}

M.Tool = ext_require("Game.game_FishFarm.Lua.SVector2DTool")
ext_require("Game.game_FishFarm.Lua.SwimVehicle")


function M.Init()
	M.swim_map = {}
end

function M.Exit()
	M.swim_map = {}
end

function M.FrameUpdate(time_elapsed)
	for k,v in pairs(M.swim_map) do
		if not v.is_stop then
			v.swim:FrameUpdate(time_elapsed)
		end
	end
	for k,v in pairs(M.swim_queue_map) do
		for kk,vv in ipairs(v) do
			if not vv.is_stop then
				vv.swim:FrameUpdate(time_elapsed)
			end
		end
	end
end

-- 随机一个位置
function M.GetRandomPos(pos)
	if pos then
		local x = math.random()
		local y = math.random()		
		x = pos.x + 2*x - 1
		y = pos.y + 2*y - 1
		return Vector3.New(x, y, 0)
	else
		local x = math.random()
		local y = math.random()
		local world = FishFarmModel.WorldDimensionUnit
		x = (world.xMax-world.xMin)*x + world.xMin
		y = (world.yMax-world.yMin)*y + world.yMin
		return Vector3.New(x, y, 0)
	end
end

-- 
function M.GetSwimParm(move_cfg, config)
	local pos
	local move_key
	local ll = {}
	local kk
	if move_cfg.style == "queue" then
		kk = "fish_queue_"..config.fish_id.."_"
		for k,v in pairs(M.swim_queue_map) do
			if string.find(k, kk) then
				local id = tonumber( string.sub(k, string.len(kk)+1) )
				ll[#ll + 1] = {id=id, num=#v, pos=v[#v].swim:Pos()}
			end
		end
	else
		kk = "fish_group_"..config.fish_id.."_"
		local mm = {}
		for k,v in pairs(M.swim_map) do
			if v.swim_tag and string.find(v.swim_tag, kk) then
				local id = tonumber( string.sub(v.swim_tag, string.len(kk)+1) )
				if mm[id] then
					ll[mm[id]].num = ll[mm[id]].num + 1
				else
					ll[#ll + 1] = {id=id, num=1, pos=v.swim:Pos()}
					mm[id] = #ll
				end
			end
		end
	end
	dump(ll, "<color=red>11111111111111111111</color>")
	if #ll > 0 then
		MathExtend.SortListCom(ll, function (v1, v2)
			if v1.id < v2.id then
				return false
			else
				return true
			end
		end)
		local ii = 1
		pos = M.GetRandomPos()
		for k,v in ipairs(ll) do
			if v.num < move_cfg.max_num then
				ii = v.id
				pos = M.GetRandomPos( v.pos )
				break
			else
				if ii == v.id then
					ii = ii + 1
				end
			end
		end
		move_key=kk..ii
	else
		pos = M.GetRandomPos()
		move_key=kk..1
	end
	return {key=move_key, pos=pos}
end

-- 创建游动控制
-- move_style:queue队列 group群 
function M.CreateSwimVehicle(data)
	local parm = {swim_key = data.key, is_wall=true, is_Wander = true, m_vPos=data.pos, m_dMass=data.mass}
	if data.move_style then
		if data.move_style == "queue" then
			local queue_key = data.queue_key
			local swimVehicle
			if M.swim_queue_map[queue_key] then
				parm.is_OffsetPursuit = true
				parm.is_Wander = false
				parm.leader=M.swim_queue_map[queue_key][#M.swim_queue_map[queue_key]].swim
				swimVehicle = SwimVehicle.Create(parm)
				M.swim_queue_map[queue_key][#M.swim_queue_map[queue_key] + 1] = {swim_key = data.key, swim=swimVehicle, is_stop=false}
			else
				M.swim_queue_map[queue_key] = {}
				swimVehicle = SwimVehicle.Create(parm)
				M.swim_queue_map[queue_key][#M.swim_queue_map[queue_key] + 1] = {swim_key = data.key, swim=swimVehicle, is_stop=false}
			end
			return swimVehicle
		elseif data.move_style == "group" then
			parm.swim_tag = data.group_key
			parm.is_group = true
			local swimVehicle = SwimVehicle.Create(parm)
			M.AddSwim(swimVehicle, data.key, parm.swim_tag)
			return swimVehicle
		end
	else
		local swimVehicle = SwimVehicle.Create(parm)
		M.AddSwim(swimVehicle, data.key)
		return swimVehicle
	end
end

function M.AddSwim(swim, key, swim_tag)
	M.swim_map[key] = {swim=swim, is_stop=false, swim_tag=swim_tag, swim_key=key}
end
function M.DelSwim(key)
	if M.swim_map[key] then
		M.swim_map[key] = nil
	else
		for k,v in pairs(M.swim_queue_map) do
			for kk,vv in ipairs(v) do
				if key == vv.swim_key then
					table.remove(v, kk)
					-- 更新队列成员的leader
					if #v > 0 then
						for kkk,vvv in ipairs(v) do
							if kkk == 1 then
								vvv.swim.is_Wander = true
								vvv.swim.is_OffsetPursuit = false
								vvv.swim.leader = nil
							else
								vvv.swim.is_Wander = false
								vvv.swim.is_OffsetPursuit = true
								vvv.swim.leader = v[kkk-1].swim
							end
						end
					else
						M.swim_queue_map[k] = nil
					end
					break
				end
			end
		end
	end
end
function M.DelAllSwim()
	M.swim_map = {}
	M.swim_queue_map = {}
end

-- 设置停止状态
function M.SetStopSwim(key, is_stop)
	if key then
		if M.swim_map[key] then
			M.swim_map[key].is_stop = is_stop
		end
	else
		for k,v in pairs(M.swim_map) do
			v.is_stop = is_stop
		end
	end
end


-- 聚集function
function M.GetNeighbors(veh)
	local list = {}
	for k,v in pairs(M.swim_map) do
		if v.swim_key ~= veh.swim_key
			and v.swim_tag == veh.swim_tag
			then--and M.Tool.Vec2DDistanceSq( M.Tool.Vec2DSub(v.swim:Pos(), veh:Pos()) ) < 16 then
			list[#list + 1] = v.swim
		end
	end
	return list
end

