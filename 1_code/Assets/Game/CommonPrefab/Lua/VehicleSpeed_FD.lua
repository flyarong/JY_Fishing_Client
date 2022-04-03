-- 创建时间:2020-04-10
-- 速度控制
-- 分段变速控制

local basefunc = require "Game/Common/basefunc"

VehicleSpeed_FD = basefunc.class()

local C = VehicleSpeed_FD
C.name = "VehicleSpeed_FD"
C.isDebug = false
function C.Create(panelSelf)
	return C.New(panelSelf)
end

function C:ctor(panelSelf)
	self.panelSelf = panelSelf
	self.state = "nor"
	self.cur_t = 0

	if C.isDebug then
		self.pp = ""
		C.isDebug = false
		self.isDebug = true
	end
end
function C:SetSpeedParm(parm)
	if self.state == "nor" then
		return
	end
	self.curve = parm.curve or 1
	self.v0 = parm.speed0 or 1
	self.vm = parm.speed1 or 2
	self.time = parm.time

	-- 变加速
	if self.curve == 1 then -- 先快后慢
		self.a = (self.v0 - self.vm) / (self.time*self.time)
		self.b = -2 * self.a * self.time
	else -- 先慢后快
		self.a = (self.vm - self.v0) / (self.time*self.time)
		self.b = 0
	end
	self.cur_t = 0
	self.issho = false
end
function C:RunCalcWeight(weight)
	local r = math.random(1, 100)
	if r <= weight then
		self.state = "run"
		self.cur_t = 0
	end
end

function C:GetSpeed(time_elapsed)
	if self.state == "nor" then
		return
	else
		self.cur_t = self.cur_t + time_elapsed
	end

	local speed

	if self.cur_t < self.time then
		local t = self.cur_t
		speed = self.v0 + self.b * t + self.a * t * t
	else
		if self.isDebug and not self.issho then
			self.issho = true
			print("<color=red>EEEEEEEEEEEEEEEEEEE</color>")	
			dump(Application.dataPath)
		    dump(self.pp)
		end

		speed = self.vm
	end
	
	if self.isDebug then
		local nn = math.floor(speed*30)
		local tt = ""
		for i =1, nn do
			tt = tt .. "."
		end
		tt = tt .. speed
		self.pp = self.pp .. "\n" .. tt
	end

	return speed
end

function C:MyExit()
end


