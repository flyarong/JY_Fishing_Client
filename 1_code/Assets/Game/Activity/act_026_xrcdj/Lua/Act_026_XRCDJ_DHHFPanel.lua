-- 创建时间:2020-08-13
-- Panel:Act_026_XRCDJ_DHHFPanel
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

Act_026_XRCDJ_DHHFPanel = basefunc.class()
local C = Act_026_XRCDJ_DHHFPanel
C.name = "Act_026_XRCDJ_DHHFPanel"
local M = Act_026_XRCDJManager

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_get_task_award_response"] = basefunc.handler(self, self.model_get_task_award_response)
    self.lister["query_fake_data_response"] = basefunc.handler(self, self.on_query_fake_data_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.pmd_pre then
		self.pmd_pre:MyExit()
		self.pmd_pre = nil
	end
	if self.pmd_t then
		self.pmd_t:Stop()
		self.pmd_t = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
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
	self.get_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	self.get_img = self.get_btn.transform:GetComponent("Image")
	self.get_outline = self.get_txt.transform:GetComponent("Outline")
	self.pmd_pre = CommonPMDManager.Create(self, self.CreatePMD, {actvity_mode=2})
	self:MyRefresh()
end

function C:MyRefresh()
	self.task_id = M.GetDHHFTaskID()	
	self.task_data = GameTaskModel.GetTaskDataByID( self.task_id )

	if not self.task_data or self.task_data.award_status == 2 then
		self.get_img.sprite = GetTexture("ty_btn_ywc")
		self.get_outline.effectColor = COLOR_HuiS_Outline
		
	else
		self.get_img.sprite = GetTexture("ty_btn_lan")
		self.get_outline.effectColor = COLOR_LanS1_Outline
	end

	local qt = M.GetFinishCJJD(1)-- 青铜
	local by = M.GetFinishCJJD(2)-- 白银
	local hj = M.GetFinishCJJD(3)-- 黄金
	self.jd_cj_txt.text = string.format("当前进度:   青铜%s/%s  白银%s/%s   黄金%s/%s", qt[1], qt[2], by[1], by[2], hj[1], hj[2])

	self.pmd_t = Timer.New(function ()
		self:QueryPMD()
	end,3,-1)
	self.pmd_t:Start()
	self:QueryPMD()
end

function C:OnGetClick()
	if self.task_data then
		if self.task_data.award_status == 1 then
			Network.SendRequest("get_task_award", {id = self.task_id}, "")
		elseif self.task_data.award_status == 0 then
			LittleTips.Create("完成任务后即可领取！")
		else
			LittleTips.Create("已领取")
		end
	else
		LittleTips.Create("任务数据为空")
	end
end

function C:model_get_task_award_response(data)
	if data.id == self.task_id then
		self:MyRefresh()
		self.pmd_pre:AddPMDData({player_name=MainModel.UserInfo.name}, true)
	end
end

function C:on_query_fake_data_response(_, data)
	if data.result == 0 and data.data_type == "xrcdj" then
		self.pmd_pre:AddPMDData(data)
	end
end

function C:QueryPMD()
	Network.SendRequest("query_fake_data", {data_type = "xrcdj"})	
end

function C:CreatePMD(data)
	local obj = GameObject.Instantiate(self.pmd, self.pmd_node.transform)
	local text = obj.transform:GetComponent("Text")
	text.text = "恭喜玩家" .. data.player_name .. " 成功领取10元话费！"
	obj.gameObject:SetActive(true)
	return obj
end