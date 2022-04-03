-- 创建时间:2020-11-25

local T = SwimManager.Tool
local basefunc = require "Game/Common/basefunc"

SwimVehicle = basefunc.class()
local C = SwimVehicle

local function InitMovingEntity()
	local data = {}
	-- 当前速率
	data.m_vVelocity = {x=1, y=0}
	-- 当前速度
	data.m_vSpeed = 0
	-- 一个标准化向量，指向实体的朝向
	data.m_vHeading = {x=1, y=0}
	-- 垂直于朝向向量的向量
	data.m_vSide = {x=0, y=-1}
	-- 实体的质量
	data.m_dMass = 1
	-- 实体的最大速度
	data.m_dMaxSpeed = 2
	-- 实体的最小速度
	data.m_dMinSpeed = 1
	-- 固定速度 速度固定能有更好的表现效果
	data.m_dGDSpeed = 1
	-- 实体产生的供以自己动力的最大力（想一下火箭和发动机推力）
	data.m_dMaxForce = 1
	-- 交通工具能旋转的最大速率（弧度每秒）
	data.m_dMaxTurnRate = 360

	return data
end

function C.Create(parm)
	return C.New(parm)
end

function C:ctor(parm)
	-- 徘徊 参数
	self.m_dWanderJitter = 12 -- 每秒加到目标的随机位移的最大值 
	self.m_dWanderRadius = 1 -- wander圈的半径
	self.m_vWanderDistance = {x=0, y=0} -- wander圈凸出在智能体前面的距离

	-- 抵达 参数
	self.decelerationTweaker = 0.3

	-- 队列 参数
	self.offset = {x=-0.3, y=0}

	local data = InitMovingEntity()
	for k,v in pairs(data) do
		self[k] = v
	end

	if parm and next(parm) then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
	self.m_vPos = self.m_vPos or {x=T.RandomClamped(), y=T.RandomClamped()}
	self.m_vWanderTarget = {x=self.m_vHeading.x, y=self.m_vHeading.y}

	self.swim_list = {}
	self.velocity_scale = 1
end
function C:AddSwim(swim)
	self.swim_list[#self.swim_list + 1] = swim
end

function C:MaxSpeed()
	if self.m_dGDSpeed > 0 then
		return self.m_dGDSpeed
	else
		return self.m_dMaxSpeed
	end
end
function C:Heading()
	return self.m_vHeading
end
function C:Side()
	return self.m_vSide
end
function C:Pos()
	return self.m_vPos
end
function C:Speed()
	return T.Vec2DLength(self.m_vVelocity)
end
function C:Velocity()
	return self.m_vVelocity
end

function C:FrameUpdate(time_elapsed)
	local ct = time_elapsed
	while (true) do
        if ct >= T.FrameTime then
            self:RunCalc(T.FrameTime)
            ct = ct - T.FrameTime
        else
        	self:RunCalc(ct)
            break
        end
    end
end
function C:RunCalc(time_elapsed)
	-- 计算操控行为的合力
	local swimForce = {x=0, y=0}
	if self.is_Wander then
		swimForce = self:Wander(time_elapsed)
	end
	if self.is_OffsetPursuit then
		swimForce = self:OffsetPursuit(self.leader, self.offset)
	end

	if self.is_wall then
		swimForce = T.Vec2DAdd(swimForce, T.Vec2DMultNum(self:Wall(), 1) )
	end

	if self.is_group then
		-- 集群
		local neighbors = SwimManager.GetNeighbors(self)
		if neighbors and #neighbors > 0 then
			swimForce = T.Vec2DAdd(swimForce, T.Vec2DMultNum(self:Separation(neighbors), 1) )
			swimForce = T.Vec2DAdd(swimForce, T.Vec2DMultNum(self:Alignment(neighbors), 2) )
			swimForce = T.Vec2DAdd(swimForce, T.Vec2DMultNum(self:Cohesion(neighbors), 2) )
		end
	end
	
	if swimForce then
		-- 加速度=力/质量
		local acceleration = T.Vec2DDivNum(swimForce, self.m_dMass)
		-- 更新速度
		self.m_vVelocity = T.Vec2DAdd( self.m_vVelocity , T.Vec2DMultNum(acceleration , time_elapsed) )
		if self.m_dGDSpeed > 0 then
			self.m_vVelocity = T.Vec2DTruncateToLen(self.m_vVelocity, self.m_dGDSpeed)
		else
			-- 确保交通工具不超过最大速度
			self.m_vVelocity = T.Vec2DTruncate(self.m_vVelocity, self.m_dMaxSpeed)
			self.m_vVelocity = T.Vec2DTruncateMin(self.m_vVelocity, self.m_dMinSpeed)
		end
	end
	local vec = T.Vec2DMultNum(self.m_vVelocity, self.velocity_scale)
	--更新位置
	self.m_vPos = T.Vec2DAdd(self.m_vPos, T.Vec2DMultNum(vec , time_elapsed))
	-- 如果速度远大于一个很小值，那么更新朝向
	if (T.Vec2DLength(self.m_vVelocity) > 0.00001) then
		local r1 = T.Vec2DAngle(self.m_vHeading)
		local r2 = T.Vec2DAngle(T.Vec2DNormalize(self.m_vVelocity))
		local d = math.abs(r1-r2)%360
		if d > 180 then
			d = 360-d
		end
		if d > self.m_dMaxTurnRate*time_elapsed then
			self.m_vVelocity = T.Vec2DTruncateToLen(T.Vec2DRotate(self.m_vHeading, self.m_dMaxTurnRate*time_elapsed), T.Vec2DLength(self.m_vVelocity))
		end

		self.m_vHeading = T.Vec2DNormalize(self.m_vVelocity)
		self.m_vSide = T.Vec2DPerp(self.m_vHeading)
	end
end

function C:GetCurRect()
	local r = T.Vec2DAngle(self.m_vHeading)
	return {pos=self.m_vPos, r=r}
end

-- 墙
function C:Wall()
	local p = 2
	local f = 10
	local world = FishFarmModel.WorldDimensionUnit
	local force = {x=0, y=0}
	if self.m_vPos.x < (world.xMin+p) then
		local cha = (world.xMin+p) - self.m_vPos.x
		force = T.Vec2DAdd( force, T.Vec2DMultNum({x=f, y=0}, cha / p) )
	end

	if self.m_vPos.x > (world.xMax-p) then
		local cha = self.m_vPos.x - (world.xMax-p)
		force = T.Vec2DAdd( force, T.Vec2DMultNum({x=-f, y=0}, cha / p) )
	end

	if self.m_vPos.y < (world.yMin+p) then
		local cha = (world.yMin+p) - self.m_vPos.y
		force = T.Vec2DAdd( force, T.Vec2DMultNum({x=0, y=f}, cha / p) )
	end

	if self.m_vPos.y > (world.yMax-p) then
		local cha = self.m_vPos.y - (world.yMax-p)
		force = T.Vec2DAdd( force, T.Vec2DMultNum({x=0, y=-f}, cha / p) )
	end

	return force
end

-- 靠近
function C:Seek(targetPos)
	local desiredVelocity = T.Vec2DNormalize( T.Vec2DSub(targetPos, self:Pos()) )
	desiredVelocity = T.Vec2DMultNum(desiredVelocity, self.m_dMaxSpeed)
	return T.Vec2DSub(desiredVelocity, self.m_vVelocity)
end

-- 抵达
function C:Arrive(targetPos, deceleration)
	local toTarget = T.Vec2DSub(targetPos, self:Pos())
	local dist = T.Vec2DLength(toTarget)
	if dist > 0 then
		local speed =  dist / (deceleration * self.decelerationTweaker)
		speed = math.min(speed, self:MaxSpeed())
		local desiredVelocity = T.Vec2DDivNum(T.Vec2DMultNum(toTarget, speed), dist)
		return T.Vec2DSub(desiredVelocity, self:Velocity())
	end
	return {x=0, y=0}
end

-- 队列
function C:OffsetPursuit(leader, offset)
	local worldOffsetPos = T.PointToWorldSpace(offset, leader:Heading(), leader:Side(), leader:Pos())
	local toOffset = T.Vec2DSub(worldOffsetPos, self:Pos())
	local lookAheadTime = T.Vec2DLength(toOffset) / (self:MaxSpeed() + leader:Speed())
	return self:Arrive(T.Vec2DAdd(worldOffsetPos, T.Vec2DMultNum(leader:Velocity(), lookAheadTime)), 1)
end

-- 徘徊
function C:Wander(time_elapsed)
	if not self.wander_t then
		self.wander_t = 1
	end

	self.wander_t = self.wander_t + time_elapsed

	if self.wander_t > 0 then
		self.wander_t = 0
		local m_dWanderJitter = self.m_dWanderJitter * time_elapsed

		self.m_vWanderTarget = T.Vec2DAdd(self.m_vWanderTarget, {x=T.RandomClamped()*m_dWanderJitter, y=T.RandomClamped()*m_dWanderJitter})
		self.m_vWanderTarget = T.Vec2DNormalize(self.m_vWanderTarget)
		if self.m_dWanderRadius ~= 1 then
			self.m_vWanderTarget = T.Vec2DMultNum(self.m_vWanderTarget, self.m_dWanderRadius)
		end
		local targetLocal = T.Vec2DAdd(self.m_vWanderTarget, self.m_vWanderDistance)
		local targetWorld = T.PointToWorldSpace(targetLocal, self:Heading(), self:Side(), self:Pos())
		return T.Vec2DSub(targetWorld, self:Pos())
	end

end
function C:RandomClamped()
	return {x=T.RandomClamped(), y=T.RandomClamped()}
end

-- 分离
function C:Separation(neighbors)
	if not neighbors or #neighbors == 0 then
		return {x=0, y=0}
	end

	local force = {x=0, y=0}
	for k,v in ipairs(neighbors) do
		local agent = T.Vec2DSub(self:Pos(), v:Pos())
		force = T.Vec2DAdd(force, T.Vec2DDivNum(T.Vec2DNormalize(agent), T.Vec2DLength(agent)) )
	end
	return force
end
-- 队列
function C:Alignment(neighbors)
	if not neighbors or #neighbors == 0 then
		return {x=0, y=0}
	end

	local heading = {x=0, y=0}
	local count = 0
	for k,v in ipairs(neighbors) do
		heading = T.Vec2DAdd(heading, v:Heading())
		count = count + 1
	end
	heading = T.Vec2DDivNum(heading, count)
	heading = T.Vec2DSub(heading, self:Heading())
	return heading
end
-- 聚集
function C:Cohesion(neighbors)
	if not neighbors or #neighbors == 0 then
		return {x=0, y=0}
	end

	local mass = {x=0, y=0}
	local count = 0
	for k,v in ipairs(neighbors) do
		mass = T.Vec2DAdd(mass, v:Pos())
		count = count + 1
	end
	mass = T.Vec2DDivNum(mass, count)
	local force = self:Seek(mass)
	return force
end