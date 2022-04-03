-- 创建时间:2020-09-14
-- Panel:Act_Ty_ZP1GiftPrefab
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

Act_Ty_ZP1GiftPrefab = basefunc.class()
local C = Act_Ty_ZP1GiftPrefab
C.name = "Act_Ty_ZP1GiftPrefab"
local M = Act_Ty_ZP1Manager
function C.Create(parent, panelSelf, gift_id)
	return C.New(parent, panelSelf, gift_id)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["finish_gift_shop"] = basefunc.handler(self, self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ClearCellList()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, panelSelf, gift_id)
	self.panelSelf = panelSelf
	self.gift_id = gift_id
	self.config = M.GetGiftConfigById(gift_id)

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
	self.get_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBuyClick(self.config.gift_id)
    end)

	self:CreateAwardPrefab()

	self.get_txt.text = self.config.name

	self:MyRefresh()
end

function C:MyRefresh()

	local n = MainModel.GetRemainTimeByShopID( self.gift_id )
	if IsEquals(self.gameObject) then
		
		self.tj.gameObject:SetActive(self.config.Isrecommended == 1)--是否推荐

		local xg = self.config.Isindefinitely == 1
		if xg then
			-- body
			self.get_btn.gameObject:SetActive(n > 0)
			self.no_get.gameObject:SetActive(n <= 0)
		else	
			self.get_btn.gameObject:SetActive(true)
			self.no_get.gameObject:SetActive(false)
		end
		
	
	end
end

function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:OnBuyClick(id)
	local iscanbuy=M.ChargeBuyTime()
	if not iscanbuy then
		-- body
		return
	end
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
	local status = MainModel.GetGiftShopStatusByID(gift_config.id)
    local b1 = MathExtend.isTimeValidity(gift_config.start_time, gift_config.end_time)

---功能修改   是否能够一直购买
	local xg = self.config.Isindefinitely == 1
	if xg then--是否限购
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
	end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
	end
end

function C:UpdateData(index)
	self:MyRefresh()
	self.transform:SetSiblingIndex(index)
end

function C:CreateAwardPrefab()
	self.CellList = {}
	for i=1, #self.config.pay_name do
		local t = {icon=self.config.pay_icon[i], desc=self.config.pay_name[i]}
		local pre = AwardPrefab.Create(self["jl_node"..i], t, "AwardPrefab3")
		if self.config.tips and not table_is_null(self.config.tips) then
			local ts = self.config.tips[i] ~= ""
			local tip_btn = pre.transform:Find("tip_btn")
			pre.transform:Find("tips/tips_txt").transform:GetComponent("Text").text = self.config.tips[i]
			tip_btn.gameObject:SetActive(ts)
			if ts then--是否提示
				EventTriggerListener.Get(tip_btn.gameObject).onDown = function ()
					pre.transform:Find("tips").gameObject:SetActive(true)
				end
				EventTriggerListener.Get(tip_btn.gameObject).onUp = function ()
					pre.transform:Find("tips").gameObject:SetActive(false)
				end
			end
		end

		self.CellList[#self.CellList + 1] = pre
	end
end