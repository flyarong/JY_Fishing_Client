-- 创建时间:2020-04-16
-- Panel:ActiveDailyTaskItemBase
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

ActiveDailyTaskItemBase = basefunc.class()
local C = ActiveDailyTaskItemBase
C.name = "ActiveDailyTaskItemBase"

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
		if VIPManager.get_vip_data() == nil then
			self:OnGetClick()
			return
		end 
		if self.config.vip then
			if self.config.vip > VIPManager.get_vip_data().vip_level then
				local pre = HintPanel.Create(6, "提升VIP等级可领高倍奖励", function ()
					self:OnGetClick()				
				end,function ()
					PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
				end)
				pre:SetButtonText("普通领取", "VIP"..self.config.vip.."领取")
			else
				self:OnGetClick()
			end
		else
			self:OnGetClick()
		end
	end)
	--前往
	self.go_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		--前往捕鱼场景
		if self.config.gotoui then
			if self.config.gotoui[1] == "game_Eliminate" then
				GameManager.CommonGotoScence({gotoui="game_Eliminate"},self.panelSelf:MyExit())
			elseif self.config.gotoui[1] == "game_EliminateSH" then
				GameManager.CommonGotoScence({gotoui="game_EliminateSH"},self.panelSelf:MyExit())

			elseif self.config.gotoui[1] == "game_EliminateCS" then
				GameManager.CommonGotoScence({gotoui="game_EliminateCS"},self.panelSelf:MyExit())
			else
				local parm = {gotoui=self.config.gotoui[1], goto_scene_parm=self.config.gotoui[2]}
				GameManager.GuideExitScene(parm, function ()
		            self.panelSelf:MyExit()        
		        end)
			end
		else
			--默认前往3d捕鱼大厅
			GameManager.GotoUI({gotoui = "game_Fishing3DHall"})
		end
	end)

	self.config = ActiveDailyTaskManager.GetTaskCfgByID(self.task_id)
	self.task_img.sprite = GetTexture(self.config.task_icon)
	self.task_title_txt.text = self.config.task_name
	self.task_introduction_txt.text = self.config.task_instruction
	local award1_ui = LuaHelper.GeneratingVar(self.award1)
	local award2_ui = LuaHelper.GeneratingVar(self.award2)

	award1_ui.award_img.sprite = GetTexture(self.config.task_award_icon[1])
	award1_ui.award_txt.text = self.config.task_award_instruction[1] .. " " .. self.config.task_award_count[1]
	if self.config.vip_desc and self.config.vip_desc[1] ~= "" then
		award1_ui.tag.gameObject:SetActive(true)
		award1_ui.tag_txt.text = self.config.vip_desc[1]
	end
	if self.config.task_award_icon[2] then
		award2_ui.award_img.sprite = GetTexture(self.config.task_award_icon[2])
		award2_ui.award_txt.text = self.config.task_award_instruction[2] .. " " .. self.config.task_award_count[2]
		if self.config.vip_desc and self.config.vip_desc[2] ~= "" then
			award2_ui.tag.gameObject:SetActive(true)
			award2_ui.tag_txt.text = self.config.vip_desc[2]
		end
	else
		self.award2.gameObject:SetActive(false)
	end

	-- 累计在线不显示进度值
	if self.task_id == 12523 or self.task_id == 12538 then
		self.task_progress_now_txt.gameObject:SetActive(false)
	end
	self:MyRefresh()
end

function C:MyRefresh()
	local task_data = ActiveDailyTaskManager.GetTaskDataByID(self.task_id)
	if not task_data then
		return
	end

	if task_data.now_process and task_data.need_process then
		if self.task_id == 12527 or self.task_id == 12530 or self.task_id == 12534 then--累计充值进度/100
			self.task_progress_now_txt.text = "<color=#008CFFFF>" .. StringHelper.ToCash(task_data.now_process/100) .. "</color>" .. "<color=#008CFFFF>/" .. StringHelper.ToCash(task_data.need_process/100) .. "</color>"
		else
			self.task_progress_now_txt.text = "<color=#008CFFFF>" .. StringHelper.ToCash(task_data.now_process) .. "</color>" .. "<color=#008CFFFF>/" .. StringHelper.ToCash(task_data.need_process) .. "</color>"
		end
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
		self.go_btn.gameObject:SetActive(true)
		self.get_btn.gameObject:SetActive(false)
		self.already_get_img.gameObject:SetActive(false)
	elseif task_data.award_status == 2 then--奖励已领
		self.go_btn.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(false)
		self.already_get_img.gameObject:SetActive(true)
	end
end

function C:UpdateData(index)
	self:MyRefresh()
	self.transform:SetSiblingIndex(index)
end

function C:OnGetClick()
	Network.SendRequest("get_task_award", {id = self.task_id}, "领取奖励")
end
