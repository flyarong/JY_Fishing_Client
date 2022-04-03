-- 创建时间:2021-01-11
-- Panel:Act_Ty_QJD1GiftItemBase
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

Act_Ty_QJD1GiftItemBase = basefunc.class()
local C = Act_Ty_QJD1GiftItemBase
C.name = "Act_Ty_QJD1GiftItemBase"
local M = Act_Ty_QJD1Manager

function C.Create(parent,index,config)
	return C.New(parent,index,config)
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

function C:ctor(parent,index,config)
	self.index = index
	self.config = config
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
	EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.OnBuyClick)
	self.buy_txt.text = self.config.price.."元领取"
	self:MyRefresh()
end

function C:MyRefresh()
	self:CreateAwardItem()
end

function C:OnBuyClick()
	M.BuyGift(self.config.gift_id)
end

function C:CreateAwardItem()
	for i=1,#self.config.award_txt do
		local pre = GameObject.Instantiate(self.item,self.item_node.transform)
		pre.gameObject:SetActive(true)
		pre.transform:Find("@award_img").transform:GetComponent("Image").sprite = GetTexture(self.config.award_img[i])
		pre.transform:Find("@award_txt").transform:GetComponent("Text").text = self.config.award_txt[i]
		local ts = self.config.award_tips[i] ~= ""
		local btn = pre.transform:Find("@tip_btn").gameObject
		btn.gameObject:SetActive(ts)
		if ts then
			pre.transform:Find("@tip_txt").transform:GetComponent("Text").text = self.config.award_tips[i]
			EventTriggerListener.Get(btn.gameObject).onDown = function ()
				pre.transform:Find("tip").gameObject:SetActive(true)
			end
			EventTriggerListener.Get(btn.gameObject).onUp = function ()
				pre.transform:Find("tip").gameObject:SetActive(false)
			end
		end
	end
end
