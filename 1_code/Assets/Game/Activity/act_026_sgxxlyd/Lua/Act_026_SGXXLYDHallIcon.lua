-- 创建时间:2020-08-19
-- Panel:Act_026_SGXXLYDHallIcon
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

Act_026_SGXXLYDHallIcon = basefunc.class()
local C = Act_026_SGXXLYDHallIcon
C.name = "Act_026_SGXXLYDHallIcon"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:KillDotween()
	self:StopTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:Timer(true)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:Dotween()
	self:KillDotween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.icon.transform:DOShakeRotation(1,Vector3.New(0,0,60),10,60))
end

function C:KillDotween()
	if IsEquals(self.seq) then
		self.seq:Kill()
		self.seq = nil
	end
end

function C:Timer(b)
	self:StopTimer()
	if b then
		self:Dotween()
		self.timer = Timer.New(function ()
			self:Dotween()
		end,3,-1)
		self.timer:Start()
	end
end

function C:StopTimer()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
end