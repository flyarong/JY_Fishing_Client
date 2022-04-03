-- 创建时间:2020-04-16
-- Panel:ActiveDailyTaskPanel
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

ActiveDailyTaskPanel = basefunc.class()
local C = ActiveDailyTaskPanel
C.name = "ActiveDailyTaskPanel"
C.instance = nil

function C.Create()
	if C.instance then
		C.instance:MyRefresh()
		return
	end
	C.instance = C.New()
	return C.instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}

	self.lister["sys_active_daily_task_msg_finish_msg"] = basefunc.handler(self,self.MyRefresh)
	self.lister["ActiveDailyTaskManager_refresh"] = basefunc.handler(self,self.on_Refresh)
	self.lister["ActiveDailyTaskManager_refresh_rate"] = basefunc.handler(self,self.RefreshRate)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["ActiveDailyTaskManager_tag_change"] = basefunc.handler(self,self.MyExit)
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
	C.instance = nil
	destroy(self.gameObject)
end

local ItemMap={}

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end
function C:OnGetHYClick(i)
	Network.SendRequest("get_task_award_new", {id = ActiveDailyTaskManager.GetCurActiveTaskID(), award_progress_lv = i},"请求奖励",function(data)
		if data.result == 0 then
			self:MyRefresh()
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end
function C:InitUI()
	self.slider_value_map = {}
	self.slider_value_map[0] = {active=0}
	local cfg = ActiveDailyTaskManager.GetAwardConfig()
	for i = 1,#cfg do
		self.slider_value_map[i] = cfg[i]
	end

	self.back_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("ActiveDailyTaskPanel_back")
		self:MyExit()
	end)

	for i = 1,5 do
		self["award" .. i .. "_btn"].onClick:AddListener(function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if self.activeValue and self.activeValue >= self.slider_value_map[i].active then
				if self.slider_value_map[i].vip then
					if self.slider_value_map[i].vip > VIPManager.get_vip_data().vip_level then
						local pre = HintPanel.Create(6, "提升VIP等级可领高倍奖励", function ()
							self:OnGetHYClick(i)				
						end,function ()
							if MainModel.UserInfo.ui_config_id == 1 and MainModel.UserInfo.vip_level < 1 then
            					GameManager.GotoUI({gotoui="hall_activity", goto_scene_parm="panel"})
            				else
								PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
							end
						end)
						pre:SetButtonText("普通领取", "VIP"..self.slider_value_map[i].vip.."领取")
					else
						self:OnGetHYClick(i)
					end
				else
					self:OnGetHYClick(i)
				end
			else
				LittleTips.Create(ActiveDailyTaskManager.GetAwardTipsByIndex(i))
			end
		end)
	end

	self.award_btn_list = {}
	self.Slider_all_list = {}
	self.slider_fx_list = {}
	self.huoyue_tag_list = {}
	for i = 1, 5 do
		self.award_btn_list[#self.award_btn_list + 1] = self["award" .. i .. "_btn"]
		self.Slider_all_list[#self.Slider_all_list + 1] = self["Slider_all" .. i]:GetComponent("Slider")
		self.huoyue_tag_list[#self.huoyue_tag_list + 1] = {tag=self["tag_node" .. i], tagtxt=self["tag"..i.."_txt"]}
		local max = 0
		if i == 1 then
			max = self.slider_value_map[i].active
		else
			max = self.slider_value_map[i].active - self.slider_value_map[i-1].active
		end
		if self.slider_value_map[i].vip then
			self.huoyue_tag_list[i].tag.gameObject:SetActive(true)
			self.huoyue_tag_list[i].tagtxt.text = self.slider_value_map[i].vip_desc or ""
		end

		self.Slider_all_list[i].maxValue = max
		local obj
		if i == 5 then
			obj = GameObject.Instantiate(GetPrefab("ActiveDailyTask_boxglow_02"), self.award_btn_list[i].transform)
			obj.transform.localPosition = Vector3.New(-10, 2.6, 0)
		else
			obj = GameObject.Instantiate(GetPrefab("ActiveDailyTask_boxglow"), self.award_btn_list[i].transform)
			obj.transform.localPosition = Vector3.New(-7.5, -4.5, 0)
		end
		self.slider_fx_list[i] = obj.gameObject
		self.slider_fx_list[i]:SetActive(false)
	end

	self.spawn_cell_map = {}
	self.task_sort_list = {} -- 排序
	local task_cfg = ActiveDailyTaskManager.GetTaskConfig()
	for i=1,#task_cfg do
		local pre = ActiveDailyTaskItemBase.Create(self.TaskNode.transform, task_cfg[i].task_id, self)
		self.spawn_cell_map[task_cfg[i].task_id] = pre
		self.task_sort_list[i] = task_cfg[i].task_id
	end

	ActiveDailyTaskManager.SetTaskState()

	ActiveDailyTaskManager.QueryData(true)
end

function C:MyRefresh()
	self:RefreshSlider()
	self:RefreshItemPrefab()
	self:RefreshTopAward()
end

function C:RefreshSlider()
	local task = ActiveDailyTaskManager.GetActiveDataByID()
	if not task then
		return
	end
	self.activeValue = task.now_total_process
	local total_value = self.activeValue
	self.huoyuedu_all_txt.text = total_value .. ""
	for i = 1, 5 do
		if total_value >= self.slider_value_map[i].active then
			self.Slider_all_list[i].value = self.slider_value_map[i].active - self.slider_value_map[i - 1].active
		elseif total_value <= self.slider_value_map[i - 1].active then
			self.Slider_all_list[i].value = 0
		else
			self.Slider_all_list[i].value = total_value - self.slider_value_map[i - 1].active
		end
	end
end

function C:RefreshItemPrefab()
	self.task_sort_list = ActiveDailyTaskManager.GetTaskDataAndSort()
	for k,v in ipairs(self.task_sort_list) do
		if self.spawn_cell_map[v] then
			self.spawn_cell_map[v]:UpdateData(k)
		end
	end
end

function C:RefreshTopAward()
	local data = ActiveDailyTaskManager.GetActiveDataByID()
	if not data then
		return
	end
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status(b, data, 5)
	for i = 1,#b do
		self.slider_fx_list[i]:SetActive(false)
		if b[i] == 0 then  -- 未达成条件
			self["award" .. i .. "_btn"].gameObject:SetActive(true)
			self["already_award" .. i .. "_img"].gameObject:SetActive(false)
		end
		if b[i] == 1 then  -- 达成条件未领取
			self.slider_fx_list[i]:SetActive(true)
			self["award" .. i .. "_btn"].gameObject:SetActive(true)
			self["already_award" .. i .. "_img"].gameObject:SetActive(false)
		end
		if b[i] == 2 then --  已领取奖励
			self["award" .. i .. "_btn"].gameObject:SetActive(false)
			self["already_award" .. i .. "_img"].gameObject:SetActive(true)
		end
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_map then
		for k,v in pairs(self.spawn_cell_map) do
			v:MyExit()
		end
	end
	self.spawn_cell_map = {}
end

function C:on_Refresh()
	self:RefreshSlider()
	self:RefreshItemPrefab()
end
function C:RefreshRate()
	self:RefreshTopAward()
end
