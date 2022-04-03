-- 创建时间:2020-11-19
-- Panel:FishFarmBookFishPrefab
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

FishFarmBookFishPrefab = basefunc.class()
local C = FishFarmBookFishPrefab
C.name = "FishFarmBookFishPrefab"

function C.Create(parent, id, index)
	return C.New(parent, id, index)
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

function C:ctor(parent, id, index)
	self.id = id
	self.index = index

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
	self.dj_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnDJClick()
	end)
	self.config = FishFarmManager.GetFishConfig(self.id)
	self.is_get = FishFarmManager.IsGetHandbookByID(self.id)
	self:MyRefresh()
end

function C:MyRefresh()
	self.icon_img.sprite = GetTexture(self.config.icon)
	self.name_txt.text = self.config.name
	if not self.is_get then
		self.icon_img.color = Color.black
		self.lock.gameObject:SetActive(true)
		self.name_txt.text = "???"
	end
end

function C:OnDJClick()
	Event.Brocast("ui_fishbowl_handbook_select_fish", {id = self.id, index = self.index})
end

function C:SetSelect(b)
	self.select.gameObject:SetActive(b)
end