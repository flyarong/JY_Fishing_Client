local basefunc = require "Game/Common/basefunc"

XRQTLEnterPrefab = basefunc.class()
local C = XRQTLEnterPrefab
C.name = "XRQTLEnterPrefab"
local M = XRQTLManager
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
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
	self.lister["get_task_award_response"] = basefunc.handler(self,self.on_get_task_award_response)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
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
end

function C:InitUI()
	self.transform:GetComponent("Button").onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self.xsyd_btn.transform:GetComponent("Button").onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	local time = MainModel.FirstLoginTime() + 604800
	time = (time - os.time()) / 3600
	if time <= 48 then
		self.down_count.gameObject:SetActive(true)
		self.cutdown_timer = CommonTimeManager.GetCutDownTimer(MainModel.FirstLoginTime() + 604800,self.time_txt,true,function ()
			if IsEquals(self.down_count) then
				self.down_count.gameObject:SetActive(false)
			end
		end)
	end

	self:MyRefresh()
end

function C:OnEnterClick()
	self.xsyd_node.gameObject:SetActive(false)
	XRQTLPanel_New.Create()
	PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.Red) then
		return
	end
	local s = M.GetHintState({gotoui= M.key})
	self.LFL.gameObject:SetActive(false)
	self.Red.gameObject:SetActive(false)
	if s == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	end 
	if s == ACTIVITY_HINT_STATUS_ENUM.AT_Red then 
		self.Red.gameObject:SetActive(true)
	end 
	if not M.IsAwardCanGet() and not M.IsAwardCanGetTop() then
		self.LHF.gameObject:SetActive(true)
	else
		self.LHF.gameObject:SetActive(false)
	end
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == M.key then
		self:MyRefresh()
	end
end

function C:on_get_task_award_response(_,data)
	if data and data.result == 0 then
		if data.id == 30021 then
			self.xsyd_node.gameObject:SetActive(true)
		end
	end
end