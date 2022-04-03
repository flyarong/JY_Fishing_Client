-- 创建时间:2021-08-06
-- Panel:SYS_Exit_AskPanel
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

SYS_Exit_AskPanel = basefunc.class()
local C = SYS_Exit_AskPanel
C.name = "SYS_Exit_AskPanel"
local M = SYS_Exit_AskManager

local instance
function C.Create(callback)
    if instance then
        instance:MyExit()
    end
    instance = C.New(callback)
    return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["sys_exit_ask_gift_buy_msg"] = basefunc.handler(self,self.on_sys_exit_ask_gift_buy_msg)
    self.lister["sys_exit_ask_refresh_msg"] = basefunc.handler(self,self.on_sys_exit_ask_refresh_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    instance = nil
    self:CloseItem()
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
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
    EventTriggerListener.Get(self.goon_btn.gameObject).onClick = basefunc.handler(self, self.OnGoOnClick)
    EventTriggerListener.Get(self.run_btn.gameObject).onClick = basefunc.handler(self, self.OnRunClick)
    EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.OnBuyClick)
	self:MyRefresh()
end

function C:MyRefresh()
    local gift_config = M.GetGiftConfig()
    for k,v in pairs(gift_config) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            self.gift_id = v.gift_id
            self.price_txt.text = v.price .. "元购买"
            self.award_txt.text = v.des_txt
            break
        end
    end
    self:CreateItem()
end

function C:OnBackClick()
    self:MyExit()
end

function C:OnRunClick()
    if self.callback then
        self.callback()
        self.callback = nil
    end
    self:MyExit()
end

function C:OnGoOnClick()
    self:MyExit()
end

function C:OnBuyClick()
    if not self.gift_id then return end
    local shopid = self.gift_id
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function C:CreateItem()
    self:CloseItem()
    local config = M.GetCheckConfig()
    local count = 0
    for i=1,#config do
        if count < 2 and _G[config[i].manager] and _G[config[i].manager].CheckShowExitAsk then
            local data1,data2,data3 = _G[config[i].manager].CheckShowExitAsk(config[i].name_txt)
            if data1 then
                count = count + 1
                local pre = SYS_Exit_AskItemBase.Create(self.Content.transform,config[i],data2,data3,function ()
                    --self:MyExit()
                end)
                self.pre_cell[#self.pre_cell + 1] = pre
            end
        end
    end
end

function C:CloseItem()
    if self.pre_cell then
        for k,v in pairs(self.pre_cell) do
            v:MyExit()
        end
    end
    self.pre_cell = {}
end

function C:on_sys_exit_ask_gift_buy_msg()
    --self:MyExit()
end

function C:on_sys_exit_ask_refresh_msg()
    self:MyRefresh()
end