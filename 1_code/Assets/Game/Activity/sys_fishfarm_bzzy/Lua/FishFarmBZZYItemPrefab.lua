-- 创建时间:2020-11-22
-- Panel:FishFarmBZZYItemPrefab
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

FishFarmBZZYItemPrefab = basefunc.class()
local C = FishFarmBZZYItemPrefab
C.name = "FishFarmBZZYItemPrefab"

function C.Create(parent, infor)
	return C.New(parent, infor)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.MyRefresh)
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

function C:ctor(parent, infor)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.infor = infor
	dump(self.infor,"<color=red>========================</color>")
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.id = self.infor.id
	self.type = self.infor.type
	self.buy_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:BuyShop()
			end
		)
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshUI()
end

function C:RefreshUI()
	if not self.infor then return end
	self.fish_img.sprite = GetTexture(self.infor.ui.image)
	self.name_txt.text = self.infor.ui.name
	if self.infor.price[1] == "jing_bi" then
		self.type_img.sprite = GetTexture("szzg_iocn_yb")
	elseif self.infor.price[1] == "prop_fishbowl_stars" then
		self.type_img.sprite = GetTexture("szg_iocn_xx")
	else

	end
	self.jg_txt.text = StringHelper.ToCash(self.infor.price[2])
	self.sl_txt.text = "x"..self.infor.weight
	--打折
	if self.infor.type == 2 then
		self.dz.gameObject:SetActive(true)
	else
		self.dz.gameObject:SetActive(false)
	end

	--当前资产不满足当前物品购买条件
	local xx = GameItemModel.GetItemCount("prop_fishbowl_stars")
	local jb = MainModel.UserInfo.jing_bi

	--取当前类型所需的资产要求
	if not self.infor.is_buy then
		if self.infor.price[1] == "prop_fishbowl_stars" then
			if xx < self.infor.price[2]  then
				--self.ts.gameObject:SetActive(true)
				self.jg_txt.transform:GetComponent("Text").color = Color.New(1,0,0,1)
			else
				--self.ts.gameObject:SetActive(false)
			end
		else
			if self.infor.price[1] == "jing_bi" then
				if jb < self.infor.price[2] then
					--self.ts.gameObject:SetActive(true)
					self.jg_txt.transform:GetComponent("Text").color = Color.New(1,0,0,1)
				else
					--self.ts.gameObject:SetActive(false)
				end
			else

			end
		end
	end
	self.had.gameObject:SetActive(self.infor.is_buy)
end


function C:BuyShop()
	--用钱购买的道具
	if self.infor.price[1] ~= "prop_fishbowl_stars" and self.infor.price[1] ~= "jing_bi" then
		local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.id).price
	    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
	        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	    else
	        PayTypePopPrefab.Create(self.infor.id, "￥" .. (price / 100))
	    end
    else
    	dump({type = self.type, id = self.id},"<color=red>xxxxxxxxxxxxxfishbowl_shop_buyxxxxxxxxxxxxxxxxx</color>")
    	--用水族馆或者金币购买
	 	Network.SendRequest("fishbowl_shop_buy", {type = self.type, id = self.id}, "请求数据", function (data)
	 		dump(data)
	 		if data.result == 0 then
				self:MyRefresh()
			else
				if self.infor.price[1] == "prop_fishbowl_stars" then
					LittleTips.Create("当前星星不足，养鱼和售卖鱼苗获得星星")
				else
					HallLogic.gotoPay()
				end
			end
	 	end)
 	end
end
