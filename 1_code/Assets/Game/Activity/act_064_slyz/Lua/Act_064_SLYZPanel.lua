-- 创建时间:2021-11-01
-- Panel:Act_064_SLYZPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_064_SLYZPanel = basefunc.class()
local C = Act_064_SLYZPanel
C.name = "Act_064_SLYZPanel"
local M = Act_064_SLYZManager

function C.Create(callback)
	return C.New(callback)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["finish_gift_shop"] = basefunc.handler(self,self.on_finish_gift_shop)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.callback then
        self.callback = nil
    end
    if self.cutdown_timer then
        self.cutdown_timer:Stop()
    end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(callback)
	ExtPanel.ExtMsg(self)
    self.callback = callback
	local parent = GameObject.Find("Canvas/LayerLv3").transform
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
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
    EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.OnBuyClick)

    self.cutdown_timer = CommonTimeManager.GetCutDownTimer(PlayerPrefs.GetInt(MainModel.UserInfo.user_id..M.key..FishingModel.game_id,0),self.remain_txt,true,nil,nil,nil,"限时购买:")

	self:MyRefresh()
end

function C:MyRefresh()
    self.config = M.GetCurConfig()
    self.price_txt.text = self.config.price .. "元购买"
    for i=1,3 do
        self["award"..i.."_img"].sprite = GetTexture(self.config.award_img[i])
        self["award"..i.."_txt"].text = self.config.award_txt[i]
    end
    self.yb_img.sprite = GetTexture(self.config.award_txt[4])
    self.yb_img:SetNativeSize()
end

function C:OnBackClick()
    if self.callback then
        self.callback()
        self.callback = nil
    end
    self:MyExit()
end

function C:OnBuyClick()
    if self.config then
        local shopid = self.config.gift_id
        local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
        dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
        if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
            ServiceGzhPrefab.Create({desc="请前往公众号获取"})
        else
            PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
        end
    end
end

function C:on_finish_gift_shop(id)
    if id and id == self.config.gift_id then
        self:MyExit()
    end
end