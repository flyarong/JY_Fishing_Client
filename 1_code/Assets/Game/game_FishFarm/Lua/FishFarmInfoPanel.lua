-- 创建时间:2020-11-13
-- Panel:FishFarmInfoPanel
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

FishFarmInfoPanel = basefunc.class()
local C = FishFarmInfoPanel
C.name = "FishFarmInfoPanel"
local M = FishFarmManager

function C.Create(data)
	return C.New(data)
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
	self:StopTime()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(data)
	self.data = data

	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.rect_je_rect = self.rect_je.transform:GetComponent("RectTransform")
	self.rect_cz_rect = self.rect_cz.transform:GetComponent("RectTransform")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.sale_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnSaleClick()
	end)

	self.tool_data = M.GetObjToolData(self.data.obj_id)
	self.config = M.GetFishConfig(self.tool_data.fish_id)

	dump(self.tool_data)

	self:MyRefresh()
end

function C:MyRefresh()
	local award_list = M.GetSaleAwardByObjID(self.data.obj_id)
	local jb = 0
	for k,v in ipairs(award_list) do
		if v.asset_type == "jing_bi" then
			jb = jb + v.value
		end
	end
	self.sale_money_txt.text = StringHelper.ToCash(jb)

	self.fish_name_txt.text = self.config.name

	self.jb_txt.text = self.tool_data.jing_bi or 0
	self.xx_txt.text = self.tool_data.prop_fishbowl_stars or 0
	self.fish_img.sprite = GetTexture(self.config.icon)

	self:RefreshState()
	self:RefreshTime()
end

function C:StopTime()
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
end
function C:RefreshTime()
	self:StopTime()
	self.down_t = self.tool_data.hungry - os.time()
	if self.down_t <= 0 then
		self:UpdateUI()
	else
		self.update_time = Timer.New(function ()
			self.down_t = self.down_t - 1
	        self:UpdateUI()
	    end, 1, -1, nil, true)
		self.update_time:Start()
		self:UpdateUI()
	end
end
function C:UpdateUI()
	if self.down_t <= 0 then
		self.je_time_txt.text = "已饥饿"
	else
		local cfg = self.config.sum_stage_list[self.state]
		local percent = self.down_t / cfg.hunger_time
		if percent > 1 then
			percent = 1
		end
		self.je_time_txt.text = StringHelper.formatTimeDHMS3(self.down_t)
		self.rect_je_rect.sizeDelta = Vector2.New(258*percent, 22)
	end
end

function C:RefreshState()
	self.state = M.GetFishByState(self.config, self.tool_data.level)
	local cfg = self.config.sum_stage_list[self.state]
	self.jb_desc_txt.text = cfg.jb_produce_dec
	self.xx_desc_txt.text = cfg.xx_produce_dec
	self.feed_time_txt.text = cfg.feed_consume
	self.state_name_txt.text = "【" .. cfg.name .. "】"
	self.state_txt.text = self.tool_data.level .. "/" .. self.config.sum_stage


	local percent = self.tool_data.level / self.config.sum_stage
	if percent > 1 then
		percent = 1
	end
	self.rect_cz_rect.sizeDelta = Vector2.New(258*percent, 22)
end

function C:OnBackClick()
	self:MyExit()
end
function C:OnSaleClick()
	dump("OnSaleClick")
	Network.SendRequest("fishbowl_sale_obj",{obj_id = self.data.obj_id}, "", function(data)
		dump(data, "fishbowl_sale_obj")
	end)
	self:MyExit()
end
