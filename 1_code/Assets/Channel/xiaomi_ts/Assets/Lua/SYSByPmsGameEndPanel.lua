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
	
	self.bool = true
	self.time = 120
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.retry_btn.gameObject).onClick = basefunc.handler(self, self.On_Retry)
	EventTriggerListener.Get(self.continue_btn.gameObject).onClick = basefunc.handler(self, self.On_Continue)
	EventTriggerListener.Get(self.share_btn.gameObject).onClick = basefunc.handler(self, self.On_Share)

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

	M.QueryCurPMSGameInfo()
	
	self.time_txt.text = os.date("%Y-%m-%d   %H:%M:%S",os.time())
	self.score_txt.text = M.GetCurScore().."积分"
	if self.data.cur_rank == -1 then
		self.rank_txt.text = "未上榜"
	else
		self.rank_txt.text = self.data.cur_rank
	end
	local name = M.GetCurBSData()
	self.bs_name_txt.text = (name.game_name or "")

	
	if (self.data.his_rank == -1 and self.data.cur_rank ~= -1) or (self.data.his_rank ~= -1 and self.data.cur_rank ~= -1 and self.data.cur_rank < self.data.his_rank) then
		self.arrow_img.gameObject:SetActive(true)
	else
		self.arrow_img.gameObject:SetActive(false)
	end

    self.timer = Timer.New(function ()
    	self.time = self.time - 1
    	if self.time <= 0 then
    		self:On_Continue()
    	end
    end,1,-1,false,true)
    self.timer:Start()

	if GameGlobalOnOff.InternalTest then
		self.share_btn.gameObject:SetActive(false)
		self.continue_btn.transform.localPosition = Vector3.New(-340,self.continue_btn.transform.localPosition.y,0)
		self.retry_btn.transform.localPosition = Vector3.New(340,self.retry_btn.transform.localPosition.y,0)
	end


	self.award_config = M.GetPMSAwardByID(M.GetSignupData())--获取奖励config
	for i=1,#self.award_config do
		dump(self.award_config[i],"<color=red><size=20>+++++++++++++++++++++</size></color>")
		if M.GetCurScore() >= tonumber(self.award_config[i].min_score) then
			--[[self.item1.gameObject:SetActive(true)
			self.item1_img.sprite = GetTexture(self.award_config[i].award_icon[1])
			self.item1_txt.text = self.award_config[i].award_desc[1]--]]
			if #self.award_config[i].award_desc == 1 then
				self.item1.gameObject:SetActive(true)
				self.item1_img.sprite = GetTexture(self.award_config[i].award_icon[1])
				self.item1_txt.text = self.award_config[i].award_desc[1]
				self.item1_txt.fontSize = 28
			elseif #self.award_config[i].award_desc == 2 then
				self.item2.gameObject:SetActive(true)
				self.item2_img.sprite = GetTexture(self.award_config[i].award_icon[2])
				self.item2_txt.text = self.award_config[i].award_desc[2]
				self.item2_txt.fontSize = 28
			end
			break
		end
	end
	if not self.item1.gameObject.activeSelf and not self.item2.gameObject.activeSelf then
		self.score_txt.transform.localPosition = Vector3.New(220,66,0)
	end
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:On_Retry()
	self.bool = false
	local id = M.GetSignupData()
	GameButtonManager.RunFun({gotoui = "sys_by_pms", data={id = id}}, "signup")
	self:MyExit()
end

function C:On_Continue()
	self.bool = false
	self:MyExit()
end

function C:On_Share()
	SYSByPmsGameSharePanel.Create()
	self:MyExit()
end

function C:on_model_pms_game_info_change_msg()
	self.pms_game_info = M.GetCurPMSGameInfo()
	self.remain_time_txt.text = "剩余次数:"..self.pms_game_info.num
end