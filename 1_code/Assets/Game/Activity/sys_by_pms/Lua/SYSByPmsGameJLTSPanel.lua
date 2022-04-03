-- 创建时间:2020-05-14
-- Panel:SYSByPmsGameJLTSPanel
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

SYSByPmsGameJLTSPanel = basefunc.class()
local C = SYSByPmsGameJLTSPanel
C.name = "SYSByPmsGameJLTSPanel"

function C.Create(target)
	return C.New(target)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["SYSByPms_on_backgroundReturn_msg"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(target)
	self.target = target
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
	self:AutoDestroy()

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:AutoDestroy()
	self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(1.5)
	self.seq:Append(self.jlts_img.transform:DOLocalMove(Vector3.New(self.target.transform.position.x+40,self.target.transform.position.y+60,0),0.8))
	self.seq:Join(self.jlts_img.transform:DOScale(Vector3.New(0,0,1),0.8))
	self.seq:AppendCallback(function ()
		self.jlts_img.gameObject:SetActive(false)
		self.SYSByPms_jiangbei.gameObject:SetActive(true)
	end)
	self.seq:AppendInterval(0.7)
	self.seq:AppendCallback(function ()
		self:MyExit()
	end)
end