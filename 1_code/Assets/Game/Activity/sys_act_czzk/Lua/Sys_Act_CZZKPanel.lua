-- 创建时间:2020-07-27
-- Panel:Sys_Act_CZZKPanel
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

Sys_Act_CZZKPanel = basefunc.class()
local C = Sys_Act_CZZKPanel
C.name = "Sys_Act_CZZKPanel"
local M = Sys_Act_CZZKManager
function C.Create(parent,backcall,isShowClosebtn)
	return C.New(parent,backcall,isShowClosebtn)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["czzk_gift_has_buy_msg"] = basefunc.handler(self,self.on_czzk_gift_has_buy_msg)
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

function C:ctor(parent,backcall,isShowClosebtn)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.isShowClosebtn=isShowClosebtn
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
	EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.MyClose)
	self.close_btn.gameObject:SetActive(self.isShowClosebtn)

	self:MyRefresh()
	self.buy_txt.text = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, M.gift_id).price/100 .."元领取"
end

function C:MyRefresh()
	self.buy_btn.gameObject:SetActive(not M.CheckIsBoughtZK())
	self.buy_img.gameObject:SetActive(M.CheckIsBoughtZK())
	self.ylq.gameObject:SetActive(M.CheckIsBoughtZK())
	self.remain_txt.text = "剩余"..M.GetCurRemainDay().."天,每天可领:"
end


function C:on_BuyClick()
	self:BuyShop(M.gift_id)
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

function C:on_czzk_gift_has_buy_msg()
	self:MyRefresh()
end