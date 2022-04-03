-- 创建时间:2020-05-08
-- Panel:SYSByPmsGameEndPanel
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

SYSByPmsGameEndPanel = basefunc.class()
local C = SYSByPmsGameEndPanel
C.name = "SYSByPmsGameEndPanel"
local M = SYSByPmsManager

local title_img_map = {
"3dby_imgf_50flq",
"3dby_imgf_200flq",
"3dby_imgf_500flq",
"3dby_imgf_1000flq",
}

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
    self.lister["model_pms_game_info_change_msg"] = basefunc.handler(self,self.on_model_pms_game_info_change_msg)
    self.lister["SYSByPmsManager_RefreshAssetTab_msg"] = basefunc.handler(self,self.RefreshAssetTab)
    self.lister["fishing_ready_finish"] = basefunc.handler(self,self.on_fishing_ready_finish)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(data)
	self.data = data
	dump(self.data,"<color>+++++++++++++++++++++self.data++++++++++++++++++++</color>")
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	data.status_tab = {1,2,0}
	self.status_tab = data.status_tab
	self.time = 120
	self:DefineChooseIndex()

	self:RefreshAssetTab()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.retry_btn.gameObject).onClick = basefunc.handler(self, self.On_Retry)
	EventTriggerListener.Get(self.continue_btn.gameObject).onClick = basefunc.handler(self, self.On_Continue)
	EventTriggerListener.Get(self.left_btn.gameObject).onClick = basefunc.handler(self, self.On_Left)
	EventTriggerListener.Get(self.right_btn.gameObject).onClick = basefunc.handler(self, self.On_Right)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.On_Get)
	EventTriggerListener.Get(self.share_btn.gameObject).onClick = basefunc.handler(self, self.On_Share)
	M.QueryCurPMSGameInfo()
	
	local bsdata = M.GetCurBSData()
	self.bs_name_txt.text = bsdata.game_name
	
	self.now_txt.text = self.data.score
	if (self.data.his_score == -1 and self.data.score ~= -1) or (self.data.his_score ~= -1 and self.data.score ~= -1 and self.data.score > self.data.his_score) then
		self.arrow1_img.gameObject:SetActive(true)
		self.high_txt.text = self.data.score
	else
		self.arrow1_img.gameObject:SetActive(false)
		self.high_txt.text = self.data.his_score
	end
	
	if (self.data.his_rank == -1 and self.data.cur_rank ~= -1) or (self.data.his_rank ~= -1 and self.data.cur_rank ~= -1 and self.data.cur_rank > self.data.his_rank) then
		self.arrow2_img.gameObject:SetActive(true)
		self.rank_txt.text = self.data.cur_rank 
	else
		self.arrow2_img.gameObject:SetActive(false)
		self.rank_txt.text = self.data.his_rank 
	end

	if self.rank_txt.text == "-1" then
		self.rank_txt.text = "未上榜"
	end

	--[[self.award_config = M.GetPMSAwardByID(M.GetSignupData())--获取奖励config
	for i=1,#self.award_config do
		if M.GetCurScore() >= tonumber(self.award_config[i].min_score) then
			self.i = i
		end
		break
	end--]]

	self:RefreshGetButton()
	self:RefreshAwardJF()
	self:RefreshAwardPM()
	self:CheckShareInit()


	local config = M.GetCurBSData()
	local id = M.GetSignupData()
	local item_index = M.CheckPMSIsCanSignup(id).result
	if item_index == -1 then--三种报名物品都不足
		self.enter_icon_img.sprite = GetTexture(GameItemModel.GetItemToKey(config.enter_condi_itemkey[#config.enter_condi_itemkey]).image)
		self.enter_hint_txt.text = config.enter_condi_item_count[#config.enter_condi_itemkey]
	elseif item_index == 0 then--免费报名类型
		self.enter_icon_img.gameObject:SetActive(false)
		self.enter_hint_txt.text = "免费报名"
	else--至少满足一种报名物品
		self.enter_icon_img.sprite = GetTexture(GameItemModel.GetItemToKey(config.enter_condi_itemkey[item_index]).image)
		self.enter_hint_txt.text = config.enter_condi_item_count[item_index]
	end

    self.timer = Timer.New(function ()
    	self.time = self.time - 1
    	if self.time <= 0 then
    		self:On_Continue()
    	end
    end,1,-1,false,true)
    self.timer:Start()


	self:MyRefresh()
end

function C:MyRefresh()
end

function C:On_Retry()
	dump(self.asset_tab,"<color=red>++++++++++++++++++++///++++++++++</color>")
	if type(self.asset_tab) == "table" and not table_is_null(self.asset_tab) then
		for k,v in pairs(self.asset_tab) do
			if v ~= -1 then
				dump(self.asset_tab[i],"<color=red>++++++++++++++++++++111111///++++++++++</color>")
				Event.Brocast("AssetGet",v)
			end
		end
	end
	local id = M.GetSignupData()
	GameButtonManager.RunFun({gotoui = "sys_by_pms", data={id = id}}, "signup")
	self.asset_tab = -1
	M.DeletAssetTab()
	self:MyExit()
end

function C:On_Continue()
	dump(self.asset_tab,"<color=red>++++++++++++++++++++///++++++++++</color>")
	if type(self.asset_tab) == "table" and not table_is_null(self.asset_tab) then
		for k,v in pairs(self.asset_tab) do
			if v ~= -1 then
				dump(self.asset_tab[i],"<color=red>++++++++++++++++++++111111///++++++++++</color>")
				Event.Brocast("AssetGet",v)
			end
		end
	end
	self.asset_tab = -1
	M.DeletAssetTab()
	self:MyExit()
end

function C:On_Left()
	self.i = self.i + 1
	if self.i > 3 then
		self.i = 3 
	end
	self:RefreshGetButton()
	self:RefreshAwardJF()
end

function C:On_Right()
	self.i = self.i - 1
	if self.i < 1 then
		self.i = 1
	end
	self:RefreshGetButton()
	self:RefreshAwardJF()
end

function C:On_Get()
	Event.Brocast("AssetGet",self.asset_tab[self.i])
	self.asset_tab[self.i] = -1
	self:RefreshGetButton()
end

function C:on_model_pms_game_info_change_msg()
	self.pms_game_info = M.GetCurPMSGameInfo()
	self.remain_time_txt.text = "剩余次数:"..self.pms_game_info.num
end


function C:RefreshAwardJF()
	self.awardjf_img.sprite = GetTexture(self.award_config[self.i].award_icon[1])
	self.awardjf_txt.text = self.award_config[self.i].award_desc[1]
	self.jf_img.sprite = GetTexture(self.award_config[self.i].icon)
	if self.award_config[self.i] then
		if self.award_config[self.i] then
			self.jf_txt.gameObject:SetActive(true)
			if self.award_config[self.i].max_score == -1 then
				self.jf_txt.text = string.sub(self.award_config[self.i].rank_name,1,6).."积分奖:大于"..self.award_config[self.i].min_score
			else
				self.jf_txt.text = string.sub(self.award_config[self.i].rank_name,1,6).."积分奖:"..self.award_config[self.i].min_score.."~"..self.award_config[self.i].max_score
			end
		else
			self.jf_txt.gameObject:SetActive(false)
		end
	end
	self:RefreshLeftAndRightBtn()
end

function C:RefreshAwardPM()
	local rank
	if (self.data.his_rank == -1 and self.data.cur_rank ~= -1) or (self.data.his_rank ~= -1 and self.data.cur_rank ~= -1 and self.data.cur_rank < self.data.his_rank) then
		rank = self.data.cur_rank 
	else
		rank = self.data.his_rank 
	end
	local award_list = SYSByPmsManager.GetPMSAwardCfgByRank(FishingModel.game_id - 1,rank,"pms")
	if table_is_null(award_list) then
		self.award_pm.gameObject:SetActive(false)
		self.tip_pm.gameObject:SetActive(true)
	else
		self.award_pm.gameObject:SetActive(true)
		self.awardpm_img.sprite = GetTexture(award_list[1].icon)
		local item1 = GameItemModel.GetItemToKey(award_list[1].type)
		self.awardpm_txt.text = StringHelper.ToCash(award_list[1].num)
	end	
end


function C:RefreshLeftAndRightBtn()
	if self.i == 3 then
		self.left_btn.gameObject:SetActive(false)
		self.right_btn.gameObject:SetActive(true)
		self:RefreshLFL(3)
	elseif self.i == 1 then
		self.left_btn.gameObject:SetActive(true)
		self.right_btn.gameObject:SetActive(false)
		self:RefreshLFL(1)
	else
		self.left_btn.gameObject:SetActive(true)
		self.right_btn.gameObject:SetActive(true)
		self:RefreshLFL(2)
	end
	
end


--[[function C:AssetChange(data)
    if data.change_type == "bullet_rank_award_settle" then
		dump(data,"<color=yellow>------------------///排名赛积分结算资产改变///------------------</color>")
		self.asset_tab = {}
		for i=1,#data.data do
		    local tab1 = {}
		    tab1.change_type = "bullet_rank_award_settle"
		    local tab2 = {}
		    tab2[1] = {}
		    tab2[1].asset_type = data.data[i].asset_type
		    tab2[1].value = data.data[i].value
		    tab1.data = tab2
		    self.asset_tab[i] = tab1
		end
		dump(self.asset_tab,"<color=yellow>------------------///排名赛积分结算资产改变///------------------</color>")
        --Event.Brocast("AssetGet",data_new)
    end
end--]]

function C:RefreshGetButton()
	dump(self.asset_tab,"<color=green>+++++++++RefreshGetButton+++++++++</color>")
	if type(self.asset_tab) == "table" and not table_is_null(self.asset_tab) and self.asset_tab[self.i] then
		if self.asset_tab[self.i] ~= -1 then
			self.texiao.gameObject:SetActive(true)
			self.get_btn.gameObject:SetActive(true)
			self.get_img.gameObject:SetActive(false)
		elseif self.asset_tab[self.i] == -1 then
			self.texiao.gameObject:SetActive(false)
			self.get_btn.gameObject:SetActive(false)
			self.get_img.gameObject:SetActive(true)
		end
	else
		self.texiao.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(false)
		self.get_img.gameObject:SetActive(false)
	end
end


function C:RefreshAssetTab()
	self.asset_tab = M.GetAssetTab()
end

function C:RefreshLFL(index)
	if type(self.asset_tab) == "table" and not table_is_null(self.asset_tab) then
		if index == 3 then
			if (self.asset_tab[2] == -1) or (not self.asset_tab[2]) then
				self.right_lfl.gameObject:SetActive(false)
			else
				self.right_lfl.gameObject:SetActive(true)
				CommonHuxiAnim.Start(self.right_lfl.gameObject,1)
			end
		elseif index == 2 then
			if (self.asset_tab[1] == -1) or (not self.asset_tab[1]) then
				self.right_lfl.gameObject:SetActive(false)
			else
				self.right_lfl.gameObject:SetActive(true)
			end
			if (self.asset_tab[3] == -1) or (not self.asset_tab[3]) then
				self.left_lfl.gameObject:SetActive(false)
			else
				self.left_lfl.gameObject:SetActive(true)
			end
		elseif index == 1 then
			if (self.asset_tab[2] == -1) or (not self.asset_tab[2]) then
				self.left_lfl.gameObject:SetActive(false)
			else
				self.left_lfl.gameObject:SetActive(true)
				CommonHuxiAnim.Start(self.left_lfl.gameObject,1)
			end
		end
	end
end

function C:on_fishing_ready_finish()
	self:MyExit()
end

function C:DefineChooseIndex()
	self.award_config = M.GetPMSAwardByID(M.GetSignupData())--获取奖励config
	for i=1,#self.award_config do
		if self.data.score >= tonumber(self.award_config[i].min_score) then
			self.i = i
			break
		end
	end
	self.i = self.i or 3
end

function C:CheckShareInit()
	self.award_config = M.GetPMSAwardByID(M.GetSignupData())--获取奖励config
	if M.GetCurScore() >= self.award_config[#self.award_config].min_score then
		self.share_btn.gameObject:SetActive(true)
		self.retry_btn.transform.localPosition = Vector3.New(0,self.retry_btn.transform.localPosition.y,self.retry_btn.transform.localPosition.z)
		local rect = self.continue_btn.transform:GetComponent("RectTransform")
		rect.sizeDelta = Vector2.New(300,116)
		self.continue_btn.transform.localPosition = Vector3.New(-450,self.continue_btn.transform.localPosition.y,self.continue_btn.transform.localPosition.z)
		self.continue_btn.transform:GetChild(0).transform:GetComponent("Text").text = "返回"
	end
end

function C:On_Share()
	local curBgCoNfig = {"bossqsb_bg_2","hlqkdhb_bg_2","mrbxl_bg_1"}
	local index = math.random(1,#curBgCoNfig)
	GameButtonManager.RunFunExt("sys_fx", "TYShareImage", nil, {fx_type="pms_settel", share_bg = curBgCoNfig[index]}, function (str)
	end)	
end