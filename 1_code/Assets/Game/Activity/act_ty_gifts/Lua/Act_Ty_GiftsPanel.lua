-- 创建时间:2020-12-28
-- Panel:Template_NAME
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

Act_Ty_GiftsPanel = basefunc.class()
local C = Act_Ty_GiftsPanel
local M = Act_Ty_GiftsManager
C.name = "Act_Ty_GiftsPanel"

function C.Create(parent,gift_key)
	return C.New(parent,gift_key)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["finish_gift_shop"] = basefunc.handler(self, self.MyRefresh)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.MyRefresh)
	self.lister["act_fmt_gifts_panel_refresh"] = basefunc.handler(self, self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.huxi then
		CommonHuxiAnim.Stop(self.huxi)
	end
	self.huxi = nil
	Event.Brocast("ty_gift_enter_fresh")  ---第三次购买成功后入口按钮没有实时刷新，所以关闭时重新刷新一下
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
	self:RemoveListener()
	self:ClearGiftItem()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent,gift_key)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gift_key = gift_key

	self:UpdateCfg()

	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:UpdateCfg()
	self.cfg = M.GetGiftCfg(self.gift_key)
	self.style_path = M.GetGiftStyle(self.gift_key)
end

-- function C:UpdateData()
-- 	self.data = M.GetGiftData(self.gift_key)
-- end

function C:InitUI()
	self.back_btn.onClick:AddListener(function()
        self:MyExit()
    end)
	self.help_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
	)
	self.buy_all_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnBuyAllClick()
		end
	)
	self.huxi = CommonHuxiAnim.Start(self.buy_all_btn.gameObject,1)
    self:ResetRectList()
    self:RefreshBuyAllUI()
	self:InitGiftItem()
	if table_is_null(M.GetHelpInfo()) then
		self.help_btn.gameObject:SetActive(false)
	end
	SetTextureExtend(self.bg_img,self.style_path.."_".."bg_1")
	--self.bg_img.sprite = GetTexture(self.cfg.panel_bg)
	if self.cfg.panel_tit_icon then
		self.tit_img.gameObject:SetActive(true)
		self.tit_img.sprite = GetTexture(self.cfg.panel_tit_icon)
	else
		self.tit_img.gameObject:SetActive(false)
	end

	-- self.time_txt.text = self.cfg.time_txt
	-- self.desc_txt.text = self.cfg.desc_txt

	if self.cfg.time_txt_fmt then
		self:SetTxt(self.time_txt.transform,self.cfg.time_txt_fmt)
	end
	-- if self.cfg.desc_txt_fmt then
	-- 	self:SetTxt(self.desc_txt.transform,self.cfg.desc_txt_fmt)
	-- end

	--对应模板  {倒计时}显示方式
	if self.cfg.act_time and self.cfg.act_time ~="" then
		self.time_txt.text=self.cfg.act_time
	else
		self.cutdown_timer=CommonTimeManager.GetCutDownTimer(self.cfg.end_time,self.time_txt)
	end

	--对应模板 {重置时间}内容显示配置
	self.desc_txt.gameObject:SetActive(false)
	if self.cfg.restartTimeStr and self.cfg.restartTimeStr~="" then
		self.desc_txt.gameObject:SetActive(true)
	 	self.desc_txt.text=self.cfg.restartTimeStr
	end

	--对应模板 {礼包描述}内容显示
	if self.cfg.gift_describStr and self.cfg.gift_describStr~=""  then
		self.desc_2_txt.gameObject:SetActive(true)
		self.desc_2_txt.text=self.cfg.gift_describStr
	end
    --self:MyRefresh()
end
function C:OpenHelpPanel()
	local Help_Info = {}
	local help_config=M.GetHelpInfo() 
	for i=1,#help_config do
		Help_Info[#Help_Info + 1] =help_config[i].content
	end
	local DESCRIBE_TEXT
	DESCRIBE_TEXT = Help_Info
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform,"IllustratePanel_New")
end
function C:ResetRectList()
	self.rect_list = {}
	self.rect_list [1] = self.rect1
	self.rect_list [2] = self.rect2
	self.rect_list [3] = self.rect3
end

function C:InitGiftItem()
	self:ClearGiftItem()
	for i = 1, 3 do
		local pre = Act_Ty_GiftsItemBase.Create(self.rect_list[i],self.gift_key,i)
		if pre then
			self.item_cell_list[#self.item_cell_list + 1] = pre
		end
	end
end

function C:ClearGiftItem()
	if self.item_cell_list then
		for k,v in ipairs(self.item_cell_list) do
			v:MyExit()
		end
	end
	self.item_cell_list = {}
end

function C:RefreshGiftItem()
	if self.item_cell_list then
		for k,v in ipairs(self.item_cell_list) do
			v:MyRefresh()
		end
	end
end

function C:SetTxt(txt_trans, fmt_cfg)
	if #fmt_cfg >= 1 then
		txt_trans:GetComponent("Text").color = M.ColorToRGB(fmt_cfg[1])
	end

	local outline_com = txt_trans:GetComponent("Outline")
	if #fmt_cfg == 1 then
		if outline_com then
			destroy(outline_com)
		end
	end

	if #fmt_cfg == 2 then
		if not outline_com then
			outline_com =  txt_trans.gameObject:AddComponent(typeof(UnityEngine.UI.Outline))
		end
		outline_com.effectColor = M.ColorToRGB(fmt_cfg[2])
    end
end

function C:MyRefresh()

	self:UpdateCfg()

	if M.IsGiftActive(self.gift_key) then
		self:RefreshBuyAllUI()
		self:RefreshGiftItem()
	else
		self:MyExit()
	end
end

function C:OnBuyAllClick()
	local cfg = M.GetGiftItemCfg(self.gift_key)
	local shopid = cfg.buy_all_gift_id
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function C:RefreshBuyAllUI()
	local cfg = M.GetGiftItemCfg(self.gift_key)
	if cfg.buy_all_gift_id then
		self.buy_all_btn.gameObject:SetActive(self:CheckCanBuyAll())
		self.buy_all_btn_gray.gameObject:SetActive(not self:CheckCanBuyAll())
		self.buy_all_txt.text = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, cfg.buy_all_gift_id).price/100 .. "元 一键领取"
		self.buy_all_no_txt.text = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, cfg.buy_all_gift_id).price/100 .. "元 一键领取"
		self.buy_all_give_txt.text = "多送" .. cfg.buy_all_give[1]
	else
		self.buy_all_btn.gameObject:SetActive(false)
		self.buy_all_btn_gray.gameObject:SetActive(false)
	end
end

function C:CheckCanBuyAll()
	local cfg = M.GetGiftItemCfg(self.gift_key)
	local can_buy = MainModel.GetGiftShopStatusByID(cfg.buy_all_gift_id) == 1
	for k,v in pairs(cfg.gift_ids) do
		if MainModel.GetGiftShopStatusByID(v) ~= 1 then
			can_buy = false
		end
	end
	return can_buy
end