-- 创建时间:2021-05-08
-- Panel:SYS_TXZ_ChoosePanel
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

SYS_TXZ_ChoosePanel = basefunc.class()
local C = SYS_TXZ_ChoosePanel
C.name = "SYS_TXZ_ChoosePanel"
local M=SYS_TXZ_Manager

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
    self.lister["finish_gift_shop"] =basefunc.handler(self,self.on_finish_gift_shop)

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
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
	EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.MyClose)
	EventTriggerListener.Get(self.commonbuy_btn.gameObject).onClick = basefunc.handler(self, self.OnCommonbuyBtnClick)
	EventTriggerListener.Get(self.specialbuy_btn.gameObject).onClick = basefunc.handler(self, self.OnSpecialbuyBtnClick)
	EventTriggerListener.Get(self.pt1_btn.gameObject).onClick = basefunc.handler(self, self.OnPTClick1)
	EventTriggerListener.Get(self.pt2_btn.gameObject).onClick = basefunc.handler(self, self.OnPTClick2)
	self.shopIDs=M.GetShopIDs()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnCommonbuyBtnClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	SYS_TXZ_TipPanel.Create(function ()
		dump(self.shopIDs.haiwang,"海王shopid")
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.shopIDs.haiwang)
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100),
			function (result)
			end)
	end)
end

function C:OnSpecialbuyBtnClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.shopIDs.haiwangSpe)
	PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100),
		function (result)
		
		end)
end
function C:on_finish_gift_shop(id)
	dump(id,"购买的礼包id: ")
	local shopIDs=M.GetShopIDs()
	if id ==shopIDs.haiwang or id==shopIDs.haiwangSpe  then
		self:MyExit()
    end
end

function C:OnPTClick1()
	self.tip1.gameObject:SetActive(not self.tip1.gameObject.activeSelf)
end

function C:OnPTClick2()
	self.tip2.gameObject:SetActive(not self.tip2.gameObject.activeSelf)
end