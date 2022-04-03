-- 创建时间:2020-07-21
-- Panel:Act_027_JQSHLPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]



local basefunc = require "Game/Common/basefunc"

Act_027_JQSHLPanel = basefunc.class()
local C = Act_027_JQSHLPanel
C.name = "Act_027_JQSHLPanel"
local M = Act_027_JQSHLManager
local Task_Config={}

function C.Create(parent,backcall)	
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	for i = 1,#self.ui_items do
	  destroy(self.ui_items[i].gameObject)	
	end
	self.ui_items={}
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
	if self.AnimTimer then
		self.AnimTimer:Stop()
	end
	if self.backcall then
		self.backcall()	
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	Task_Config={}
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	for i=1,#M.config.task do
		Task_Config[#Task_Config + 1] = 
		{
			task_id = (M.config.task[i].type == 0 and M.GetCurrTaskID() or M.config.task[i].type == 1 and M.cz_task_id),
			task_level = M.config.task[i].task_level,
			task_name = M.config.task[i].task_name,
			award = 
			{
				image = M.config.task[i].image,
				text = M.config.task[i].text
			}	
		}
	end
	dump(#Task_Config,"长度：  ")
	--[[Task_Config = {
		[1] = {task_id = M.GetCurrTaskID(),task_level = 1,task_name = "累计抽取福利券3",award = {image = "ty_icon_jb_6y",text = "1000金币"}},
		[2] = {task_id = M.GetCurrTaskID(),task_level = 2,task_name = "累计抽取福利券6",award = {image = "ty_icon_jb_15y",text = "2000金币"}},
		[3] = {task_id = M.cz_task_id,task_level = 1,task_name = "累计充值3元",award = {image = "ty_icon_flq2",text = "10福利券"}},
		[4] = {task_id = M.GetCurrTaskID(),task_level = 3,task_name = "累计抽取福利券10",award = {image = "ty_icon_flq1",text = "2福利券"}},
		[5] = {task_id = M.GetCurrTaskID(),task_level = 4,task_name = "累计抽取福利券20",award = {image = "ty_icon_flq1",text = "5福利券"}},
		[6] = {task_id = M.cz_task_id,task_level = 2,task_name = "累计充值10元",award = {image = "ty_icon_flq3",text = "35福利券"}},
		[7] = {task_id = M.GetCurrTaskID(),task_level = 5,task_name = "累计抽取福利券50",award = {image = "ty_icon_flq2",text = "15福利券"}},
		[8] = {task_id = M.GetCurrTaskID(),task_level = 6,task_name = "累计抽取福利券100",award = {image = "ty_icon_flq2",text = "25福利券"}},
	    [9] = {task_id = M.cz_task_id,task_level = 3,task_name = "累计充值48元",award = {image = "ty_icon_flq3",text = "180福利券"}},
		[10] = {task_id = M.GetCurrTaskID(),task_level = 7,task_name = "累计抽取福利券300",award = {image = "ty_icon_flq3",text = "100福利券"}},
		[11] = {task_id = M.GetCurrTaskID(),task_level = 8,task_name = "累计抽取福利券600",award = {image = "ty_icon_flq3",text = "150福利券"}},
		[12] = {task_id = M.cz_task_id,task_level = 4,task_name = "累计充值198元",award = {image = "ty_icon_flq3",text = "750福利券"}},
		[13] = {task_id = M.GetCurrTaskID(),task_level = 9,task_name = "累计抽取福利券1200",award = {image = "ty_icon_flq3",text = "300福利券"}},
		[14] = {task_id = M.GetCurrTaskID(),task_level = 10,task_name = "累计抽取福利券2000",award = {image = "ty_icon_flq3",text = "400福利券"}},
		[15] = {task_id = M.cz_task_id,task_level = 5,task_name = "累计充值500元",award = {image = "ty_icon_flq4",text = "1500福利券"}},
		[16] = {task_id = M.GetCurrTaskID(),task_level = 11,task_name = "累计抽取福利券4000",award = {image = "ty_icon_flq4",text = "1000福利券"}},
		[17] = {task_id = M.GetCurrTaskID(),task_level = 12,task_name = "累计抽取福利券8000",award = {image = "ty_icon_flq4",text = "2000福利券"}},
		[18] = {task_id = M.GetCurrTaskID(),task_level = 13,task_name = "累计抽取福利券1.5万",award = {image = "ty_icon_flq4",text = "3500福利券"}},
		[19] = {task_id = M.cz_task_id,task_level = 6,task_name = "累计充值2498元",award = {image = "ty_icon_flq5",text = "10000福利券"}},
		[20] = {task_id = M.GetCurrTaskID(),task_level = 14,task_name = "累计抽取福利券5万",award = {image = "ty_icon_flq5",text = "15000福利券"}},
		[21] = {task_id = M.GetCurrTaskID(),task_level = 15,task_name = "累计抽取福利券10万",award = {image = "ty_icon_flq5",text = "32000福利券"}},
	}--]]
	
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.task_len_map = self:GetTaskLenMap()
	self.SV = self.transform:Find("Scroll View"):GetComponent("ScrollRect")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.anim_value = 0
	self:MainAnim() 
	self.backcall = backcall
	self:AutoGoCanGetAwardItem(self:GetBestIndex())
	local m_config=M.GetCurConfig()
	if 	m_config then
		if m_config.act_time and m_config.act_time~="" then
			--显示时间
			self.time_txt.text = m_config.act_time
		else
			self.cutdown_timer=CommonTimeManager.GetCutDownTimer(M.GetCutDownEndTime(),self.time_txt)
		end
	end
end

function C:InitUI()
	self.ui_items = {}
	self.ui_objs={}
	for i = 1,#Task_Config do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.item,self.Content)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.task_name_txt.text = Task_Config[i].task_name
		temp_ui.award_txt.text = Task_Config[i].award.text
		temp_ui.award_img.sprite = GetTexture(Task_Config[i].award.image)
		if (i%2) == 1 then
			temp_ui.award.transform.parent = temp_ui.node1
			temp_ui.award.transform.localPosition = Vector2.zero
		else
			temp_ui.tiao1.gameObject:SetActive(false)
			temp_ui.tiao2.gameObject:SetActive(false)
			temp_ui.award.transform.parent = temp_ui.node2
			temp_ui.award.transform.localPosition = Vector2.zero
		end
		if i == 1 then
			temp_ui.tiao2.gameObject:SetActive(false)
		end
		if i == #Task_Config then
			temp_ui.tiao1.gameObject:SetActive(false)
		end
		temp_ui.get_award_btn.onClick:AddListener(
			function ()
				self:GetAward(i)
			end
		)
		self.ui_items[#self.ui_items + 1] = temp_ui
		self.ui_objs[#self.ui_objs+1]=obj
	end
	self.close_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.help_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
	)
	self.go_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.GuideExitScene({gotoui = "game_Fishing3DHall"})
			self:MyExit()
		end
	)
	self.go1_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			local config=M.GetCurConfig()
			if config and config.btn_gotoui then
				GameManager.GuideExitScene({gotoui = config.btn_gotoui})
			end
			self:MyExit()
		end
	)
	self.pay_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
			self:MyExit()
		end
	)
	self.pay1_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
			self:MyExit()
		end
	)
	EventTriggerListener.Get(self.left_btn_.gameObject).onDown = basefunc.handler(self,self.LeftAnim)
	EventTriggerListener.Get(self.right_btn_.gameObject).onDown = basefunc.handler(self,self.RightAnim)
	EventTriggerListener.Get(self.left_btn_.gameObject).onUp = basefunc.handler(self,self.ButtonUp)
	EventTriggerListener.Get(self.right_btn_.gameObject).onUp = basefunc.handler(self,self.ButtonUp)
	-- self.topTitle_img.sprite=GetTexture(M.cur_path.."_title_img")
	self:MyRefresh()
end

function C:MyRefresh()
	if IsEquals(self.gameObject) then
		for i = 1,#self.ui_items do
			local data = GameTaskModel.GetTaskDataByID(Task_Config[i].task_id)
			if data then
				local b = basefunc.decode_task_award_status(data.award_get_status)
				b = basefunc.decode_all_task_award_status2(b, data, self.task_len_map[Task_Config[i].task_id])
				if b[Task_Config[i].task_level] == 1 then
					self.ui_items[i].ylq.gameObject:SetActive(false)
					self.ui_items[i].get_award_btn.gameObject:SetActive(true)
					--CommonHuxiAnim.Start(self.ui_items[i].dlq.gameObject,1)
				elseif b[Task_Config[i].task_level] == 2 then
					self.ui_items[i].ylq.gameObject:SetActive(true)
					self.ui_items[i].get_award_btn.gameObject:SetActive(false)
				else
					self.ui_items[i].ylq.gameObject:SetActive(false)
					self.ui_items[i].get_award_btn.gameObject:SetActive(false)
				end
			end
		end
		self:RefreshLJCZ()
		self:RefreshLJYJ()
	end
end

function C:OpenHelpPanel()
	local Help_Info = {}
	for i=1,#M.config.help_Info do
		Help_Info[#Help_Info + 1] = M.config.help_Info[i].content
	end
	local DESCRIBE_TEXT
	DESCRIBE_TEXT = Help_Info
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform,"IllustratePanel_New")
end

--充值任务长度5
--累计赢金任务长度14
function C:GetAward(index)
	local task_len_map = self.task_len_map
	dump(task_len_map,"<color=red> 任务长度----- </color>")
	if index > 1 then
		local last_taskid = Task_Config[index - 1].task_id
		local data = GameTaskModel.GetTaskDataByID(last_taskid)
		dump(data,"上一个任务数据")
		if data then
			local b = basefunc.decode_task_award_status(data.award_get_status)
			b = basefunc.decode_all_task_award_status2(b, data, task_len_map[last_taskid])
			if b[Task_Config[index - 1].task_level] == 2 then
				Network.SendRequest("get_task_award",{id = Task_Config[index].task_id})
			else
				HintPanel.Create(1,"请先领取前一个任务的奖励!")
			end
		end
	else
		Network.SendRequest("get_task_award",{id = Task_Config[index].task_id})
	end
end

function C:GetTaskLenMap()
	local task_len_map = {}
	for i = 1,#Task_Config do
		task_len_map[Task_Config[i].task_id] = task_len_map[Task_Config[i].task_id] and (task_len_map[Task_Config[i].task_id] + 1) or 1
	end
	return task_len_map
end

function C:on_model_task_change_msg(data) 
	if data and self.task_len_map[data.id] then
		self:MyRefresh()
		Event.Brocast("global_hint_state_change_msg",{ gotoui = M.key })
	end
end

function C:LeftAnim()
	self.anim_value = - 1
end

function C:RightAnim()
	self.anim_value =  1
end

function C:ButtonUp()
	self.anim_value = 0	 
end

function C:MainAnim()
	if self.AnimTimer then
		self.AnimTimer:Stop()
	end
	self.AnimTimer = Timer.New(
		function()
			self.SV.horizontalNormalizedPosition = self.SV.horizontalNormalizedPosition + 0.01 * self.anim_value
			if self.SV.horizontalNormalizedPosition >= 0.999 then
				self.right_btn_.gameObject:SetActive(false)
				self.anim_value = 0	 
			else
				self.right_btn_.gameObject:SetActive(true)
			end
			if self.SV.horizontalNormalizedPosition <= 0.001 then
				self.left_btn_.gameObject:SetActive(false)
				self.anim_value = 0	 
			else
				self.left_btn_.gameObject:SetActive(true)
			end			
		end
	,0.02,-1)
	self.AnimTimer:Start()
end

function C:AutoGoCanGetAwardItem(index)
	self.MMM.gameObject:SetActive(true)
	local go_anim = function(val)
		local t 
		t = Timer.New(
			function()
				if IsEquals(self.gameObject) then
					self.SV.horizontalNormalizedPosition = Mathf.Lerp(self.SV.horizontalNormalizedPosition,val,0.1)
					if math.abs(self.SV.horizontalNormalizedPosition - val) <= 0.006 then 
						self.MMM.gameObject:SetActive(false)
						t:Stop()
						t = nil
					end
				end
			end
		,0.02,-1)
		t:Start()
	end
	if index <= 3 then
		go_anim(0)
	elseif index >= #Task_Config - 3 then
		go_anim(1)
	else
		go_anim(1/#Task_Config * (index) + 0.015)
	end
end


function C:GetBestIndex()
	for i = #Task_Config,1,-1 do
		local data = GameTaskModel.GetTaskDataByID(Task_Config[i].task_id)
		if data then
			local b = basefunc.decode_task_award_status(data.award_get_status)
			b = basefunc.decode_all_task_award_status2(b, data, self.task_len_map[Task_Config[i].task_id])
			if b[Task_Config[i].task_level] == 2 then
				return i + 1
			end
		end
	end
	return 1
end

function C:RefreshLJYJ()
	local data = GameTaskModel.GetTaskDataByID(M.GetCurrTaskID())
	dump(data,"LJFLQ  data:  ")
	if data then
		self.all_ljyj_txt.text = StringHelper.ToCash(data.now_total_process)
	else
		self.all_ljyj_txt.text = 0
	end
end

function C:RefreshLJCZ()
	local data = GameTaskModel.GetTaskDataByID(M.cz_task_id)
	dump(data,"LJCZZZ  data:  ")

	if data then
		self.all_pay_txt.text = StringHelper.ToCash(data.now_total_process/100)
	else
		self.all_pay_txt.text = 0 
	end
end
