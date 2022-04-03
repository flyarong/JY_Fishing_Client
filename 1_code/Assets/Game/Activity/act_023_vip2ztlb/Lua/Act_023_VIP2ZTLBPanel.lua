-- 创建时间:2020-07-27
-- Panel:Act_023_VIP2ZTLBPanel
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

Act_023_VIP2ZTLBPanel = basefunc.class()
local C = Act_023_VIP2ZTLBPanel
C.name = "Act_023_VIP2ZTLBPanel"
local M = Act_023_VIP2ZTLBManager
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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
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
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.config = M.GetConfig()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.on_BuyClick)
	EventTriggerListener.Get(self.tips_btn.gameObject).onDown = basefunc.handler(self, self.on_TipsDown)
	EventTriggerListener.Get(self.tips_btn.gameObject).onUp = basefunc.handler(self, self.on_TipsUp)

	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cpl_cjj", is_on_hint = true}, "CheckCondition")
    if a and  b then
       self.tips_btn.gameObject:SetActive(false)
    end
	self:MyRefresh()
	--[[for i=1,#self.config.award_img do
		self["award"..i].gameObject:SetActive(true)
		self["award"..i.."_img"].sprite = GetTexture(self.config.award_img[i])
		self["award"..i.."_txt"].text = self.config.award_txt[i]
	end--]]
	self.buy_txt.text = self.config.price.."元领取"
end

function C:MyRefresh()
end


function C:on_BuyClick()
	self:BuyShop(self.config.gift_id)
end

function C:on_TipsDown()
	self.tips.gameObject:SetActive(true)
end

function C:on_TipsUp()
	self.tips.gameObject:SetActive(false)
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