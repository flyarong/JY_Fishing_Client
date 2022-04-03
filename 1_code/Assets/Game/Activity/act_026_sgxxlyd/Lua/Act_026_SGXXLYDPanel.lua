-- 创建时间:2020-08-19
-- Panel:Act_026_SGXXLYDPanel
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

Act_026_SGXXLYDPanel = basefunc.class()
local C = Act_026_SGXXLYDPanel
C.name = "Act_026_SGXXLYDPanel"
local M = Act_026_SGXXLYDManager
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
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopTimer()
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
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.slider = self.Slider.transform:GetComponent("Slider")
	self.remain_time = 604800 - (MainModel.GetCurTime() - MainModel.UserInfo.first_login_time)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
	self:CountDownTimer(true)
	self:RefreshTask()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:RefreshTime()
	local dd = math.floor(self.remain_time/86400)
	local hh = math.floor((self.remain_time%86400)/3600)
	local ff = math.floor(((self.remain_time%86400)%3600)/60)
	local str = string.format("%2d天%02d时%02d分", dd, hh, ff)
	self.time_txt.text = "1.本活动为新人专属，有效期7天。（剩余时间："..str.."）"
end

function C:CountDownTimer(b)
	self:StopTimer()
	if b then
		self:RefreshTime()
		self.countdowntimer = Timer.New(function ()
			self.remain_time = self.remain_time - 60
			self:RefreshTime()
		end,60,-1)
		self.countdowntimer:Start()
	end
end

function C:StopTimer()
	if self.countdowntimer then
		self.countdowntimer:Stop()
		self.countdowntimer = nil
	end
end

function C:on_BackClick()
	self:MyExit()
end

function C:RefreshTask()
	local task_ids = M.GetTask_id()
	local data
	local index
	for i=1,#task_ids do
		data = GameTaskModel.GetTaskDataByID(task_ids[i])
		if data and data.award_status ~= 2 then
			index = i
			break
		end
	end
	dump(data,"<color=red>+++++++data+++++++</color>")
	if data and index then
		self.task_desc_txt.text = "当前任务:  "..M.config[index].condition
		self.award_txt.text = "任务奖励:  <color=#ff0000>"..M.config[index].award.."福利券</color>"
		self.slider.value = data.now_process/data.need_process
		if M.GetBet() >= M.config[index].num then
			if self.slider.value >= 1 then
				self.progress_txt.text = math.ceil(data.now_process/M.GetBet()).."/"..math.ceil(data.need_process/M.GetBet())
			else
				self.progress_txt.text = math.floor(data.now_process/M.GetBet()).."/"..math.ceil(data.need_process/M.GetBet())
			end
		else
			self.progress_txt.text = math.floor(data.now_process/M.config[index].num).."/"..math.ceil(data.need_process/M.config[index].num)
		end
		
	else
	end
end

function C:on_model_task_change_msg()
	self:RefreshTask()
end