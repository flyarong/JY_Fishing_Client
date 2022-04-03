-- 创建时间:2019-12-04
-- Panel:VIPHintPanel
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

VIPHintPanel = basefunc.class()
local C = VIPHintPanel
C.name = "VIPHintPanel"

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
	if self.parm and self.parm.call then
		self.parm.call()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)
	self.parm = parm
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.BG_rect = self.BG_img.transform:GetComponent("RectTransform")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	self.ck_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnCKClick()
		self:MyExit()
	end)
	self.cw_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnCWClick()
		self:MyExit()
	end)
	self.qd_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnQDClick()
		self:MyExit()
	end)

	self.cw_txt.text = "升级VIP"

	self:MyRefresh()
end

function C:MyRefresh()
	if self.parm and self.parm.desc then
		self.desc_txt.text = self.parm.desc
	else
		self.desc_txt.text = "VIP等级不够"
	end
	if self.parm and self.parm.type then
		if self.parm.type == 1 then
			self.BG_rect.sizeDelta = {x = 1111, y = 560}
			self.ck_btn.transform.localPosition = Vector3.New(-206, -70, 0)
			self.cw_btn.transform.localPosition = Vector3.New(-206, -180, 0)
			self.qd_btn.gameObject:SetActive(true)
			self.qd_btn.transform.localPosition = Vector3.New(210, -180, 0)
			self.desc_txt.transform.localPosition = Vector3.New(0, 116, 0)
		else
		end
	else
		self.BG_rect.sizeDelta = {x = 1020, y = 456}
		self.qd_btn.gameObject:SetActive(false)
		self.ck_btn.transform.localPosition = Vector3.New(-206, -112, 0)
		self.cw_btn.transform.localPosition = Vector3.New(206, -112, 0)
		self.desc_txt.transform.localPosition = Vector3.New(0, 66, 0)
	end

	if VIPManager.is_on_off then
		self.ck_btn.gameObject:SetActive(false)
		self.cw_btn.transform.localPosition = Vector3.New(0, -112, 0)
	end
end

function C:OnCKClick()
	--GameManager.GotoUI({gotoui="vip", goto_scene_parm="VIP2"})
	VipShowTaskPanel2.Create()
	DSM.PushAct({info = {vip = "vip_ck"}})
end

function C:OnCWClick()
	if MainModel.UserInfo.ui_config_id == 1 and MainModel.UserInfo.vip_level < 1 then
		GameManager.GotoUI({gotoui="hall_activity", goto_scene_parm="panel"})
	else
		PayPanel.Create(GOODS_TYPE.jing_bi)
	end
	if self.parm and self.parm.cw_cb and type(self.parm.cw_cb) == "function" then
		self.parm.cw_cb()
	end
	DSM.PushAct({info = {vip = "vip_up"}})
end

function C:OnQDClick()
	if self.parm.call then
		self.parm.call()
	end
end
