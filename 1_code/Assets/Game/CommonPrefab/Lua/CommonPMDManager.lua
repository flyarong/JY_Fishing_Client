-- 创建时间:2020-06-22
-- Panel:CommonPMDManager
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

CommonPMDManager = basefunc.class()
local C = CommonPMDManager
C.name = "CommonPMDManager"
--actvity_mode :1 左滑动,2向上滑动，居中时停止一会
local anim_funcs = {
"Anim1",
"Anim2",
}
local dotweenLayerKey = "CommonPMDManager"

function C.Create(panelSelf, cell_call, parm)
	return C.New(panelSelf, cell_call, parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	DOTweenManager.KillLayerKeyTween(self.parm.dotweenLayerKey)

	if self.Loop_Timer then
		self.Loop_Timer:Stop()
	end
	self:RemoveListener()
	
end

function C:ctor(panelSelf, cell_call, parm)
	self.panelSelf = panelSelf
	self.cell_call = cell_call
	self.parm = parm
	self.parm.dotweenLayerKey = self.parm.dotweenLayerKey or dotweenLayerKey

	self:MakeLister()
	self:AddMsgListener()

	self.pmd_list = self.parm.pmd_list or {}

	self.actvity_mode = parm.actvity_mode or 1
	self.time_scale = self.parm.time_scale or 1
	if self.actvity_mode == 1 then
		self.start_pos = parm.start_pos or 1200
		self.end_pos = parm.end_pos or -1200
	else
		self.start_pos = parm.start_pos or -120
		self.end_pos = parm.end_pos or 120
	end
	self.is_can_anim = true
	self:RunPMD()
end

--当展示区域没有任何一个物体的时,某个物体出现
function C:SetOnStartCall(backcall)
	self.onStartCall = backcall
end

--当展示区域只剩下一个物体,这个物体即将消失时
function C:SetOnEndCall(backcall)
	self.onEndCall = backcall
end

--横着走
function C:Anim1(obj)
	local tran = obj.transform
	tran.localPosition = Vector3.New(self.start_pos, 0, 0)
	local seq = DoTweenSequence.Create({dotweenLayerKey=self.parm.dotweenLayerKey})
	seq:Append(tran:DOLocalMoveX(self.end_pos, 10*self.time_scale):SetEase(DG.Tweening.Ease.Linear))
	seq:OnKill(function ()
		destroy(obj.gameObject)
		self.is_can_anim = true
		self:RunPMD()
		if #self.pmd_list == 0 then
			if self.onEndCall then
				self.onEndCall()
			end
		end
	end)
end

--竖着走
function C:Anim2(obj)
	local tran = obj.transform
	tran.localPosition = Vector3.New(0, self.start_pos, 0)
	local seq = DoTweenSequence.Create({dotweenLayerKey=self.parm.dotweenLayerKey})
	seq:Append(tran:DOLocalMoveY(0, 1.5*self.time_scale))
	seq:AppendInterval(1*self.time_scale)
	seq:Append(tran:DOLocalMoveY(100, 1.5*self.time_scale))
	seq:OnKill(function ()
		destroy(obj.gameObject)
		self.is_can_anim = true
		self:RunPMD()
		if #self.pmd_list == 0 then
			if self.onEndCall then
				self.onEndCall()
			end
		end
	end)
end

function C:RunPMD()
	if #self.pmd_list > 0 and self.is_can_anim then
		local obj = self.cell_call(self.panelSelf, self.pmd_list[1])
		table.remove(self.pmd_list, 1)
		self.is_can_anim = false
		if self.actvity_mode == 1 then
			self:Anim1(obj)
		else
			self:Anim2(obj)
		end
	end
end

function C:AddPMDData(data, is_top)
	if is_top then
		table.insert(self.pmd_list, 1, data)
	else
		self.pmd_list[#self.pmd_list + 1] = data
	end
	self:RunPMD()
end
