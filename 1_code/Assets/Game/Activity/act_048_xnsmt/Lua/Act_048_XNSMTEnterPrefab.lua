-- 创建时间:2021-01-20
-- Panel:Act_048_XNSMTEnterPrefab
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

Act_048_XNSMTEnterPrefab = basefunc.class()
local C = Act_048_XNSMTEnterPrefab
local M = Act_048_XNSMTManager
C.name = "Act_048_XNSMTEnterPrefab"

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
	self.lister["model_xnsmt_share_refresh"] = basefunc.handler(self, self.on_model_xnsmt_share_refresh)
	self.lister["model_xnsmt_collect_refresh"] = basefunc.handler(self,self.on_model_xnsmt_collect_refresh)
	self.lister["model_xnsmt_task_refresh"] = basefunc.handler(self,self.on_model_xnsmt_task_refresh)
	self.lister["xnsmt_task_award_new_refresh"] = basefunc.handler(self,self.on_xnsmt_task_award_new_refresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	CommonHuxiAnim.Stop(1,Vector3.New(1, 1, 1))
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
	--local parent = GameObject.Find("Canvas/GUIRoot").transform
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
	self.transform:GetComponent("Button").onClick:AddListener(function ()
		self.OnEnterClick()
	end)
	CommonHuxiAnim.Start(self.gameObject)
	self:MyRefresh()
end

function C:OnEnterClick()
	Act_048_XNSMTPanel.Create()
end

function C:MyRefresh()
	self.LFL.gameObject:SetActive(M.IsHint())
end

function C:on_model_xnsmt_share_refresh()
	self:MyRefresh()
end

function C:on_model_xnsmt_collect_refresh()
	self:MyRefresh()
end

function C:on_model_xnsmt_task_refresh()
	self:MyRefresh()
end

function C:on_xnsmt_task_award_new_refresh()
	self:MyRefresh()
end