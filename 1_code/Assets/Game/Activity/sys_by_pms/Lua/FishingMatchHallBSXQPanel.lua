-- 创建时间:2020-05-07
-- Panel:FishingMatchHallBSXQPanel
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

FishingMatchHallBSXQPanel = basefunc.class()
local C = FishingMatchHallBSXQPanel
C.name = "FishingMatchHallBSXQPanel"
local M = SYSByPmsManager
function C.Create(index,panelSelf,pms_config)
	return C.New(index,panelSelf,pms_config)
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

function C:ctor(index,panelSelf,pms_config)
	dump(pms_config)
	self.index = index
	self.panelSelf = panelSelf
	self.config = SYSByPmsManager.GetPMSAwardByID(pms_config.id)
	self.sign_time_config = M.GetSignTimeConfig()
	self.pms_config = pms_config
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	dump(self.config,"++++++++++++++++++++++++++++++++++++++++++++")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	self.signup_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.panelSelf:OnSignupClick(self.index)
	end)
	self.tomorrow_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTomorrowClick()
	end)
	self.time_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTimeClick()
	end)

	self.where_txt.text = "比赛地:"..self.pms_config.game_type_name
	if self.config[1].max_score == -1 then
		self.need1_score_txt.text = "积分:"..self.config[1].min_score.."积分以上"
	else
		self.need1_score_txt.text = "积分:"..self.config[1].min_score.."~"..self.config[1].max_score
	end
	if self.config[2].max_score == -1 then
		self.need2_score_txt.text = "积分:"..self.config[2].min_score.."积分以上"
	else
		self.need2_score_txt.text = "积分:"..self.config[2].min_score.."~"..self.config[2].max_score
	end
	if self.config[3].max_score == -1 then
		self.need3_score_txt.text = "积分:"..self.config[3].min_score.."积分以上"
	else
		self.need3_score_txt.text = "积分:"..self.config[3].min_score.."~"..self.config[3].max_score
	end

	if #self.config[1].award_desc == 1 then
		self.awardbg11.gameObject:SetActive(true)
		self.award11_img.sprite = GetTexture(self.config[1].award_icon[1])
		self.award11_txt.text = self.config[1].award_desc[1]
	elseif #self.config[1].award_desc == 2 then
		self.awardbg11.gameObject:SetActive(true)
		self.awardbg12.gameObject:SetActive(true)
		self.award11_img.sprite = GetTexture(self.config[1].award_icon[1])
		self.award11_txt.text = self.config[1].award_desc[1]
		self.award12_img.sprite = GetTexture(self.config[1].award_icon[2])
		self.award12_txt.text = self.config[1].award_desc[2]
	else
	end
	if #self.config[2].award_desc == 1 then
		self.awardbg21.gameObject:SetActive(true)
		self.award21_img.sprite = GetTexture(self.config[2].award_icon[1])
		self.award21_txt.text = self.config[2].award_desc[1]
	elseif #self.config[2].award_desc == 2 then
		self.awardbg21.gameObject:SetActive(true)
		self.awardbg22.gameObject:SetActive(true)
		self.award21_img.sprite = GetTexture(self.config[2].award_icon[1])
		self.award21_txt.text = self.config[2].award_desc[1]
		self.award22_img.sprite = GetTexture(self.config[2].award_icon[2])
		self.award22_txt.text = self.config[2].award_desc[2]
	else
	end
	if #self.config[3].award_desc == 1 then
		self.awardbg31.gameObject:SetActive(true)
		self.award31_img.sprite = GetTexture(self.config[3].award_icon[1])
		self.award31_txt.text = self.config[3].award_desc[1]
	elseif #self.config[3].award_desc == 2 then
		self.awardbg31.gameObject:SetActive(true)
		self.awardbg32.gameObject:SetActive(true)
		self.award31_img.sprite = GetTexture(self.config[3].award_icon[1])
		self.award31_txt.text = self.config[3].award_desc[1]
		self.award32_img.sprite = GetTexture(self.config[3].award_icon[2])
		self.award32_txt.text = self.config[3].award_desc[2]
	else
	end

	self.item_index = SYSByPmsManager.CheckPMSIsCanSignup(self.pms_config.id).result
	self.pms_game_info = SYSByPmsManager.GetCurPMSGameInfo()
	self.ramain_time_txt.text = "剩余参赛次数:"..(self.pms_game_info.num or "")
	if self.item_index == -1 then--三种报名物品都不足
		self.enter_icon1_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.pms_config.enter_condi_itemkey[#self.pms_config.enter_condi_item_count]).image)
		self.enter_icon2_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.pms_config.enter_condi_itemkey[#self.pms_config.enter_condi_item_count]).image)
		self.enter_icon3_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.pms_config.enter_condi_itemkey[#self.pms_config.enter_condi_item_count]).image)
		self.enter_hint1_txt.text = StringHelper.ToCash(self.pms_config.enter_condi_item_count[#self.pms_config.enter_condi_item_count]).." 报名"
		self.enter_hint2_txt.text = StringHelper.ToCash(self.pms_config.enter_condi_item_count[#self.pms_config.enter_condi_item_count]).." 报名"
		self.enter_hint3_txt.text = StringHelper.ToCash(self.pms_config.enter_condi_item_count[#self.pms_config.enter_condi_item_count]).." 报名"
	elseif self.item_index == 0 then--免费报名类型
		self.enter_icon1_img.gameObject:SetActive(false)
		self.enter_icon2_img.gameObject:SetActive(false)
		self.enter_icon3_img.gameObject:SetActive(false)
		self.enter_hint1_txt.text = "免费报名"
		self.enter_hint2_txt.text = "免费报名"
		self.enter_hint3_txt.text = "免费报名"
	else--至少满足一种报名物品
		self.enter_icon1_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.pms_config.enter_condi_itemkey[self.item_index]).image)
		self.enter_icon2_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.pms_config.enter_condi_itemkey[self.item_index]).image)
		self.enter_icon3_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.pms_config.enter_condi_itemkey[self.item_index]).image)
		self.enter_hint1_txt.text = StringHelper.ToCash(self.pms_config.enter_condi_item_count[self.item_index]).." 报名"
		self.enter_hint2_txt.text = StringHelper.ToCash(self.pms_config.enter_condi_item_count[self.item_index]).." 报名"
		self.enter_hint3_txt.text = StringHelper.ToCash(self.pms_config.enter_condi_item_count[self.item_index]).." 报名"
	end
	
	self:MyRefresh()
	self:StartSignTimer(true)
end

function C:MyRefresh()
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