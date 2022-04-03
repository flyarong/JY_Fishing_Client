-- 创建时间:2020-04-24
-- Panel:FishingMatchHallPMSItem
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

FishingMatchHallPMSItem = basefunc.class()
local C = FishingMatchHallPMSItem
C.name = "FishingMatchHallPMSItem"
local M = SYSByPmsManager
function C.Create(parent_transform, config, panelSelf, index)
	return C.New(parent_transform, config, panelSelf, index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopSignTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end
function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent_transform, config, panelSelf, index)
	self.config = config
	self.panelSelf = panelSelf
	self.index = index
	self.pms_game_info = SYSByPmsManager.GetCurPMSGameInfo()
	self.sign_time_config = M.GetSignTimeConfig()
	dump(self.pms_game_info,"<color=red>+++++++++++++++pms_game_info++++++++++++++</color>")
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	CommonHuxiAnim.Start(self.signup_btn.gameObject,1)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.my_rank_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnOpenPmsRankClick()
	end)
	self.signup_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnSignupClick()
	end)
	self.open_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnOpenClick()
	end)
	self.tomorrow_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTomorrowClick()
	end)
	self.time_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTimeClick()
	end)

	for i=1,#self.pms_game_info.my_rank_data do
		if self.pms_game_info.my_rank_data[i].id == self.config.id then
			if self.pms_game_info.my_rank_data[i].rank <= 0 then
				self.rank2_img.gameObject:SetActive(true)
			else
				self.rank1_img.gameObject:SetActive(true)
				self.my_rank_txt.gameObject:SetActive(true)
				self.my_rank_txt.text = self.pms_game_info.my_rank_data[i].rank
			end
		end
	end

	self.title_txt.text = self.config.game_name
	self.level_txt.text = self.config.game_type_name

	if #self.config.award_desc == 1 then 
		self.awardbg1.gameObject:SetActive(true)
		self.award11_txt.text = self.config.award_desc[1]
		self.award11_img.sprite = GetTexture(self.config.award_icon[1])
	elseif #self.config.award_desc == 2 then
		self.awardbg1.gameObject:SetActive(true)
		self.awardbg2.gameObject:SetActive(true)
		self.award11_txt.text = self.config.award_desc[1]
		self.award11_img.sprite = GetTexture(self.config.award_icon[1])
		self.award12_txt.text = self.config.award_desc[2]
		self.award12_img.sprite = GetTexture(self.config.award_icon[2])
	else
	end

	


	self.item_index = SYSByPmsManager.CheckPMSIsCanSignup(self.config.id).result
	if self.item_index == -1 then--三种报名物品都不足
		self.enter_icon1_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.config.enter_condi_itemkey[#self.config.enter_condi_item_count]).image)
		self.enter_icon2_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.config.enter_condi_itemkey[#self.config.enter_condi_item_count]).image)
		self.enter_icon3_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.config.enter_condi_itemkey[#self.config.enter_condi_item_count]).image)
		self.enter_hint1_txt.text = StringHelper.ToCash(self.config.enter_condi_item_count[#self.config.enter_condi_item_count]).." 报名"
		self.enter_hint2_txt.text = StringHelper.ToCash(self.config.enter_condi_item_count[#self.config.enter_condi_item_count]).." 报名"
		self.enter_hint3_txt.text = StringHelper.ToCash(self.config.enter_condi_item_count[#self.config.enter_condi_item_count]).." 报名"
	elseif self.item_index == 0 then--免费报名类型
		self.enter_icon1_img.gameObject:SetActive(false)
		self.enter_icon2_img.gameObject:SetActive(false)
		self.enter_icon3_img.gameObject:SetActive(false)
		self.enter_hint1_txt.text = "免费报名"
		self.enter_hint2_txt.text = "免费报名"
		self.enter_hint3_txt.text = "免费报名"
	else--至少满足一种报名物品
		self.enter_icon1_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.config.enter_condi_itemkey[self.item_index]).image)
		self.enter_icon2_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.config.enter_condi_itemkey[self.item_index]).image)
		self.enter_icon3_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.config.enter_condi_itemkey[self.item_index]).image)
		self.enter_hint1_txt.text = StringHelper.ToCash(self.config.enter_condi_item_count[self.item_index]).." 报名"
		self.enter_hint2_txt.text = StringHelper.ToCash(self.config.enter_condi_item_count[self.item_index]).." 报名"
		self.enter_hint3_txt.text = StringHelper.ToCash(self.config.enter_condi_item_count[self.item_index]).." 报名"
	end
	self:MyRefresh()
	self:RefreshTJ()
	self:StartSignTimer(true)
end

function C:MyRefresh()
	self.title_txt.text = self.config.game_name or "Nil"
end

function C:OnOpenClick()
	self.panelSelf:OnOpenClick(self.index,self.item_index)
end
function C:OnSignupClick()
	self.panelSelf:OnSignupClick(self.index,self.item_index)
end


function C:OnOpenPmsRankClick()
	SYSByPmsHallRankPanel.Create("pms",self.index)
end

function C:RefreshTJ()
	dump({id = SYSByPmsManager.GetTJGameID(),index= self.index})
	if (SYSByPmsManager.GetTJGameID() - 1) == self.index then
		self.tj.gameObject:SetActive(true)
	else
		self.tj.gameObject:SetActive(false)
	end
end


function C:StartSignTimer(b)
	self:StopSignTimer()
	if b then
		self:RefreshBtn()
		self.signTimer = Timer.New(function ()
			self:RefreshBtn()
		end,1,-1)
		self.signTimer:Start()
	end
end

function C:StopSignTimer()
	if self.signTimer then
		self.signTimer:Stop()
		self.signTimer = nil
	end
end

function C:RefreshBtn()
	local h = os.date("%H", os.time())
	local f = os.date("%M", os.time())
	local m = os.date("%S", os.time())
	local cur_all = h*3600 + f*60 + m
	if cur_all >= self.sign_time_config[#self.sign_time_config].timestamp_max and cur_all <= 86400 then--明日开赛
		self:Refresh2Btn2("tomorrow")
		return
	end
	for i=1,#self.sign_time_config do
		if self.sign_time_config[i].timestamp_min >= cur_all then--倒计时
			self:Refresh2Btn2("time")
			local count = self.sign_time_config[i].timestamp_min - cur_all
			local ff = math.floor(count / 60)
			local mm = count - ff * 60
			self.time_txt.text = string.format("%02d:%02d",ff,mm)
			return
		elseif self.sign_time_config[i].timestamp_min < cur_all and self.sign_time_config[i].timestamp_max > cur_all then--立刻参赛
			self:Refresh2Btn2("now")
			return
		end
	end
end

function C:Refresh2Btn2(type)
	self.tomorrow_btn.gameObject:SetActive(type == "tomorrow")
	self.tomorrow_txt.gameObject:SetActive(type == "tomorrow")
	self.time_btn.gameObject:SetActive(type == "time")
	self.time_txt.gameObject:SetActive(type == "time")
	self.signup_btn.gameObject:SetActive(type == "now" and self.pms_game_info.num > 0)
	self.cant_signup_img.gameObject:SetActive(type == "now" and self.pms_game_info.num <= 0)
end

function C:OnTomorrowClick()
	SYSByPmsGameRulesPanel.Create("pms")
end

function C:OnTimeClick()
	LittleTips.Create("即将开赛!")
end