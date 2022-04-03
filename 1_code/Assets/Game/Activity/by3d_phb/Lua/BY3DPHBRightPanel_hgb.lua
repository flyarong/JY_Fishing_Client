-- 创建时间:2020-10-22
-- Panel:BY3DPHBRightPanel_hgb
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

BY3DPHBRightPanel_hgb = basefunc.class()
local C = BY3DPHBRightPanel_hgb
C.name = "BY3DPHBRightPanel_hgb"
local M = BY3DPHBManager
function C.Create(panelSelf,parent,config)
	return C.New(panelSelf,parent,config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["hgb_rank_data_msg"] = basefunc.handler(self,self.RefreshRank)
    self.lister["hgb_myrank_data_msg"] = basefunc.handler(self,self.RefreshMyRank)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.head_pre then
		self.head_pre:MyExit()
	end
	self:CloseItemPrefab()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(panelSelf,parent,config)
	self.panelSelf = panelSelf
	self.panelSelf_config = config
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.page_index = 1
	self.game_id = 1
	self.panelSelf:ChangeBgImg("phb_bg_1")
	self.spawn_cell_list = {}
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.title1_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTitleClick(1)
	end)
	self.title2_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTitleClick(2)
	end)
	self.title3_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTitleClick(3)
	end)
	self.title4_btn.onClick:AddListener(function ()
	    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTitleClick(4)
	end)

	self.config = HotUpdateConfig("Game.Activity.by3d_phb.Lua.right_hgb_config")
	dump(self.config,"<color=green>++++++++right_hgb_config+++++++</color>")
	self.refreshtime_txt.text = self.config.refreshtime
	for i=1,#self.config.title do
		self["title"..i.."_txt"].text = self.config.title[i]
		self["title"..i..i.."_txt"].text = self.config.title[i]
	end

	self:OnTitleClick(1)

	self.sv = self.ScrollView.transform:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		local VNP = self.sv.verticalNormalizedPosition
		if VNP <= 0 then
			self:RefreshRankInfo()		
		end
	end
end

function C:MyRefresh()
end

function C:CreateItemPrefab(data)
	for i=1,#data do
		local panelName = self.panelSelf_config.itemName
		if _G[panelName] then
			if _G[panelName].Create then 
				self.spawn_cell_list[#self.spawn_cell_list + 1] = _G[panelName].Create(self,self.Content.transform,self.config,data[i])
			else
				dump("<color=red>该脚本没有实现Create</color>")
			end
		else
			dump("<color=red>该脚本没有载入</color>")
		end
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

function C:GetRulseConfig()
	return self.config.help_list
end

function C:RefreshRankInfo()
	M.QueryData_hgb(self.game_id,self.page_index)
end

function C:RefreshRank(data)
	dump(data,"<color=red>************</color>")
	if data and data.rank_data and #data.rank_data > 0 then
		self:CreateItemPrefab(data.rank_data)
		self.page_index = self.page_index + 1
	else
		LittleTips.Create("当前无新数据")
	end
end

function C:RefreshMyRank(data)
	dump(data,"<color=blue>************</color>")
	if data.rank == -1 then
		self.my_rank_img.gameObject:SetActive(true)
		self.my_rank_txt.gameObject:SetActive(false)
		self.my_rank_img.sprite = GetTexture("phb_imgf_wsb")
	else
		if data.rank == 1 then
			self.my_rank_img.gameObject:SetActive(true)
			self.my_rank_txt.gameObject:SetActive(false)
			self.my_rank_img.sprite = GetTexture("localpop_icon_1")
		elseif data.rank == 2 then
			self.my_rank_img.gameObject:SetActive(true)
			self.my_rank_txt.gameObject:SetActive(false)
			self.my_rank_img.sprite = GetTexture("localpop_icon_2")
		elseif data.rank == 3 then
			self.my_rank_img.gameObject:SetActive(true)
			self.my_rank_txt.gameObject:SetActive(false)
			self.my_rank_img.sprite = GetTexture("localpop_icon_3")
		else
			self.my_rank_img.gameObject:SetActive(false)
			self.my_rank_txt.gameObject:SetActive(true)
			self.my_rank_txt.text = "第"..data.rank.."名"
		end
	end
	self.my_rank_img:SetNativeSize()
	self.my_name_txt.text = MainModel.UserInfo.name
	self.my_score_txt.text = StringHelper.ToCash(data.score)
	for i=1,#self.config.rank_list do
		if data.rank >= self.config.rank_list[i].rank[1] and data.rank <= self.config.rank_list[i].rank[2] then
			for j=1,#self.config.rank_list[i].award_img do
				self["rank_award_icon"..j].gameObject:SetActive(true)
				self["rank_award"..j.."_img"].sprite = GetTexture(self.config.rank_list[i].award_img[j])
				self["rank_award"..j.."_txt"].text = self.config.rank_list[i].award_txt[j]
			end
		end
	end
	self.head_pre = CommonHeadInstancePrafab.Create({type = 1,
								parent = self.headBG.transform,
								--scale = 1.2, 
								})
end

function C:OnTitleClick(game_id)
	self.game_id = game_id
	self.page_index = 1
	self:RefreshTitle()
	M.QueryMyData_hgb(self.game_id)
	M.QueryData_hgb(self.game_id,self.page_index)
end

function C:RefreshTitle()
	for i=1,#self.config.title do
		if self.game_id == i then
			self["title"..i.."_img"].gameObject:SetActive(true)
		else
			self["title"..i.."_img"].gameObject:SetActive(false)
		end
	end
end