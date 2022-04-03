-- 创建时间:2020-03-05
-- Panel:Fishing3DActBKEnterPrefab
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

Fishing3DActBKEnterPrefab = basefunc.class()
local C = Fishing3DActBKEnterPrefab
C.name = "Fishing3DActBKEnterPrefab"
local M = BY3DActXYCBManager
function C.Create(parent)
	return C.New(parent)
end
function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
	self.lister["XYCBManager_enter_lfl_msg"] = basefunc.handler(self,self.on_XYCBManager_enter_lfl_msg)
	self.lister["model_fishing_skill_msg"] = basefunc.handler(self,self.on_model_fishing_skill_msg)
	self.lister["fishing3d_xycb_djs_msg"] = basefunc.handler(self,self.on_fishing3d_xycb_djs_msg)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	M.StopMFLQUpdataTimer()
	M.StopEnterCountDownTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end


function C:ctor(parent)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self) 
	self.transform.localPosition = Vector3.zero
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.djs_txt.text = 99999999999999
	self.down_val = 99999999999999
end

function C:InitUI()
	self.enter_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	M.QueryAllInfo()
	M.MFLQUpdataTimer()
	self:MyRefresh()
end

function C:OnEnterClick()
	Fishing3DActXYCBPanel.Create()
end

function C:MyRefresh()
end


function C:on_XYCBManager_enter_lfl_msg(b,type)
	if IsEquals(self.lfl) then
		self.lfl.gameObject:SetActive(b and type and (type == "lfl"))
	end
	if IsEquals(self.lcb) then
		self.lcb.gameObject:SetActive(b and type and (type == "lcb"))
	end
end

function C:on_model_fishing_skill_msg(data)
	FishingAnimManager.PlayMoveAndHideFX(self.transform, "Fish3D_hongbaoyu_glow", data.beginPos, self.transform.position, 1, 0.5, nil, 0.5)
end

function C:on_fishing3d_xycb_djs_msg(time)
	--dump(time,"<color=yellow>++++++++++//////++++++++++++</color>")
	if time then
		self.djs_bg.gameObject:SetActive(true)
		self.djs_txt.gameObject:SetActive(true)
		--dump({time = time,txt = self.djs_txt,text = self.djs_txt.text},"<color=yellow>+++++++++++++////++++++++++++++</color>")
		self.down_val = math.min(tonumber(time),tonumber(self.down_val))
		local hh = math.floor(self.down_val / 3600)
		local ff = math.floor((self.down_val % 3600) / 60)
		local mm = self.down_val % 60
		self.djs_txt.text = string.format("%02d:%02d:%02d", hh, ff, mm)
	else
		self.down_val = 99999999999999
		self.djs_bg.gameObject:SetActive(false)
		self.djs_txt.gameObject:SetActive(false)
	end
end
