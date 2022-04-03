-- 创建时间:2020-05-15
-- Panel:SYSByPmsHallYesterdayRankPanel
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

SYSByPmsHallYesterdayRankPanel = basefunc.class()
local C = SYSByPmsHallYesterdayRankPanel
C.name = "SYSByPmsHallYesterdayRankPanel"

function C.Create(id)
	return C.New(id)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["SYSByPms_query_bullet_rank_history_data"] = basefunc.handler(self,self.RefreshRank)
    self.lister["SYSByPms_query_bullet_history_myrank_data"] = basefunc.handler(self,self.RefreshMyRank)
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

function C:ctor(id)
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
	self.id = self.id or 1
	self:OnOpenClick(self.id)
end

function C:RefreshRank(data)
	if data and #data > 0 then
		self:CreateItemPrefab(data)
		self.page_index = self.page_index + 1
	else
		LittleTips.Create("当前无新数据")
	end
end

function C:RefreshMyRank(data)
	dump(data,"<color=red>++++++++++++++++++111++++++</color>")
	if data then
		local award_list = SYSByPmsManager.GetPMSAwardCfgByRank(self.id,data.rank,"pms")
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
		self.my_score_txt.text = data.score
	else
		--初始化
		self.my_rank_txt.gameObject:SetActive(false)
		self.rank_img.gameObject:SetActive(true)
		self.my_name_txt.text = MainModel.UserInfo.name
		self.my_score_txt.text = ""
		self.my_award_txt.text = "--"
	end
end

function C:OnBackClick()
	self:MyExit()
end

function C:CreateItemPrefab(data)
	for i=1,#data do
		local pre = SYSByPmsHallYesterdayRankItem.Create(self.Content.transform, data[i],self.id)
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
	SYSByPmsManager.CloseRankData("pms",id)
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

function C:RefreshRankInfo()
	SYSByPmsManager.GetHallYesterdayRank_data(self.id, self.page_index)
end