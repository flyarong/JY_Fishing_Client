-- 创建时间:2021-05-25
-- Panel:GameShop3YuanPanelInAct
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

GameShop3YuanPanelInAct = basefunc.class()
local C = GameShop3YuanPanelInAct
C.name = "GameShop3YuanPanelInAct"

function C.Create(parent)
	return C.New(parent)
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

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent =parent or GameObject.Find("Canvas/GUIRoot").transform
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
	EventTriggerListener.Get(self.goto_btn.gameObject).onClick = basefunc.handler(self, self.on_BuyClick)

	self:MyRefresh()
end
function C:MyRefresh()
	self:RefleshClickType()
	self.yuka_img.gameObject:SetActive(self.clickType>0)
	self.haohua_tip.gameObject:SetActive(self.clickType==1)
	self.zhizun_tip.gameObject:SetActive(self.clickType==2)
	if self.clickType==0 then
		GetTextureExtend(self.bg_img,"3ylb_dk_bg_0")
	elseif self.clickType==1 then
		GetTextureExtend(self.bg_img,"syfllb_imgf_syfllb")
		GetTextureExtend(self.yuka_img,"syfllb_imgf_hhyk")
	else
		GetTextureExtend(self.bg_img,"syfllb_imgf_syfllb")
		GetTextureExtend(self.yuka_img,"syfllb_imgf_zxyk")
	end
end
function C:RefleshClickType()
	local shopid=10
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
	self.status = MainModel.GetGiftShopStatusByID(gift_config.id)
	dump(MainModel.UserInfo.vip_level,"vip_level  ")
	if self.status==1 then
		self.clickType=0
	else
		local yuekastate=Sys_011_YuekaManager.YueKaBuyState()
		if MainModel.UserInfo.vip_level==0 then
			if yuekastate==0 then
				self.clickType=1
			else
				self.clickType=0				
			end
		else
			if yuekastate==0 or yuekastate==1 then
				self.clickType=2
			elseif yuekastate==2 then
				self.clickType=1
			elseif yuekastate==3 then
				self.clickType=0
			end
		end	
	end
end
gotoUI_0 = {"hall_gift",10}
gotoUI_1_2 = "sys_011_yueka_new"

function C:on_BuyClick()
	if self.clickType==0 then
		local parm = {}
		SetTempParm(parm, gotoUI_0, "panel")
		GameManager.GuideExitScene(parm)
	else
		Event.Brocast("jump_to_index",gotoUI_1_2)
	end
	
end
