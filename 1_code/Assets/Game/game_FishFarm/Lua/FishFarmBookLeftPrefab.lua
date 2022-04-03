-- 创建时间:2020-11-19
-- Panel:FishFarmBookLeftPrefab
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

FishFarmBookLeftPrefab = basefunc.class()
local C = FishFarmBookLeftPrefab
C.name = "FishFarmBookLeftPrefab"

function C.Create(parent, data)
	return C.New(parent, data)
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

function C:ctor(parent, data)
	self.data = data
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.img1 = self.select_btn.transform:GetComponent("Image")
	self.img2 = self.not_select.transform:GetComponent("Image")
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.select_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnXZClick()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self.img1.sprite = GetTexture(self.data.img1)
	self.img2.sprite = GetTexture(self.data.img2)
	self.select_txt.text = self.data.name
	self.not_select_txt.text = self.data.name
end

function C:OnXZClick()
	Event.Brocast("ui_fishbowl_handbook_select_tag", self.data)
end

function C:SetSelect(b)
	self.select_btn.gameObject:SetActive(not b)
	self.not_select.gameObject:SetActive(b)
end

