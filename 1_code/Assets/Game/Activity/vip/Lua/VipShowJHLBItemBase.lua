-- 创建时间:2020-07-13
-- Panel:VipShowJHLBItemBase
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

VipShowJHLBItemBase = basefunc.class()
local C = VipShowJHLBItemBase
C.name = "VipShowJHLBItemBase"

function C.Create(parent,data,parent_panel)
	return C.New(parent,data,parent_panel)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["finish_gift_shop"] = basefunc.handler(self,self.on_finish_gift_shop)
    self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self,self.on_model_vip_level_is_up_msg)
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

function C:ctor(parent,data,parent_panel)
	self.data = data
	self.parent_panel = parent_panel
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
	EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.on_BuyClick)
	EventTriggerListener.Get(self.lock_btn.gameObject).onClick = basefunc.handler(self, self.on_LockClick)
	EventTriggerListener.Get(self.bg2_btn.gameObject).onClick = basefunc.handler(self, self.on_Tips2Click)
	EventTriggerListener.Get(self.bg3_btn.gameObject).onClick = basefunc.handler(self, self.on_Tips3Click)

	self.title1_txt.text = self.data.title[1]
	self.title2_txt.text = self.data.title[2]
	self.price_txt.text = "价格: "..(self.data.price or "99999999").."元"
	for i=1,#self.data.award_img do
		self["award"..i].gameObject:SetActive(true)
		self["award"..i.."_img"].sprite = GetTexture(self.data.award_img[i])
		self["award"..i.."_txt"].text = self.data.award_txt[i]
	end
	self:MyRefresh()
end

function C:MyRefresh()
	local status = MainModel.GetGiftShopStatusByID(self.data.gift_id)
	if status then	
		if status == 1 then
			--[[local _permission_key = "actp_buy_gift_bag_"..self.data.gift_id
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
	        if a and b then--]]
	        if IsEquals(self.buy_btn) then
            	self.buy_btn.gameObject:SetActive(true)
            end
            if IsEquals(self.lock_btn) then
				self.lock_btn.gameObject:SetActive(false)
			end
			if IsEquals(self.hint_node1) then
				self.hint_node1.gameObject:SetActive(true)
			end
		elseif status == 0 then
			if MainModel.UserInfo.vip_level >= self.data.index then
				self:MyExit()
			else
				if IsEquals(self.buy_btn) then
					self.buy_btn.gameObject:SetActive(false)
				end
				if IsEquals(self.lock_btn) then
					self.lock_btn.gameObject:SetActive(true)
				end
				if IsEquals(self.hint_node1) then
					self.hint_node1.gameObject:SetActive(false)
				end
			end
		end
	end
end


function C:on_finish_gift_shop(id)
	if self.data.gift_id == id then
		self:MyRefresh()
		self.parent_panel:CheckCanShow()
	end
end


function C:on_BuyClick()
	self:BuyShop(self.data.gift_id)
end

function C:on_LockClick()
	LittleTips.Create("提升VIP等级,可解锁礼包")
end

function C:BuyShop(shopid)
	dump(shopid)
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function C:on_model_vip_level_is_up_msg()
	self:MyRefresh()
end

function C:on_Tips2Click()
	
end

function C:on_Tips3Click()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
	if a and  b then
		LittleTips.Create("请在冲金鸡中使用")
	else
		LittleTips.Create("请在敲敲乐中使用")
	end

end