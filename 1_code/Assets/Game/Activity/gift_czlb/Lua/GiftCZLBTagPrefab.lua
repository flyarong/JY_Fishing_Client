-- 创建时间:2020-08-07
-- Panel:GiftCZLBTagPrefab
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

GiftCZLBTagPrefab = basefunc.class()
local C = GiftCZLBTagPrefab
C.name = "GiftCZLBTagPrefab"

function C.Create(parent_transform, config, call, panelSelf)
	return C.New(parent_transform, config, call, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["gift_czlb_gift_bag_data_change_msg"] = basefunc.handler(self, self.RefreshRed)
    self.lister["gift_czlb_gift_bag_data_finish_msg"] = basefunc.handler(self, self.RefreshRed)
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

function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
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
	self.tag_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.call(self.panelSelf, self.config)
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self.name1_txt.text = self.config.title
	self.name2_txt.text = self.config.title
	self:SetSelect(false)
end

function C:SetSelect(b)
	self.tag_btn.gameObject:SetActive(not b)
	self.tag_no.gameObject:SetActive(b)

	if b then
		GiftCZLBManager.SetRedByKey(self.config.id)
		self:RefreshRed()
	end
end

function C:RefreshRed()
	if GiftCZLBManager.IsRedByKey(self.config.id) then
		self.Red.gameObject:SetActive(true)		
	else
		self.Red.gameObject:SetActive(false)
	end
end