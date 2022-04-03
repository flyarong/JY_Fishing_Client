-- 创建时间:2020-05-18
-- Panel:Act_028_XYCDItemBase
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

Act_028_XYCDItemBase = basefunc.class()
local C = Act_028_XYCDItemBase
C.name = "Act_028_XYCDItemBase"

function C.Create(parent,data)
	return C.New(parent,data)
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

function C:ctor(parent,data)
	self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.ani_blue = self.blue_btn.transform:GetComponent("Animator")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.blue_btn.gameObject).onClick = basefunc.handler(self, self.sun_is_enough2buy)
	EventTriggerListener.Get(self.yellow_btn.gameObject).onClick = basefunc.handler(self, self.sun_is_no_enough)
	self.tips_btn.onClick:AddListener(function()
		self:on_tipsClick()
	end)

	if self.data.gift_id == 10292 or self.data.gift_id == 10297 then
		if Act_028_XYCDManager.GetSunCount() >= 1 then
			self.finger.gameObject:SetActive(true)
		end
		self.yellow_btn.gameObject:SetActive(false)
		CommonHuxiAnim.Start(self.blue_btn.gameObject,1,1,1.1)
		--self.ani_blue:Play("blue_btn_ani",-1,0)
	end

	if  Act_028_XYCDManager.GetSunCount() >= tonumber(self.data.sun_cost_text) then
		self.yellow_btn.gameObject:SetActive(false)
		CommonHuxiAnim.Start(self.blue_btn.gameObject,1,1,1.1)
		--self.ani_blue:Play("blue_btn_ani",-1,0)
	end
	self.eggs_name_img.sprite = GetTexture(self.data.eggs_name)
	self.eggs_award_img.sprite = GetTexture(self.data.eggs_award_text)
	self.eggs_award_img:SetNativeSize()
	self.eggs_image_img.sprite = GetTexture(self.data.eggs_image)
	self.sun_cost_text_txt.text = self.data.sun_cost_text
	self.blue_txt.text = self.data.button_text
	self.yellow_txt.text = self.data.button_text
	self.eggs_nameBG_img.sprite = GetTexture(self.data.eggs_nameBG)
	if self.data.gift_id ~= 10292 and self.data.gift_id ~= 10297 then
		if Act_028_XYCDManager.GetSunCount() < tonumber(self.data.sun_cost_text) then
			if self.data.remain_time > 0 then
				self.blue_btn.gameObject:SetActive(false)
				self.yellow_btn.gameObject:SetActive(true)
			else
				self.blue_btn.gameObject:SetActive(false)
				self.yellow_btn.gameObject:SetActive(false)
			end
		else
			if self.data.remain_time > 0 then
				self.blue_btn.gameObject:SetActive(true)
				CommonHuxiAnim.Start(self.blue_btn.gameObject,1,1,1.1)
				--self.ani_blue:Play("blue_btn_ani",-1,0)
				self.yellow_btn.gameObject:SetActive(false)
			else
				self.blue_btn.gameObject:SetActive(false)
				self.yellow_btn.gameObject:SetActive(false)
			end
		end
	end


	self:MyRefresh()
end

function C:MyRefresh()
end


function C:sun_is_no_enough()
	HintPanel.Create(1, "阳光能量不足")
end


function C:sun_is_enough2buy()
	if self.data.gift_id == 10292 or self.data.gift_id == 10297 then
		self:Type_ID1()
	else
		self:BuyShop(self.data.gift_id)
	end
end

function C:Type_ID1()
	dump(self.data,"体验彩蛋")
	if Act_028_XYCDManager.GetSunCount() < tonumber(self.data.sun_cost_text) then
		local panel = HintPanel.Create(1, "阳光能量不足", function()
			--self:GotoMiniGame()
		end)
		panel:SetButtonText("前往")
	else
		self:Pay4Free(self.data.gift_id)
	end
end


function C:GotoMiniGame()
    GameManager.GuideExitScene({gotoui = "game_Fishing3DHall"})
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


function C:Pay4Free(shopid)
	goodsid = shopid
	local request = {}
    request.goods_id = goodsid
    request.channel_type = "weixin"
    request.geturl = MainModel.pay_url and "n" or "y"
    request.convert = self.convert
    dump(request, "<color=green>创建订单</color>")
    Network.SendRequest(
        "create_pay_order",
        request,
        function(_data)
            dump(_data, "<color=green>返回订单号</color>")
            if _data.result == 0 then
                MainModel.pay_url = _data.url or MainModel.pay_url
                local url = string.gsub(MainModel.pay_url, "@order_id@", _data.order_id)
            else
                HintPanel.ErrorMsg(_data.result)
            end
        end
    )
end

function C:on_tipsClick()
	LittleTips.Create("孵化"..self.data.eggs_award_desc)
end