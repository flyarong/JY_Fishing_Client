-- 创建时间:2021-05-21
-- Panel:ACTCJDBHelpPrefab
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

ACTCJDBHelpPrefab = basefunc.class()
local C = ACTCJDBHelpPrefab
C.name = "ACTCJDBHelpPrefab"

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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:MyExit()
    end)

    self.config = {}
    self.config[#self.config + 1] = {vip=2, a=2, b=0}
	self.config[#self.config + 1] = {vip=3, a=3, b=0}
	self.config[#self.config + 1] = {vip=4, a=5, b=0}
	self.config[#self.config + 1] = {vip=5, a=10, b=1}
	self.config[#self.config + 1] = {vip=6, a=15, b=2}
	self.config[#self.config + 1] = {vip=7, a=20, b=3}
	self.config[#self.config + 1] = {vip=8, a=30, b=4}
	self.config[#self.config + 1] = {vip=9, a=40, b=5}
	self.config[#self.config + 1] = {vip=10, a=50, b=6}
	self.config[#self.config + 1] = {vip=11, a=50, b=6}
	self.config[#self.config + 1] = {vip=12, a=50, b=6}

	self:MyRefresh()
end

function C:MyRefresh()
	for k,v in ipairs(self.config) do
		local obj = GameObject.Instantiate(self.cell, self.node)
		obj.gameObject:SetActive(true)
		local ui = {}
		LuaHelper.GeneratingVar(obj.transform, ui)
		ui.level_txt.text = v.vip
		ui.ybx_txt.text = v.a
		ui.jbx_txt.text = v.b
	end
end
