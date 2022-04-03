-- 创建时间:2020-08-05
-- Panel:SYSByPmsGameRankPanel_JFPM
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

SYSByPmsGameRankPanel_JFPM = basefunc.class()
local C = SYSByPmsGameRankPanel_JFPM
C.name = "SYSByPmsGameRankPanel_JFPM"
local Page_status = {
	JF = "jf",
	PM = "pm",
}
local M = SYSByPmsManager
function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    --jf👇
    self.lister["query_bullet_rank_part_response"] = basefunc.handler(self,self.on_query_bullet_rank_part)
    --pm👇
    self.lister["SYSByPms_query_bullet_rank_data"] = basefunc.handler(self,self.RefreshRank_pm)
    self.lister["SYSByPms_query_bullet_myrank_data"] = basefunc.handler(self,self.RefreshMyRank)	

    self.lister["SYSByPms_enter_scene"] = basefunc.handler(self,self.on_SYSByPms_enter_scene)	
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseItemPrefab()
	self:Stop_Timer()
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

function C:ctor()
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
	EventTriggerListener.Get(self.jf_btn.gameObject).onClick = basefunc.handler(self, self.on_JFClick)
	EventTriggerListener.Get(self.pm_btn.gameObject).onClick = basefunc.handler(self, self.on_PMClick)
	EventTriggerListener.Get(self.exit_btn.gameObject).onClick = basefunc.handler(self, self.on_ExitClick)
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.on_HelpClick)
	local bsdata = M.GetCurBSData()
	self.pms_name_txt.text = bsdata.game_name
	self.page_status = Page_status.JF
	self:RefreshPage()
	self.spawn_cell_list = {}
	self.page_index = 1
	self.sv = self.ScrollView_pm.transform:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		local VNP = self.sv.verticalNormalizedPosition
		if VNP <= 0 then
			self:RefreshRankInfo()		
		end
	end
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:RefreshPage()
	self.jf_yes.gameObject:SetActive(self.page_status == Page_status.JF)
	self.jf_no.gameObject:SetActive(self.page_status ~= Page_status.JF)
	self.pm_yes.gameObject:SetActive(self.page_status == Page_status.PM)
	self.pm_no.gameObject:SetActive(self.page_status ~= Page_status.PM)
	self.jf.gameObject:SetActive(self.page_status == Page_status.JF)
	self.pm.gameObject:SetActive(self.page_status == Page_status.PM)
	self:CheckShouldRefresh()
	self:DeletItemPre()
end

function C:on_BackClick()
	self:MyExit()
end

function C:DeletItemPre()
	if self.page_status == Page_status.JF then
		self:CloseItemPrefab()
	else
		self:ClearCellList()
	end
end

function C:CheckShouldRefresh()
	if self.page_status == Page_status.JF then
		self:RefreshRank_jf()
		self:Query_bullet_rank_part_Timer(true)
	else
		SYSByPmsManager.CloseRankData("pms",id)
		self:RefreshRankInfo()
	end
end


function C:on_JFClick()
	self.page_status = Page_status.JF
	self:RefreshPage()
end

function C:on_PMClick()
	self.page_index = 1
	self.page_status = Page_status.PM
	self:RefreshPage()
end

function C:on_ExitClick()
	SYSByPmsGameExitPanel.Create()
end



-----------------------------------------------jf👇
function C:RefreshRank_jf()
	dump("<color=yellow>+++++++++++++++++++++++++++++</color>")
	self:ClearCellList()
	for i=1,4 do
		local pre = SYSByPmsGameRankItem_jf.Create(self.Content_jf.transform,i)
		self.CellList_jf[#self.CellList_jf + 1] = pre
	end
end

function C:ClearCellList()
	if self.CellList_jf then
		for k,v in ipairs(self.CellList_jf) do
			v:MyExit()
		end
	end
	self.CellList_jf = {}
end

function C:Query_bullet_rank_part()
	dump("<color=yellow>+++++++++++++++++++++++++++++</color>")
	Network.SendRequest("query_bullet_rank_part",{id = M.GetSignupData()})
end

function C:Query_bullet_rank_part_Timer(b)
	self:Stop_Timer()
	if b then
		self.timer_rank = Timer.New(function ()
			self:Query_bullet_rank_part()
		end,30,-1,false,true)
		self.timer_rank:Start()
	end
end

function C:Stop_Timer()
	if self.timer_rank then
		self.timer_rank:Stop()
		self.timer_rank = nil
	end
end

function C:on_query_bullet_rank_part(_,data)
	if self.page_status == Page_status.JF then
		if data then
			if data.result == 0 then
				for i=2,4 do
					self.CellList_jf[i]:Refresh(data.part_data[data.part_data[i-1].rank_id])
				end
				Event.Brocast("BYPMS_on_query_bullet_rank_part",data.cur_rank)
			else
				HintPanel.ErrorMsg(data.result)
			end
		end
	end
end
---------------------------------------------jf👆


---------------------------------------------pm👇
function C:RefreshRankInfo()
	dump({game_id = FishingModel.game_id - 1,page_index = self.page_index},"<color=yellow>555555555555555555555</color>")
	SYSByPmsManager.GetHallRank_data("pms",FishingModel.game_id - 1, self.page_index)
end

function C:CreateItemPrefab(data)
	for i=1,#data do
		local pre = SYSByPmsGameRankItem_pm.Create(self.Content_pm.transform, data[i],FishingModel.game_id - 1,"pms")
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

function C:RefreshMyRank(data)
	if self.page_status == Page_status.PM then
		if data then
			local award_list = SYSByPmsManager.GetPMSAwardCfgByRank(FishingModel.game_id - 1,data.rank,"pms")
			if award_list then--玩家自己在榜上
				local item1 = GameItemModel.GetItemToKey(award_list[1].type)
				self.my_award_txt.text = StringHelper.ToCash(award_list[1].num)
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
end


function C:RefreshRank_pm(data)
	if self.page_status == Page_status.PM then
		if data and #data > 0 then
			self:CreateItemPrefab(data)
			self.page_index = self.page_index + 1
		else
			LittleTips.Create("当前无新数据")
		end
	end
end
---------------------------------------------pm👆


function C:on_SYSByPms_enter_scene(b)
	if b then
		self:MyExit()
	end
end

function C:on_HelpClick()
	SYSByPmsGameRulesPanel.Create("pms")
end