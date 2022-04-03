-- 创建时间:2019-03-06

local SVector2DTool = {}

SVector2DTool.FrameTime = 0.033
SVector2DTool.Rad2Deg = 180 / math.pi
-- 转化为单位向量
function SVector2DTool.Vec2DNormalize(vec)
	local len = SVector2DTool.Vec2DLength(vec)
	if len > 0 then
		return {x=vec.x/len, y=vec.y/len}
	else
		return {x=0, y=0}
	end
end

-- 向量长度
function SVector2DTool.Vec2DLength(vec)
	return math.sqrt( SVector2DTool.Vec2DDistanceSq(vec) )
end
-- 长度的平方
function SVector2DTool.Vec2DDistanceSq(vec)
	return (vec.x*vec.x + vec.y*vec.y)
end
-- 向量夹角角度
function SVector2DTool.Vec2DAngle2(vec1, vec2)
	local a = SVector2DTool.Vec2DDotMult(vec1, vec2)
	local b = SVector2DTool.Vec2DLength(vec1) * SVector2DTool.Vec2DLength(vec2)
	local r = math.acos( a/b ) * (180 / math.pi)
	return r
end

-- 向量角度
function SVector2DTool.Vec2DAngle(vec)
	local r = math.acos( SVector2DTool.Vec2DDotMult(vec, {x=1,y=0}), SVector2DTool.Vec2DLength(vec) ) * (180 / math.pi)
	if vec.y < 0 then
		r = 360 - r
	end
	return r
end

-- 向量X积
-- ()
function SVector2DTool.Vec3DXMult(vec1, vec2)
	local x = vec1.y*vec2.z - vec1.z*vec2.y
	local y = vec1.z*vec2.x - vec1.x*vec2.z
	local z = vec1.x*vec2.y - vec1.y*vec2.x
	return {x=x,y=y,z=z}
end

-- 向量减法
function SVector2DTool.Vec2DSub(vec1, vec2)
	return {x=vec1.x-vec2.x, y=vec1.y-vec2.y}
end

-- 向量加法
function SVector2DTool.Vec2DAdd(vec1, vec2)
	return {x=vec1.x+vec2.x, y=vec1.y+vec2.y}
end

-- 向量点积
-- (返回第二个向量在第一个向量上的投影，向量可交换)
function SVector2DTool.Vec2DDotMult(vec1, vec2)
	return vec1.x*vec2.x + vec1.y*vec2.y
end

-- 向量除标量
function SVector2DTool.Vec2DDivNum(vec, num)
	if num == 0 then
		return {x=vec.x, y=vec.y}
	end
	return {x=vec.x/num, y=vec.y/num}
end

-- 向量乘标量
function SVector2DTool.Vec2DMultNum(vec, num)
	return {x=vec.x*num, y=vec.y*num}
end
-- 将向量的长度限制一个最大值
function SVector2DTool.Vec2DTruncate(vec, num)
	local len = SVector2DTool.Vec2DLength(vec)
	if len > num then
		return {x=vec.x * num / len, y=vec.y * num / len}
	else
		return {x=vec.x, y=vec.y}
	end
end
-- 将向量的长度限制一个最小值
function SVector2DTool.Vec2DTruncateMin(vec, num)
	local len = SVector2DTool.Vec2DLength(vec)
	if len < num then
		return {x=vec.x * num / len, y=vec.y * num / len}
	else
		return {x=vec.x, y=vec.y}
	end
end

function SVector2DTool.Vec2DTruncateToLen(vec, len)
	local len1 = SVector2DTool.Vec2DLength(vec)
	if len1 > 0 then
		return {x=vec.x * len / len1, y=vec.y * len / len1}
	else
		return {x=vec.x, y=vec.y}
	end
end

function SVector2DTool.Vec2DPerp(vec)
	local cosB = 0
	local sinB = -1
	local x1 = vec.x * cosB - vec.y * sinB
	local y1 = vec.x * sinB + vec.y * cosB
	return {x=x1, y=y1}
end
function SVector2DTool.Vec2DReversePerp(vec)
	local cosB = 0
	local sinB = -1
	local x1 = vec.x * cosB - vec.y * sinB
	local y1 = vec.x * sinB + vec.y * cosB
	return {x=-x1, y=-y1}
end
function SVector2DTool.Vec2DRotate(vec, a)
	local rad = math.rad(a)
	local cosB = math.cos(rad)
	local sinB = math.sin(rad)
	local x1 = vec.x * cosB - vec.y * sinB
	local y1 = vec.x * sinB + vec.y * cosB
	return {x=x1, y=y1}
end

function SVector2DTool.PointToWorldSpace(point, AgentHeading, AgentSide, AgentPosition)
	local x = point.x * AgentHeading.x + point.y * AgentSide.x + AgentPosition.x
	local y = point.x * AgentHeading.y + point.y * AgentSide.y + AgentPosition.y
	return {x=x ,y=y}
end

function SVector2DTool.RandomClamped()
	return 2*math.random()-1
end

return SVector2DTool