-- 创建时间:2020-04-10
-- 速度控制
-- 匀速

local basefunc = require "Game/Common/basefunc"

VehicleSpeed_YS = basefunc.class()

local C = VehicleSpeed_YS
C.name = "VehicleSpeed_YS"

-- 运动模式
function C.Create(panelSelf, parm)
	return C.New(panelSelf, parm)
end

function C:ctor(panelSelf, parm)
	self.parm = parm
	self.panelSelf = panelSelf
	self.speed = self.parm.speed or 1
end

function C:GetSpeed(time_elapsed)
	return self.speed
end
function C:SetSpeedParm(parm)
	self.speed = parm.speed
end
function C:MyExit()
	
end


