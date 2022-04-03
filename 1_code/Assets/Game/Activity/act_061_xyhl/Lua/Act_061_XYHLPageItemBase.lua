-- 创建时间:2021-09-27
-- Panel:Act_061_XYHLPageItemBase
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

Act_061_XYHLPageItemBase = basefunc.class()
local C = Act_061_XYHLPageItemBase
C.name = "Act_061_XYHLPageItemBase"
local M = Act_061_XYHLManager

function C.Create(parent, panelSelf, index, config)
	return C.New(parent, panelSelf, index, config)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, panelSelf, index, config)
	ExtPanel.ExtMsg(self)
    self.index = index
    self.config = config
    self.panelSelf = panelSelf
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
    self.btn_txt.text = self.config.left
    self.img_txt.text = self.config.left
    self.page_btn.onClick:AddListener(function ()
        self:OnClick()
    end)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnClick()
    self.panelSelf:Selet(self.index)
end

function C:RefreshSelet(index)
    self.page_img.gameObject:SetActive(index == self.index)
    self.page_btn.gameObject:SetActive(index ~= self.index)
end