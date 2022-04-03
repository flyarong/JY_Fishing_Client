-- 创建时间:2021-02-24
-- Panel:Act_TY_JZSJBEXTRAPanel
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

Act_TY_JZSJBEXTRAPanel = basefunc.class()
local C = Act_TY_JZSJBEXTRAPanel
C.name = "Act_TY_JZSJBEXTRAPanel"
local M = Act_TY_JZSJBManager

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
	self:ClearExtraItemBase()
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	self:MyRefresh()
end

function C:MyRefresh()
	local path = M.GetCurSytleKey()
	SetTextureExtend(self.bg1_img, path.."_ewjl_bg_1")
	SetTextureExtend(self.title_img, path.."_ewjl_bt_1")
	self:CreateExtraItemBase()
end

function C:CreateExtraItemBase()
	self:ClearExtraItemBase()
	local tab = M.GerCurExtraAwardConfig()
	for i=1,#tab do
		for j=tab[i].limit[1],tab[i].limit[2] do
			local pre = Act_TY_JZSJBEXTRAItemBase.Create(self.Content.transform,j,tab[i])
			self.extra_cell[#self.extra_cell + 1] = pre
		end
	end
end

function C:ClearExtraItemBase()
	if self.extra_cell then
		for k,v in pairs(self.extra_cell) do
			v:MyExit()
		end
	end
	self.extra_cell = {}
end

function C:OnBackClick()
	self:MyExit()
end