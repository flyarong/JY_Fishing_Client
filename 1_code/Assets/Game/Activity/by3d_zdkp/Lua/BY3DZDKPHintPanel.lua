-- 创建时间:2020-08-03
-- Panel:BY3DZDKPHintPanel
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

BY3DZDKPHintPanel = basefunc.class()
local C = BY3DZDKPHintPanel
C.name = "BY3DZDKPHintPanel"
local M = BY3DZDKPManager

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
	self.back_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	self.ad_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnADClick()
		self:MyExit()
	end)
	self.pay_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnPayClick()
		self:MyExit()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	local n = M.GetCount()
	if n <= 0 then
		self.ad_btn.gameObject:SetActive(false)
		self.ad_no.gameObject:SetActive(true)
	else
		self.ad_btn.gameObject:SetActive(true)
		self.ad_no.gameObject:SetActive(false)
	end
	self.ad_hint_txt.text = "今日还可试用：<color=#FF3F25>" .. n .. "</color>次"
end

function C:OnADClick()
	AdvertisingManager.RandPlay("zdkp", nil, function ()
		Event.Brocast("zdkp_sy_gun_auto_msg")
	end)
end

function C:OnPayClick()
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end