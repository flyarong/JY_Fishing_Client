-- 创建时间:2020-04-15
-- Panel:ByGunItemPrefab
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

ByGunItemPrefab = basefunc.class()
local C = ByGunItemPrefab
C.name = "ByGunItemPrefab"

function C.Create(panelSelf, data, parent_transform, call, index)
	return C.New(panelSelf, data, parent_transform, call, index)
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

function C:ctor(panelSelf, data, parent_transform, call, index)
	self.panelSelf = panelSelf
	self.data = data
	self.call = call
	self.index = index
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.type = data.type
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.item_btn.onClick:AddListener(function ()
		if self.call then
			self.call(self.panelSelf, self.index)
		end
	end)
	if self.data.type_colour == 1 then
		--普通炮台
		self.bg_pt.gameObject:SetActive(true)
		self.bg_ss.gameObject:SetActive(false)
		self.bg_cs.gameObject:SetActive(false)
		self.name_pt_txt.text = self.data.name
	elseif self.data.type_colour == 2 then
		--史诗炮台
		self.bg_pt.gameObject:SetActive(false)
		self.bg_ss.gameObject:SetActive(true)
		self.bg_cs.gameObject:SetActive(false)
		self.name_ss_txt.text = self.data.name
	elseif self.data.type_colour == 3 then
		--传说炮台
		self.bg_pt.gameObject:SetActive(false)
		self.bg_ss.gameObject:SetActive(false)
		self.bg_cs.gameObject:SetActive(true)
		self.name_cs_txt.text = self.data.name
	end
	self.icon_img.sprite = GetTexture(self.data.image)
	self.icon_img:SetNativeSize()
	self:MyRefresh()
end

function C:SetSelect(b)
	if self.data.type_colour == 1 then
		--普通炮台
		self.xz_obj_pt.gameObject:SetActive(b)
		self.xz_obj_cs.gameObject:SetActive(false)
	elseif self.data.type_colour == 2 then
		--普通炮台
		self.xz_obj_pt.gameObject:SetActive(b)
		self.xz_obj_cs.gameObject:SetActive(false)
	elseif self.data.type_colour == 3 then
		--传说炮台
		self.xz_obj_pt.gameObject:SetActive(false)
		self.xz_obj_cs.gameObject:SetActive(b)
	end
	SYSByBagManager.DelRed(self.data.type, self.data.item_id)
	self.red.gameObject:SetActive(false)
end

function C:MyRefresh()
	self.equiped_txt.gameObject:SetActive(self:CheckEquiped())
	self.lock_icon.gameObject:SetActive(self.data.is_get == 0)

	self.red.gameObject:SetActive(SYSByBagManager.GetRed(self.data.type, self.data.item_id))
end

function C:CheckEquiped()
	if self.type == 1 then
		if SYSByBagManager.m_data.GunInfo and SYSByBagManager.m_data.GunInfo.barrel_id then
			return self.data.item_id == SYSByBagManager.m_data.GunInfo.barrel_id
		end
	elseif self.type == 2 then
		if SYSByBagManager.m_data.GunInfo and SYSByBagManager.m_data.GunInfo.bed_id then
			return self.data.item_id == SYSByBagManager.m_data.GunInfo.bed_id
		end
	elseif self.type == 3 then
		if SYSByBagManager.m_data.GunInfo and SYSByBagManager.m_data.GunInfo.frame_id then
			return self.data.item_id == SYSByBagManager.m_data.GunInfo.frame_id
		end
	end
	return false
end