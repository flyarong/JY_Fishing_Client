-- 创建时间:2020-09-22
-- Panel:Act_036_CJFBLBItemPanel
--[[
GE    ┌─┐       ┌─┐
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

Act_Ty_LB1ItemPanel = basefunc.class()
local C = Act_Ty_LB1ItemPanel
C.name = "Act_Ty_LB1ItemPanel"
local M = Act_Ty_LB1Manager

function C.Create(parent,b)
	return C.New(parent,b)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    --完成礼包购买
    self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,b)
	self.shop_id = b
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	

	local _tips1 = Act_Ty_LB1Manager.GetConfigByID(self.shop_id).tips[1]
	local _tips2 = Act_Ty_LB1Manager.GetConfigByID(self.shop_id).tips[2]
	
	if _tips1 ~= "" then
		PointerEventListener.Get(self.tps1_btn.gameObject).onDown = function ()
			self.ti1_img.gameObject:SetActive(true)
			self.js1_txt.text = _tips1
	    end
	    PointerEventListener.Get(self.tps1_btn.gameObject).onUp = function ()
	    	self.ti1_img.gameObject:SetActive(false)
	    end
	end
	if _tips2 ~= "" then
	    PointerEventListener.Get(self.tps2_btn.gameObject).onDown = function ()
			self.ti2_img.gameObject:SetActive(true)
			self.js2_txt.text = _tips2
	    end
	    PointerEventListener.Get(self.tps2_btn.gameObject).onUp = function ()
	    	self.ti2_img.gameObject:SetActive(false)
	    end
	end
	
	self.buy_btn.onClick:AddListener(
		function () 
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:BuyShop(self.shop_id)
		end
	)


	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	-- print("item背景名称"..M.cur_path.."bg_dk")
	SetTextureExtend(self.bg_img,M.cur_path.."bg_dk")
	SetTextureExtend(self.ti1_img,M.cur_path.."tc_1")
	SetTextureExtend(self.ti2_img,M.cur_path.."tc_1")
	self:MyRefresh()
end

function C:MyRefresh()
	self:StartTimer()
	self:ShowDiffUI()
	self:RefreshPos(self.shop_id)
	self:GetFinshGiftShowUI(self.shop_id)
end

function C:BuyShop(shopid)
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function C:ShowDiffUI()
	local config_shop = Act_Ty_LB1Manager.GetConfigByID(self.shop_id)
	dump(config_shop,"<color=red>xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</color>")
	if self.shop_id then
		self.lbname_txt.text = config_shop.title
		self.jg_txt.text = config_shop.jg.."领取"

		SetTextureExtend(self.bx_img,config_shop.bx_img)
		SetTextureExtend(self.yubi_img,config_shop.jl_img[1])
		SetTextureExtend(self.tips_img,config_shop.jl_img[2])

		-- self.bx_img.sprite = GetTexture(config_shop.bx_img)
		-- self.yubi_img.sprite = GetTexture(config_shop.jl_img[1])
		-- self.tips_img.sprite = GetTexture(config_shop.jl_img[2])
		self.number1_txt.text = config_shop.jl_number[1]
		self.number2_txt.text = config_shop.jl_number[2]
	end
end

function C:GetFinshGiftShowUI(shopid)
	local status = MainModel.GetGiftShopStatusByID(shopid)
	if IsEquals(self.gameObject) then
		if status == 1 then
			self.buy_btn.gameObject:SetActive(true)
			self.hui_img.gameObject:SetActive(false)
		else
			self.buy_btn.gameObject:SetActive(false)
			self.hui_img.gameObject:SetActive(true)
			self.jg_txt.text = "明日再来"
		end
	end
end

function C:on_finish_gift_shop(id)
	local shop_config = M.GetCurrShopIdList()
	for i=1,#shop_config do
		if id == shop_config[i] then
			self:MyRefresh()
		end
	end
end

function C:CreateTips()
	
end

function C:RefreshPos(shopid)
	local status = MainModel.GetGiftShopStatusByID(shopid)
	if status == 0 and IsEquals(self.gameObject) then
		self.gameObject.transform:SetAsLastSibling()
	end
end


function C:StartTimer()
	self:StopTimer()
	self.main_time = Timer.New(function ()
		if self.ti1_img.gameObject.activeSelf then
			self.ti1_img.gameObject:SetActive(false)
		end
		if self.ti2_img.gameObject.activeSelf then
			self.ti2_img.gameObject:SetActive(false)
		end
	end,3,-1) 
	self.main_time:Start()
end

function C:StopTimer()
	if self.main_time then
		self.main_time:Stop()
		self.main_time = nil
	end
end