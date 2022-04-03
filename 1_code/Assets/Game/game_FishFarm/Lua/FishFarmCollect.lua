-- 创建时间:2020-11-17
-- Panel:FishFarmCollect
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

FishFarmCollect = basefunc.class()
local C = FishFarmCollect
C.name = "FishFarmCollect"

function C.Create(parent, data)
	return C.New(parent, data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:kill_seq()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, data)
	self.data = data

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.get_img = self.get_btn.transform:GetComponent("Image")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.get_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnGetClick()
	end)
	if self.data.type == "jinbi" then
		self.get_img.sprite = GetTexture("szzg_iocn_yb")
	elseif self.data.type == "exp" then
		self.get_img.sprite = GetTexture("szzg_btn_szg")
	else
		self.get_img.sprite = GetTexture("szzg_iocn_sb")
	end
	self.transform.position = self.data.beginPos
	self.get_txt.text = "+" .. self.data.value

	self:MyRefresh()
end

function C:MyRefresh()
	local pos = Vector3.New(self.data.beginPos.x+math.random(0,800)-400, -320, 0)
	self.get_btn.enabled = false
	self.seq_cx = DoTweenSequence.Create()
    self.seq_cx:Append(self.transform:DOMoveY(self.data.beginPos.y+460, 0.8):SetEase(DG.Tweening.Ease.Linear))
    self.seq_cx:Append(self.transform:DOMoveY(pos.y, 1.2):SetEase(DG.Tweening.Ease.OutBounce))
    self.seq_cx:AppendInterval(-2)
    self.seq_cx:Append(self.transform:DOMoveX(pos.x, 2):SetEase(DG.Tweening.Ease.Linear))
    self.seq_cx:OnKill(function ()
    	self.seq_cx = nil
		self.get_btn.enabled = true
		
		self.seq_cx = DoTweenSequence.Create()
		self.seq_cx:AppendInterval(3)
	    self.seq_cx:OnKill(function ()
	    	self.seq_cx = nil
	    	self:PlayFly()
		end)
    end)
end

function C:PlayFly()
	self.get_btn.enabled = false
	self:kill_seq()

	self.seq_cx = DoTweenSequence.Create()
    self.seq_cx:Append(self.transform:DOMoveBezier(self.data.endPos, 150, 0.5))
    self.seq_cx:OnKill(function ()
    	self.seq_cx = nil
    	self:MyExit()
	end)
end
function C:kill_seq()
	if self.seq_cx then
		self.seq_cx:Kill()
		self.seq_cx = nil
	end
end

function C:OnGetClick()
	self:PlayFly()
end