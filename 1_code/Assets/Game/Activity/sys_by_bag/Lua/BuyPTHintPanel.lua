-- 创建时间:2020-07-06
-- Panel:BuyPTHintPanel
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

BuyPTHintPanel = basefunc.class()
local C = BuyPTHintPanel
C.name = "BuyPTHintPanel"

function C.Create(parm)
	return C.New(parm)
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

function C:ctor(parm)
	self.parm = parm
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	self.close_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:MyExit()
    end)
    self.confirm_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnConfirmClick()
		self:MyExit()
    end)
	self:MyRefresh()
end

function C:MyRefresh()
	self.hint_info_txt.text = self.parm.buy_hint or self.parm.name
	self.confirm_txt.text = self.parm.buy_anniu_hint or "购  买"
end

function C:OnConfirmClick()
	local cfg = self.parm
	if cfg.use_parm then
		local gotoUI = {gotoui=cfg.use_parm[1], goto_scene_parm=cfg.use_parm[2]}
		if gotoUI.gotoui == "buyitem" then
			local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.item ,tonumber(gotoUI.goto_scene_parm), cfg.item_key)
			Network.SendRequest("pay_exchange_goods", {goods_type = goodsData.type, goods_id = goodsData.id}, "购买道具", function (data)
				dump(data)
                if data.result == 0 then
                	
                else
                    HintPanel.ErrorMsg(data.result)
                end
            end)
		elseif gotoUI.gotoui == "buygift" then
			local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, tonumber(gotoUI.goto_scene_parm))
			if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		        GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
		    else
		        PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
		    end
		else
			GameManager.GotoUI(gotoUI)
		end
	end
end