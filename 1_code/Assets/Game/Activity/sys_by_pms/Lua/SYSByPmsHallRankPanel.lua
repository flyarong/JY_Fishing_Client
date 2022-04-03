-- 创建时间:2020-05-15
-- Panel:SYSByPmsHallRankPanel
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

SYSByPmsHallRankPanel = basefunc.class()
local C = SYSByPmsHallRankPanel
C.name = "SYSByPmsHallRankPanel"

function C.Create(type,id)
	return C.New(type,id)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["SYSByPms_query_bullet_rank_data"] = basefunc.handler(self,self.RefreshRank)
    self.lister["SYSByPms_query_bullet_myrank_data"] = basefunc.handler(self,self.RefreshMyRank)
    self.lister["SYSByPms_query_bullet_rank_history_data"] = basefunc.handler(self,self.RefreshRank_yesterday)
    self.lister["SYSByPms_query_bullet_history_myrank_data"] = basefunc.handler(self,self.RefreshMyRank_yesterday)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseItemPrefab()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(type,id)
	self.type = type
	self.id = id
	self.page_index = 1
	local parent = GameObject.Find("Canvas/GUIRoot").transform
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
		self:OnBackClick()
	end)
	if self.type == "pms" then
		self.BG5_img.sprite = GetTexture("bs_imgf_pmphb")
		self.my_jiesuan_txt.text = "每日 24:00 结算"
		self.smhy_btn.gameObject:SetActive(true)
		self.hdbz_btn.gameObject:SetActive(true)
		self.cbhw_btn.gameObject:SetActive(true)
		self.ccmb_btn.gameObject:SetActive(true)
		self.smhy_btn.onClick:AddListener(function ()
		    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnOpenClick(1)
		end)
		self.hdbz_btn.onClick:AddListener(function ()
		    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnOpenClick(2)
		end)
		self.cbhw_btn.onClick:AddListener(function ()
		    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnOpenClick(3)
		end)
		self.ccmb_btn.onClick:AddListener(function ()
		    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnOpenClick(4)
		end)
		self.tag_btn_list = {}
		self.tag_img_list = {}
		self.tag_btn_list[#self.tag_btn_list + 1] = self.smhy_btn
		self.tag_btn_list[#self.tag_btn_list + 1] = self.hdbz_btn
		self.tag_btn_list[#self.tag_btn_list + 1] = self.cbhw_btn
		self.tag_btn_list[#self.tag_btn_list + 1] = self.ccmb_btn
		self.tag_img_list[#self.tag_img_list + 1] = self.smhy_img
		self.tag_img_list[#self.tag_img_list + 1] = self.hdbz_img
		self.tag_img_list[#self.tag_img_list + 1] = self.cbhw_img
		self.tag_img_list[#self.tag_img_list + 1] = self.ccmb_img

		self.tag_count = #self.tag_btn_list

		self.smhy_btn.gameObject:SetActive(false)
		self.smhy_img.gameObject:SetActive(true)
	elseif self.type == "hks" then
		self.BG5_img.sprite = GetTexture("vip4hksphb_bt_1")
		self.my_jiesuan_txt.text = ""
		self.bypm_btn.gameObject:SetActive(true)
		self.sypm_btn.gameObject:SetActive(true)
		self.bypm_btn.onClick:AddListener(function ()
		    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnOpen_hksClick(5,"by")
		end)
		self.sypm_btn.onClick:AddListener(function ()
		    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnOpen_hksClick(5,"sy")
		end)
		self.tag_btn_list = {}
		self.tag_img_list = {}
		self.tag_btn_list[5] = self.bypm_btn
		self.tag_btn_list[6] = self.sypm_btn
		self.tag_img_list[5] = self.bypm_img
		self.tag_img_list[6] = self.sypm_img

		self.tag_count = #self.tag_btn_list
	end
	self.spawn_cell_list = {}
	self.sv = self.ScrollView.transform:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		local VNP = self.sv.verticalNormalizedPosition
		if VNP <= 0 then
			self:RefreshRankInfo()		
		end
	end

	self:MyRefresh()
end

function C:MyRefresh()
	if self.type == "pms" then
		self.id = self.id or 1
		self:OnOpenClick(self.id)
	elseif self.type == "hks" then
		self.id = self.id or 5
		local tab = os.date("*t")
	    local target_month
	    local target_year
	    if tab.month + 1 <= 12 then
	        target_month = tab.month + 1
	        target_year = tab.year
	    else
	        target_month = 1
	        target_year = tab.year + 1
	    end
	    local temp = {year = target_year,month = target_month,day = 1,hour = 0,min = 0,sec = 0,isdst = false}
	    local temp2 = {year = tab.year,month = tab.month,day = 1,hour = 0,min = 0,sec = 0,isdst = false}
	    local begin_time = os.time(temp) - 86400
	    local end_time = os.time(temp)
	    local end_time2 = os.time(temp2)
	    if ((os.time() > begin_time) and (os.time() < end_time)) or ((os.time() > end_time2) and (os.time() < (end_time2 + 600))) then
			self:OnOpen_hksClick(5,"by")
		else
			self:OnOpen_hksClick(5,"sy")
		end
	end
end

function C:RefreshRank(data,type)
	if type == self.type then
		if data and #data > 0 then
			self:CreateItemPrefab(data)
			self.page_index = self.page_index + 1
		else
			LittleTips.Create("当前无新数据")
		end
	end
end

function C:RefreshMyRank(data,type)
	dump(data,"<color=red>++++++++++++++++++111++++++</color>")
	if type == self.type then
		if data then
			local award_list = SYSByPmsManager.GetPMSAwardCfgByRank(self.id,data.rank,self.type)
			if award_list then--玩家自己在榜上
				local item1 = GameItemModel.GetItemToKey(award_list[1].type)
				self.my_award_txt.text = item1.name..StringHelper.ToCash(award_list[1].num)
			--[[else--玩家自己未上榜
				self.my_rank_txt.gameObject:SetActive(false)
				self.rank_img.gameObject:SetActive(true)
				self.my_name_txt.text = MainModel.UserInfo.name
				self.my_score_txt.text = ""
				self.my_award_txt.text = "--"--]]
			end
			self.my_rank_txt.gameObject:SetActive(true)
			self.rank_img.gameObject:SetActive(false)
			self.my_rank_txt.text = "第 "..data.rank.." 名"
			self.my_name_txt.text = data.player_name
			if self.type == "pms" then
				self.my_score_txt.text = data.score
			elseif self.type == "hks" then
				self.my_score_txt.text = data.score / 100
			end
		else
			--初始化
			self.my_rank_txt.gameObject:SetActive(false)
			self.rank_img.gameObject:SetActive(true)
			self.my_name_txt.text = MainModel.UserInfo.name
			self.my_score_txt.text = ""
			self.my_award_txt.text = "--"
		end
	end
end

function C:OnBackClick()
	self:MyExit()
end

function C:CreateItemPrefab(data)
	for i=1,#data do
		local pre = SYSByPmsHallRankItem.Create(self.Content.transform, data[i],self.id,self.type)
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:OnOpenClick(id)
	self.id = id
	self.page_index = 1
	SYSByPmsManager.CloseRankData(self.type, id)
	self:CloseItemPrefab()
	self:RefreshRankInfo()
	for i=1, self.tag_count do
		if id == i then
			self.tag_btn_list[i].gameObject:SetActive(false)
			self.tag_img_list[i].gameObject:SetActive(true)
		else
			self.tag_btn_list[i].gameObject:SetActive(true)
			self.tag_img_list[i].gameObject:SetActive(false)
		end
	end
end

function C:OnOpen_hksClick(id, _type)
	self.id = id
	self.page_index = 1
	self._type = _type
	SYSByPmsManager.CloseRankData(self.type, id)
	self.tag_btn_list[5].gameObject:SetActive(self._type ~= "by")
	self.tag_img_list[5].gameObject:SetActive(self._type == "by")
	self.tag_btn_list[6].gameObject:SetActive(self._type ~= "sy")
	self.tag_img_list[6].gameObject:SetActive(self._type == "sy")
	self:RefreshMyRank(nil,self.type)
	self:CloseItemPrefab()
	self:RefreshRankInfo()
end

function C:RefreshRankInfo()
	if self.page_index > 1 then
	else
		if self._type == "by" then
			SYSByPmsManager.GetHallRank_data(self.type, self.id, self.page_index)
		elseif self._type == "sy" then
			SYSByPmsManager.GetHallYesterdayRank_data(self.type, self.id, self.page_index)
		end
	end
end

function C:RefreshRank_yesterday(data,type)
	if self.id == 5 then
		self:RefreshRank(data,type)
	end
end

function C:RefreshMyRank_yesterday(data,type)
	if self.id == 5 then
		self:RefreshMyRank(data,type)
	end
end