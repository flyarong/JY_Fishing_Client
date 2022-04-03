-- 创建时间:2020-10-11
-- Panel:XZZXGiftPanel
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
XRZXGiftPanel = basefunc.class()
local C = XRZXGiftPanel
C.name = "XRZXGiftPanel"

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
    self.lister["AssetChange"] = basefunc.handler(self, self.MyRefresh)
    self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
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
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	
	self.buy_btn.onClick:AddListener(function ()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBuyGiftClick()
	end)


	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:ShowCurUI()
end

function C:OnBuyGiftClick()

	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.shopid).price
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(self.shopid, "￥" .. (price / 100))
    end
end

function C:ShowCurUI()
	
	if XRZXGiftManager.IsFinishBuyGift() then
   		self:MyExit()
   		Event.Brocast("ui_button_state_change_msg")
   		return
	end

	self.gift = {}
	self.gift = XRZXGiftManager.GetCurGiftInforByID()
	dump(self.gift,"<color=red>==============</color>")
	if self.gift then
		self.shopid = self.gift.gift_id
		self.lb_img.sprite = GetTexture(self.gift.box_image)
		--self.title_txt.text = self.gift.price.."元首充返利800%"
		self.js_txt.text = self.gift.name
		self.jg_txt.text = self.gift.price.."元购买"
		self.jl_img.sprite = GetTexture(self.gift.show_image)
		-- for i=1,3 do
			self.jl1_img.sprite = GetTexture(self.gift.jl1_image)
			self.jl2_img.sprite = GetTexture(self.gift.jl2_image)
			self.jl3_img.sprite = GetTexture(self.gift.jl3_image)

			self.jl1_txt.text = self.gift.jl1_number.."金币"
			self.jl2_txt.text = "冰冻x"..tostring(self.gift.jl2_number)
			self.jl3_txt.text = "锁定x"..tostring(self.gift.jl3_number)
		-- end
	end
end

function C:on_finish_gift_shop(id)
	if self.shopid == id  then
		self:MyRefresh()
	end
end
