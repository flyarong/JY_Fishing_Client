-- 创建时间:2020-04-16
-- Panel:FishFarmDailyTaskItemBase
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

FishFarmDailyTaskItemBase = basefunc.class()
local C = FishFarmDailyTaskItemBase
C.name = "FishFarmDailyTaskItemBase"

function C.Create(parent, task_id, panelSelf)
	return C.New(parent, task_id, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, task_id, panelSelf)
	self.task_id = task_id
	self.panelSelf = panelSelf
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.slider = self.Slider.transform:GetComponent("Slider")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	--领奖
	self.get_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Network.SendRequest("get_task_award", {id = self.task_id}, "领取奖励")
	end)
	--前往
	self.go_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		--前往捕鱼场景
		if self.config.gotoui then

		end
	end)

	self.config = FishFarmDailyTaskManager.GetTaskCfgByID(self.task_id)
	self.task_img.sprite = GetTexture(self.config.task_icon)
	self.task_title_txt.text = self.config.task_name
	self.task_introduction_txt.text = self.config.task_instruction
	local award1_ui = LuaHelper.GeneratingVar(self.award1)
	local award2_ui = LuaHelper.GeneratingVar(self.award2)

	award1_ui.award_img.sprite = GetTexture(self.config.task_award_icon[1])
	award1_ui.award_txt.text = self.config.task_award_instruction[1] .. " " .. self.config.task_award_count[1]
	if self.config.task_award_icon[2] then
		award2_ui.award_img.sprite = GetTexture(self.config.task_award_icon[2])
		award2_ui.award_txt.text = self.config.task_award_instruction[2] .. " " .. self.config.task_award_count[2]
	else
		self.award2.gameObject:SetActive(false)
	end

	self:MyRefresh()
end

function C:MyRefresh()
	local task_data = FishFarmDailyTaskManager.GetTaskDataByID(self.task_id)
	if not task_data then
		return
	end

	if task_data.now_process and task_data.need_process then
		self.task_progress_now_txt.text = "<color=#008CFFFF>" .. StringHelper.ToCash(task_data.now_process) .. "</color>" .. "<color=#008CFFFF>/" .. StringHelper.ToCash(task_data.need_process) .. "</color>"
		self.slider.maxValue = task_data.need_process
		self.slider.value = task_data.now_process
	else
		self.task_progress_now_txt.gameObject:SetActive(false)
		self.slider.gameObject:SetActive(false)
	end

	if task_data.award_status == 1 then--奖励可领还未领
		self.go_btn.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(true)
		self.already_get_img.gameObject:SetActive(false)
	elseif task_data.award_status == 0 then--奖励还不可领
		self.get_btn.gameObject:SetActive(false)
		self.already_get_img.gameObject:SetActive(false)
		self.go_btn.gameObject:SetActive(false)
		if self.config.gotoui then
			self.go_btn.gameObject:SetActive(true)
		else
			self.already_get_img.gameObject:SetActive(true)
			self.already_get_txt.text = "领    取"
		end
	elseif task_data.award_status == 2 then--奖励已领
		self.go_btn.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(false)
		self.already_get_img.gameObject:SetActive(true)
		self.already_get_txt.text = "已领取"
	end
end

function C:UpdateData(index)
	self:MyRefresh()
	self.transform:SetSiblingIndex(index)
end
