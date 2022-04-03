-- 创建时间:2020-10-22
-- Panel:BY3DPHBRightPanel_qys
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

BY3DPHBRightPanel_qys = basefunc.class()
local C = BY3DPHBRightPanel_qys
C.name = "BY3DPHBRightPanel_qys"
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
    self.lister["qys_rank_data_msg"] = basefunc.handler(self,self.RefreshRank)
    self.lister["qys_myrank_data_msg"] = basefunc.handler(self,self.RefreshMyRank)
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
	self.game_id = FishingManager.GetQYSLastMatchGameID()
	self.spawn_cell_list = {}
	self.panelSelf:ChangeBgImg("phb_bg_1_1")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.config = HotUpdateConfig("Game.Activity.by3d_phb.Lua.right_qys_config")
	local award_list = HotUpdateConfig("Game.Activity.sys_fishing_manager.Lua.fishmatch_ui")
	self.award_list = award_list.qys_award
	dump(self.config,"<color=green>++++++++right_qys_config+++++++</color>")
	self.refreshtime_txt.text = self.config.refreshtime

	M.QueryData_qys(self.game_id,self.page_index)

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
				self.spawn_cell_list[#self.spawn_cell_list + 1] = _G[panelName].Create(self,self.Content.transform,self.award_list,data[i])
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
	M.QueryData_qys(self.game_id,self.page_index)
end

function C:RefreshRank(data)
	dump(data,"<color=red>************</color>")
	if data and #data > 0 then
		self:CreateItemPrefab(data)
		self.page_index = self.page_index + 1
	else
		LittleTips.Create("当前无新数据")
	end
end

function C:RefreshMyRank(data)
	dump(data,"<color=blue>************</color>")
	if data then
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
		self.my_score_txt.text = StringHelper.ToCash(data.score)
		for i=1,#self.award_list do
			if data.rank >= self.award_list[i].min_rank and data.rank <= self.award_list[i].max_rank then
				for j=1,#self.award_list[i].award_icon do
					self["rank_award_icon"..j].gameObject:SetActive(true)
					self["rank_award"..j.."_img"].sprite = GetTexture(self.award_list[i].award_icon[j])
					self["rank_award"..j.."_txt"].text = self.award_list[i].award_desc[j]
				end
			end
		end
	else
		self.my_rank_img.game_id:SetActive(true)
		self.my_rank_txt.gameObject:SetActive(false)
		self.my_rank_img.sprite = GetTexture("phb_imgf_wsb")
		self.my_score_txt.text = ""
	end
	self.my_rank_img:SetNativeSize()
	self.my_name_txt.text = MainModel.UserInfo.name
	self.head_pre = CommonHeadInstancePrafab.Create({type = 1,
									parent = self.headBG.transform,
									--scale = 1.2, 
									})
end