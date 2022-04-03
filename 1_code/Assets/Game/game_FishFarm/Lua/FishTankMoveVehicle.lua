-- 创建时间:2020-07-22
-- 鱼缸的鱼游动控制器

require "Game.CommonPrefab.Lua.VehicleSpeed"
require "Game.CommonPrefab.Lua.Vector2D"

local basefunc = require "Game/Common/basefunc"

FishTankMoveVehicle = basefunc.class()
local C = FishTankMoveVehicle

local define_speed = 0.5
function C.Create(parm)
	return C.New(parm)
end

function C:ctor(parm)
	self.isStart = false
	self.isFinish = false
	self.angular = 90--角速度

	self.rate_jd = 30

	self.jd = 100
    self.map = {xMin=-9.8, xMax=9.8, yMin=-5.4, yMax=5.4}
    self.cur_pos = parm.pos

	self.speed_list = {}
	self.speed_list[#self.speed_list + 1] = VehicleSpeed_YS.Create(self, {speed=define_speed})
	self.speed_list[#self.speed_list + 1] = VehicleSpeed_FD.Create(self)
	self.speed_list[#self.speed_list + 1] = self.speed_list[#self.speed_list]
end
function C:MyExit()
	self.isStart = false
end

function C:FrameUpdate(time_elapsed)
	if not self.isStart then
		return
	end

	if self.cha_num < self.rate_jd then
		self.cha_num = self.cha_num + 1
		self.cur_heading = self.old_heading + self.cha_head * self.cha_num * self.cha_len
		self.cur_heading = self.cur_heading.normalized
	end

	if self.cur_time <= 0 then
		self:RunRand()
	end

	if self.cur_time > 0 then
		self.cur_time = self.cur_time - time_elapsed
		if self.cur_time < 0 then
			self.cur_time = 0
		end
		local s = self.speed_list[self.move_mode]:GetSpeed(time_elapsed)
		if s then
			self.cur_speed = s
		end
	
		self.cur_pos = self.cur_pos + self.cur_heading * time_elapsed * self.cur_speed
	end
end

function C:Start()
	self.isStart = true
	self.cur_time = self.cur_time or 0
	self.cur_r = 0
	self.rate_t = 0
	self.cha_num = self.rate_jd
	if not self.cur_heading then
		local x = math.random(1, 100) - 50
		local y = math.random(1, 100) - 50
		self.cur_heading = Vector3.New(x, y, 0)
		self.cur_heading = self.cur_heading.normalized
	end

	if not self.cur_pos then
		local x = (math.random(1, self.jd * (self.map.xMax - self.map.xMin)) + self.jd * self.map.xMin) / self.jd
		local y = (math.random(1, self.jd * (self.map.yMax - self.map.yMin)) + self.jd * self.map.yMin) / self.jd
		self.cur_pos = Vector3.New(x, y, 0)
	end
	self.cur_speed = self.cur_speed or define_speed
end

function C:GetCurRect()
	return {pos=self.cur_pos, r=Vec2DAngle(self.cur_heading)}
end

function C:GetCurPos()
	return self.cur_pos
end
function C:Stop()
	self.isStart = false
end
-- 设置目标点
function C:SetTargetPos(pos)
	self.target_pos = pos

	local head = (self.target_pos - self.cur_pos).normalized
	self.cha_head = head - self.cur_heading
	local len = math.sqrt(self.cha_head.x*self.cha_head.x + self.cha_head.y*self.cha_head.y)
	self.cha_head = self.cha_head.normalized
	self.cha_len = len / self.rate_jd
	self.cha_num = 0
	self.angle = Vec2DAngle2(self.cur_heading, head)
	self.old_heading = self.cur_heading
	self.is_rotate_head = true
end

function C:RunRand()
	if self.next_mode == 3 then
		self:JianS()
	else
		local d = math.random(1, 100)
		if d <= 100 then
			self.move_mode = 1
			local x = (math.random(1, self.jd * (self.map.xMax - self.map.xMin)) + self.jd * self.map.xMin) / self.jd
			local y = (math.random(1, self.jd * (self.map.yMax - self.map.yMin)) + self.jd * self.map.yMin) / self.jd
			local chax = self.cur_pos.x - x
			local chay = self.cur_pos.y - y
			self.cur_time = math.sqrt(chax*chax + chay*chay) / self.cur_speed
			self:SetTargetPos(Vector3.New(x, y, 0))

			self.speed_list[self.move_mode]:SetSpeedParm({speed = self.cur_speed})
		else
			self:JiaS()
		end
	end
end

function C:RandomRate()
	local d = math.random(1, 100)
	if d < 50 then
		self.rate_t = (math.random(0, 180) - 90) / self.angular
		if self.rate_t > 0 then
			self.is_add = true
		else
			self.is_add = false
			self.rate_t = -1 * self.rate_t
		end
	end
end


function C:JiaS()
	self.cur_time = 1
	self.move_mode = 2
	self.next_mode = 3

	local parm = {}
	parm.speed0 = self.cur_speed
	parm.speed1 = self.cur_speed + 3
	parm.time = 1
	parm.curve = 1

	self.speed_list[self.move_mode]:RunCalcWeight(100)
	self.speed_list[self.move_mode]:SetSpeedParm(parm)
end
function C:JianS()
	self.cur_time = 1
	self.move_mode = 2
	self.next_mode = nil

	local parm = {}
	parm.speed0 = self.cur_speed
	parm.speed1 = 1
	parm.time = 1
	parm.curve = 1

	self.speed_list[self.move_mode]:RunCalcWeight(100)
	self.speed_list[self.move_mode]:SetSpeedParm(parm)	
end

