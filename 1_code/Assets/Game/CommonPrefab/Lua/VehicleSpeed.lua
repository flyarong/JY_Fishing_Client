-- 创建时间:2020-04-10
-- 速度控制
require "Game.CommonPrefab.Lua.VehicleSpeed_YS"
require "Game.CommonPrefab.Lua.VehicleSpeed_BS"
require "Game.CommonPrefab.Lua.VehicleSpeed_FD"

local basefunc = require "Game/Common/basefunc"

VehicleSpeed = basefunc.class()

local C = VehicleSpeed
C.name = "VehicleSpeed"

-- 运动模式
function C.Create(panelSelf, parm)
	local data = {}
	if parm[1] == 1 then
		if #parm == 9 then
			data.type = parm[1]
			data.weight = parm[2]
			data.speed = parm[3]
			data.max_speed = parm[4]
			data.time_q = parm[5]
			data.time_add = parm[6]
			data.time_cx = parm[7]
			data.time_sub = parm[8]
			data.time_h = parm[9]
		else
			dump(parm)
			HintPanel.Create(1, "参数不对")
			return
		end
	else
		dump(parm)
		HintPanel.Create(1, "参数不对")
		return
	end


	return C.New(panelSelf, data)
end

function C:ctor(panelSelf, data)
	self.data = data

	if self.data.type == 1 then
		self.speed_pre = VehicleSpeed_BS.Create(panelSelf, self.data)
	else
		self.speed_pre = VehicleSpeed_YS.Create(panelSelf, self.data)
	end
end

function C:GetSpeed(time_elapsed)
	return self.speed_pre:GetSpeed(time_elapsed)
end

function C:MyExit()
	self.speed_pre:MyExit()
end


