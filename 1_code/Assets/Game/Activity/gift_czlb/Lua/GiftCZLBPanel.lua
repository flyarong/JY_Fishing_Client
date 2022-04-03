-- 创建时间:2020-08-07
-- Panel:GiftCZLBPanel
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

GiftCZLBPanel = basefunc.class()
local C = GiftCZLBPanel
C.name = "GiftCZLBPanel"
local M = GiftCZLBManager

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
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["gift_czlb_gift_bag_data_change_msg"] = basefunc.handler(self, self.RefreshTag)
    self.lister["gift_czlb_gift_bag_data_finish_msg"] = basefunc.handler(self, self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseTagList()
	self:CloseTagList()
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
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.buy_img = self.buy_btn.transform:GetComponent("Image")
	self.buy_outline = self.buy_txt.transform:GetComponent("Outline")
	self.buy_btn.gameObject:SetActive(false)
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBackClick()
	end)
	self.buy_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBuyClick()
	end)
	self.czlb_list = M.GetGradeList()
	self.czlb_map = {}
	for k,v in ipairs(self.czlb_list) do
		self.czlb_map[v.id] = v
	end
	M.QueryGiftBagData()
end

function C:MyRefresh()
	self.buy_btn.gameObject:SetActive(true)
	self.select_id = self.czlb_list[1].id

	self:RefreshTag()
end

function C:RefreshTag()
	self.gifts_cfg = self.czlb_map[self.select_id]
	self:RefreshRight()
	self:RefreshLeft()

	local id = M.GetTagCanBuyGiftID(self.select_id)
	if id then
		self.buy_img.sprite = GetTexture("ty_btn_huang1")
		self.buy_txt.text = "立即购买"
		self.buy_outline.effectColor = COLOR_HuangS_Outline
	else
		self.buy_img.sprite = GetTexture("ty_btn_ywc")
		self.buy_txt.text = "明日购买"
		self.buy_outline.effectColor = COLOR_HuiS_Outline
	end
end

function C:RefreshLeft()
	if not self.TagCell then
		self.TagCell = {}
		for k,v in ipairs(self.czlb_list) do
			local pre = GiftCZLBTagPrefab.Create(self.content_l, v, self.OnTagClick, self)
			self.TagCell[#self.TagCell + 1] = pre
		end
	end

	for i = 1, #self.TagCell do
		if self.TagCell[i].config.id == self.select_id then
			self.TagCell[i]:SetSelect(true)
		else
			self.TagCell[i]:SetSelect(false)
		end
	end
end
function C:CloseTagList()
	if self.TagCell then
		for i = 1, #self.TagCell do
			self.TagCell[i]:OnDestroy()
		end
	end
end
function C:RefreshRight()
	self:CloseAwardList()

	local cur_i = M.GetTagBuyDay(self.select_id)

	for k,v in ipairs(self.gifts_cfg.gift_ids) do
		local gift = M.GetGiftConfig(v)
		for k1,v1 in ipairs(gift.award) do
			local dd = {}
			if k == 1 then
				dd.bg = "mrcjlb_bg_8"
			elseif k == 2 then
				dd.bg = "mrcjlb_bg_10"
			else
				dd.bg = "mrcjlb_bg_9"
			end
			dd.icon_img = v1.icon_img
			dd.name = v1.pay_name
			dd.tips = v1.tips
			local pre = GiftCZLBAwardPrefab.Create(self["award" .. k .. "_node"], dd, nil, self)
			self.AwardCell[#self.AwardCell + 1] = pre
			if k ~= cur_i then
				self["ground" .. k .. "_img"].gameObject:SetActive(true)
			else
				self["ground" .. k .. "_img"].gameObject:SetActive(false)
			end
		end
	end
end
function C:CloseAwardList()
	if self.AwardCell then
		for k,v in ipairs(self.AwardCell) do
			v:OnDestroy()
		end
	end
	self.AwardCell = {}
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnBuyClick()
	local id = M.GetTagCanBuyGiftID(self.select_id)
	if not id then
		self:RefreshTag()
		LittleTips.Create("请明日再来购买！")
		return
	end

	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
	local status = MainModel.GetGiftShopStatusByID(gift_config.id)
    local b1 = MathExtend.isTimeValidity(gift_config.start_time, gift_config.end_time)

    if b1 then
		if status ~= 1 then
			local s1 = os.date("%m月%d日%H点", gift_config.start_time)
			local e1 = os.date("%m月%d日%H点", gift_config.end_time)
			HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。",s1,e1))
			return
		end
    else
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
    end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
	end
end

function C:OnTagClick(cfg)
	self.select_id = cfg.id
	self:RefreshTag()
end
