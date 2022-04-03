-- 创建时间:2021-02-08
-- Panel:Act_XRXSFLEnterPrefab
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_XRXSFLEnterPrefab = basefunc.class()
local C = Act_XRXSFLEnterPrefab
C.name = "Act_XRXSFLEnterPrefab"
local M = Act_XRXSFLManager

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["xrxsfl_task_had_got_msg"] = basefunc.handler(self,self.on_xrxsfl_task_had_got_msg)
    self.lister["xrxsfl_cj_award_had_got_msg"] = basefunc.handler(self,self.on_xrxsfl_cj_award_had_got_msg)
    self.lister["xrxsfl_task_change_smg"] = basefunc.handler(self,self.on_xrxsfl_task_change_smg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterClick)
	EventTriggerListener.Get(self.zz_btn.gameObject).onClick = basefunc.handler(self, self.OnZheZhaoClick)
	CommonTimeManager.GetCutDownTimer2(MainModel.UserInfo.first_login_time + 259200 , self.remain_txt)
	self:MyRefresh()
end

function C:MyRefresh()
	self.lfl.gameObject:SetActive(M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get)
	self.red.gameObject:SetActive(M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Red)
	--self.finger.gameObject:SetActive((M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get) and self:CheckIsCjj())
	if self:CheckIsCjj() then
		self.zz_btn.gameObject:SetActive(false)
	else
		local b,lvl = GameButtonManager.RunFun({gotoui = "sys_by_level"}, "GetLevel")
		if b then
			if lvl >= 3 then
				self.finger_.gameObject:SetActive(true)
				self.zz_btn.gameObject:SetActive(false)
			else
				self.finger_.gameObject:SetActive(false)
				self.zz_btn.gameObject:SetActive(true)
			end
		end
	end
end

function C:OnEnterClick()
	if self:CheckIsCjj() then
		Act_XRXSFLPanel.Create()
	else
		local b,lvl = GameButtonManager.RunFun({gotoui = "sys_by_level"}, "GetLevel")
		if b then
			if lvl >= 3 then
				Act_XRXSFLPanel.Create()
			else
				LittleTips.Create("3级解锁")
			end
		end
	end
end

function C:on_xrxsfl_task_had_got_msg()
	self:MyRefresh()
end

function C:on_xrxsfl_cj_award_had_got_msg()
	self:MyRefresh()
end

function C:on_xrxsfl_task_change_smg()
	self:MyRefresh()
end

function C:CheckIsCjj()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
	if a and b then
		return true
	end
	return false
end

function C:OnZheZhaoClick()
	LittleTips.Create("3级解锁")
end