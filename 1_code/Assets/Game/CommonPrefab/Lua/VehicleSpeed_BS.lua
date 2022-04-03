-- 创建时间:2020-04-10
-- 速度控制
-- 带随机的变速

local basefunc = require "Game/Common/basefunc"

VehicleSpeed_BS = basefunc.class()

local C = VehicleSpeed_BS
C.name = "VehicleSpeed_BS"
C.isDebug = false
function C.Create(panelSelf, parm)
	return C.New(panelSelf, parm)
end

function C:ctor(panelSelf, parm)
	self.panelSelf = panelSelf
	-- 随机权重
	self.weight = parm.weight or 100
	self.speed = parm.speed or 1
	self.max_speed = parm.max_speed or 2
	self.time_q = parm.time_q
	self.time_add = parm.time_add
	self.time_cx = parm.time_cx or 0
	self.time_sub = parm.time_sub
	self.time_h = parm.time_h

	self.cha_speed = self.max_speed - self.speed

	-- 变加速
	self.add_a_chg = -(self.max_speed - self.speed) / (self.time_add*self.time_add)
	self.sub_a_chg = -(self.max_speed - self.speed) / (self.time_sub*self.time_sub)
	self.a0 = -2 * self.add_a_chg * self.time_add

	self.state = "nor"
	self.cur_t = 0
	if C.isDebug then
		self.pp = ""
		C.isDebug = false
		self.isDebug = true
	end
end

function C:GetSpeed(time_elapsed)
	if self.state == "nor" then
		local r = math.random(1, 100)
		if r <= self.weight then
			self.state = "run"
			self.cur_t = 0
		end
	else
		self.cur_t = self.cur_t + time_elapsed
	end

	local speed

	if self.cur_t < (self.time_q) then
		speed = self.speed
	elseif self.cur_t < (self.time_q + self.time_add) then
		local t = self.cur_t - self.time_q
		speed = self.speed + self.a0 * t + self.add_a_chg * t * t
	elseif self.cur_t < (self.time_q + self.time_add + self.time_cx) then
		speed = self.max_speed
	elseif self.cur_t < (self.time_q + self.time_add + self.time_cx + self.time_sub) then
		local t = self.cur_t - self.time_q - self.time_add - self.time_cx
		speed = self.max_speed + self.sub_a_chg * t * t
	elseif self.cur_t < (self.time_q + self.time_add + self.time_cx + self.time_sub + self.time_h) then
		speed = self.speed
	else
		if self.isDebug and not self.issho then
			self.issho = true
			print("<color=red>EEEEEEEEEEEEEEEEEEE</color>")	
			dump(Application.dataPath)
		    File.WriteAllText(Application.dataPath .. "/aaaaaa.txt", self.pp)
		    dump(self.pp)
		end

		speed = self.speed
		self.state = "nor"
	end

	-- 调整
	-- if speed < self.speed then
	-- 	speed = self.speed
	-- end
	-- if speed > self.max_speed then
	-- 	speed = self.max_speed
	-- end
	if self.isDebug then
		print(speed)
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


