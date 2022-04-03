-- 创建时间:2020-08-19
-- Panel:Act_026_SGXXLYDEnterPrefab
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

Act_026_SGXXLYDEnterPrefab = basefunc.class()
local C = Act_026_SGXXLYDEnterPrefab
C.name = "Act_026_SGXXLYDEnterPrefab"
local M = Act_026_SGXXLYDManager
local Enter_Status = {
	can_get = "Can_Get",
	cant_get = "Cant_Get",
}

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
    self.lister["SGXXLYD_enter_msg"] = basefunc.handler(self,self.on_SGXXLYD_enter_msg)
    self.lister["model_lottery_success"] = basefunc.handler(self,self.on_model_lottery_success)
    self.lister["bet_is_change_msg"] = basefunc.handler(self,self.on_bet_is_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:KillDotween()
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
	dump("<color=yellow>666666666666666</color>")
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.slider = self.Slider.transform:GetComponent("Slider")
	self.task_ids = M.GetTask_id()
	self.count = 0
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.on_EnterClick)
	self:RefreshPage()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:RefreshPage()
	local data
	for i=1,#self.task_ids do
		data = GameTaskModel.GetTaskDataByID(self.task_ids[i])
		if data and data.award_status ~= 2 then
			self.index = i
			break
		end
	end
	dump(data,"<color=red>+++++++data+++++++</color>")
	if data and self.index then
		
		self.award_txt.text = M.config[self.index].award
		self.desc_txt.text = M.config[self.index].condition2
		self.slider.value = data.now_process/data.need_process
		if M.GetBet() >= M.config[self.index].num then
			if self.slider.value >= 1 then
				self.progress_txt.text = math.ceil(data.now_process/M.GetBet()).."/"..math.ceil(data.need_process/M.GetBet())
				self.remain_txt.text = "再消"..(math.ceil(data.need_process/M.GetBet()) - math.ceil(data.now_process/M.GetBet())).."次"
			else
				self.progress_txt.text = math.floor(data.now_process/M.GetBet()).."/"..math.ceil(data.need_process/M.GetBet())
				self.remain_txt.text = "再消"..(math.ceil(data.need_process/M.GetBet()) - math.floor(data.now_process/M.GetBet())).."次"
			end
		else
			self.progress_txt.text = math.floor(data.now_process/M.config[self.index].num).."/"..math.ceil(data.need_process/M.config[self.index].num)
			self.remain_txt.text = "再消"..(math.ceil(data.need_process/M.config[self.index].num) - math.floor(data.now_process/M.config[self.index].num)).."次"
		end
		
		
		if data.award_status == 0 then
			self.enter_status = Enter_Status.cant_get
			self.lfl.gameObject:SetActive(false)
		elseif data.award_status == 1 then
			self.enter_status = Enter_Status.can_get
			self.lfl.gameObject:SetActive(true)
			self:on(false)
		end
	end
end

function C:IsCareId(id)
	for i=1,#self.task_ids do
		if self.task_ids[i] == id then
			return true
		end
	end
	return false
end

function C:on_model_task_change_msg(data)
	if data then
		if self:IsCareId(data.id) then
			self:RefreshPage()
		end
	end
end

function C:on_EnterClick()
	if self.enter_status == Enter_Status.cant_get then
		Act_026_SGXXLYDPanel.Create()
	elseif self.enter_status == Enter_Status.can_get then
		Network.SendRequest("get_task_award", {id = self.task_ids[self.index]})
	end 
end

function C:on_SGXXLYD_enter_msg()
	self:on(true)
end

function C:on(bool)
	self:KillDotween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.bg.transform:DOLocalMoveX(0,0.3))
	if bool then
		self.seq:Join(self.enter_btn.transform:DOShakeRotation(1,Vector3.New(0,0,60),10,60))
	end
	self.seq:AppendInterval(0.3)
	self.seq:AppendCallback(function ()
		self.kuang.gameObject:SetActive(true)
	end)
	self.seq:AppendInterval(3)
	self.seq:AppendCallback(function ()
		self.kuang.gameObject:SetActive(false)
		self:off()
	end)
end

function C:off()
	self:KillDotween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.bg.transform:DOLocalMoveX(-500,0.3))
	self.seq:Join(self.enter_btn.transform:DOShakeRotation(1,Vector3.New(0,0,60),10,60))
end

function C:KillDotween()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
end

function C:on_model_lottery_success()
	self.count = self.count + 1
	if self.count == 20 then
		self:on(true)
		self.count = 0
	end
end

function C:on_bet_is_change_msg()
	self:RefreshPage()
end