-- 创建时间:2020-04-15
-- Panel:ByGunItemBuyPrefab
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

ByGunItemBuyPrefab = basefunc.class()
local C = ByGunItemBuyPrefab
C.name = "ByGunItemBuyPrefab"

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:OnDestroy()
	self:MyExit()
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
			self.call(self.panelSelf,self.index)
		end
	end)
	self.buy_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBuyClick()
	end)
	if self.data.type_colour == 1 then
		--普通炮台
		self.type_img.gameObject:SetActive(false)
		--[[self.bg_pt.gameObject:SetActive(true)
		self.bg_ss.gameObject:SetActive(false)
		self.bg_cs.gameObject:SetActive(false)
		self.name_pt_txt.text = self.data.name--]]
	elseif self.data.type_colour == 2 then
		--史诗炮台
		self.type_img.gameObject:SetActive(true)
		self.type_img.sprite = GetTexture("bb_icon_ss")
		self.type_img.transform.localScale = Vector3.New(0.8,0.8,0.8)
		self.type_img:SetNativeSize()
		--[[self.bg_pt.gameObject:SetActive(false)
		self.bg_ss.gameObject:SetActive(true)
		self.bg_cs.gameObject:SetActive(false)
		self.name_ss_txt.text = self.data.name--]]
	elseif self.data.type_colour == 3 then
		--传说炮台
		self.type_img.gameObject:SetActive(true)
		self.type_img.sprite = GetTexture("bb_icon_cq")
		self.type_img.transform.localScale = Vector3.New(1,1,1)
		self.type_img:SetNativeSize()
		--[[self.bg_pt.gameObject:SetActive(false)
		self.bg_ss.gameObject:SetActive(false)
		self.bg_cs.gameObject:SetActive(true)
		self.name_cs_txt.text = self.data.name--]]
	end
	self.name_pt_txt.text = self.data.name
	if self.data.is_get == 1 then
		self.price_txt.text = "已拥有"
	elseif self.data.is_get == 0 then
		local _type = self.data.buy_parm[1]
		local _id = self.data.buy_parm[2]
		if _type == "gift" then
			local cfg = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, _id)
			dump(cfg, "<color=red>EEEEEEEEEEEEEEEEEEEEE </color>")
			self.hb_icon.gameObject:SetActive(false)
			self.price_txt.text = "￥"..cfg.price/100
		else
			local cfg = MainModel.GetShopingConfig(GOODS_TYPE.item, _id, self.data.item_key)
			dump(cfg, "<color=red>EEEEEEEEEEEEEEEEEEEEE </color>")
			self.hb_icon.gameObject:SetActive(true)
			self.price_txt.text = ""..cfg.ui_price
		end
	end
	self.icon_img.sprite = GetTexture(self.data.image)
	self.icon_img:SetNativeSize()
	self:MyRefresh()
end

function C:SetSelect(b)
	self.xz_obj_pt.gameObject:SetActive(b)
	--[[if self.data.type_colour == 1 then
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
	end--]]
end

function C:MyRefresh()
	--self.equiped_txt.gameObject:SetActive(self:CheckEquiped())
	--self.lock_icon.gameObject:SetActive(self.data.is_get == 0)
	--self.got.gameObject:SetActive(self.data.is_get == 1)
	self.buy_btn.gameObject:SetActive(self.data.is_get == 0)
	if self.data.tag then
		self.tag_node.gameObject:SetActive(true)
		self.tag_txt.text = self.data.tag
	else
		self.tag_node.gameObject:SetActive(false)
	end
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

function C:OnBuyClick()
	self:BuyShop(self.data.gift_id)
end

function C:BuyShop()
	local _type = self.data.buy_parm[1]
	local _id = self.data.buy_parm[2]
	if _type == "gift" then
    	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, _id).price
	    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, _id))
	    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
	        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	    else
	        PayTypePopPrefab.Create(_id, "￥" .. (price / 100))
	    end
	else
	        Network.SendRequest(
            					"pay_exchange_goods",
            					{goods_type = self.data.item_key, goods_id = _id},
            "购买道具",
            function(data)
                dump(data, "pay_exchange_goods")
                if data.goods_type and (string.sub(data.goods_type, 1, 10) == "gun_barrel" or string.sub(data.goods_type, 1, 7) == "gun_bed") and data.result ~= 0 then
                    local pre = HintPanel.Create(2, "3D捕鱼中开炮可得福利券", function ()
                        if MainModel.myLocation ~= "game_Fishing3DHall" and MainModel.myLocation ~= "game_Fishing3D" then
                            GameManager.GuideExitScene({gotoui="game_Fishing3DHall"})
                        else
                            PayPanel.Close()
                        end
                    end)
                    pre:SetButtonText(nil, "前  往")
                    return
                end
                if data.result ~= 0 then
                    HintPanel.ErrorMsg(data.result)
                end
            end
        )

	end
end