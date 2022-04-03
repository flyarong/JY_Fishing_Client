-- 创建时间:2020-04-24
-- Panel:FishingMatchHallTagPrefab
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

FishingMatchHallTagPrefab = basefunc.class()
local C = FishingMatchHallTagPrefab
C.name = "FishingMatchHallTagPrefab"

function C.Create(parent_transform, config, call, panelSelf, index)
	return C.New(parent_transform, config, call, panelSelf, index)
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

function C:ctor(parent_transform, config, call, panelSelf, index)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	self.index = index

	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.normal_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnClick()
	end)
	self:SetSelect(false)
	self:MyRefresh()
end

function C:MyRefresh()
	self.normal_tge_txt.text = self.config.game_name
	self.select_tge_txt.text = self.config.game_name

	if self.config.game_key == "djs" then
		self.hint_node.gameObject:SetActive(true)
	else
		self.hint_node.gameObject:SetActive(false)
	end
end

function C:OnClick()
	self:SetSelect(true)
	if self.call then
		self.call(self.panelSelf, self.index)
	end
end

function C:SetSelect(b)
	self.normal_btn.gameObject:SetActive(not b)
	self.selected_img.gameObject:SetActive(b)
end
