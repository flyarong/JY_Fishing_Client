-- 创建时间:2021-03-04
-- Panel:SYSLWGPPanel
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

SYSLWGPPanel = basefunc.class()
local C = SYSLWGPPanel
C.name = "SYSLWGPPanel"
local M = SYSLWGPManager

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
	self:DeletNodePre()
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
	ExtPanel.ExtMsg(self)
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.OnHelpClick)
	EventTriggerListener.Get(self.store_btn.gameObject).onClick = basefunc.handler(self, self.OnStoreClick)
	EventTriggerListener.Get(self.history_btn.gameObject).onClick = basefunc.handler(self, self.OnHistoryClick)
	self:MyRefresh()
	self:OnStoreClick()
	
end

function C:MyRefresh()
end

function C:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:MyExit()
end

function C:OnHelpClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	SYSLWGPHelpPanel.Create()
end

function C:OnStoreClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:DeletNodePre()
	self.node_pre = SYSLWGPStorePanel.Create(self.node.transform)
	self.store_img.sprite = GetTexture("lwgp_imgf_xz1")
	self.history_img.sprite = GetTexture("lwgp_imgf_wxz2")
end

function C:OnHistoryClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:DeletNodePre()
	self.node_pre = SYSLWGPHistoryPanel.Create(self.node.transform)
	self.store_img.sprite = GetTexture("lwgp_imgf_wxz1")
	self.history_img.sprite = GetTexture("lwgp_imgf_xz2")
end

function C:DeletNodePre()
	if self.node_pre then
		self.node_pre:MyExit()
		self.node_pre = nil
	end
end