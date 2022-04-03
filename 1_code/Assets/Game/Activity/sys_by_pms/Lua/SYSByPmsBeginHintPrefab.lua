-- 创建时间:2020-04-27
-- Panel:SYSByPmsBeginHintPrefab
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

SYSByPmsBeginHintPrefab = basefunc.class()
local C = SYSByPmsBeginHintPrefab
C.name = "SYSByPmsBeginHintPrefab"

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
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
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
	if self.seq1 then
		self.seq1:Kill()
		self.seq1 = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv3").transform
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
	self.hint.transform.localPosition = Vector3.New(-1600,0,0)
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.hint.transform:DOLocalMove(Vector3.New(0,0,0),1.5):SetEase(DG.Tweening.Ease.OutElastic))
	self.seq:AppendInterval(1)
	self.seq:Append(self.hint.transform:DOLocalMove(Vector3.New(1600,0,0),0.1))
	self.seq:AppendCallback(function ()
		self.gameObject:SetActive(false)
		self.seq1 = DoTweenSequence.Create()
		self.seq1:AppendInterval(0.5)
		self.seq1:AppendCallback(function ()
			Event.Brocast("SYSByPmsBeginHint_exit")
			self:MyExit()
		end)
	end)
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:OnExitScene()
	self:MyExit()
end