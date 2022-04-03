-- 创建时间:2021-05-06
-- Panel:SYS_TXZ_TaskPanel
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

SYS_TXZ_TaskPanel = basefunc.class()
local C = SYS_TXZ_TaskPanel
C.name = "SYS_TXZ_TaskPanel"
local M=SYS_TXZ_Manager
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
    self.lister["refresh_txz_level_task_data"] =basefunc.handler(self,self.MyRefresh)
    self.lister["refresh_txz_taskitem"] =basefunc.handler(self,self.on_refresh_txz_taskitem)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self.canGetQue=nil
	self.canGetQueIndex=nil
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
	ExtPanel.ExtMsg(self)
	local parent =parent or GameObject.Find("Canvas/LayerLv4").transform
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
	EventTriggerListener.Get(self.getall_btn.gameObject).onClick = basefunc.handler(self, self.OnGetAllBtnClick)
	self:CloseTaskItemPre()
	self:CreateTaskItemPre()
	
	self:MyRefresh()
end

function C:on_refresh_txz_taskitem()
	self:CloseTaskItemPre()
	self:CreateTaskItemPre()
end

function C:CreateTaskItemPre()
	local  taskInfo=M.GetTXZTaskConfigInfo()
	MathExtend.SortListCom(taskInfo,function (v1,v2)
		local v1taskInfo=GameTaskModel.GetTaskDataByID(v1.task)
		local v2taskInfo=GameTaskModel.GetTaskDataByID(v2.task)

		if (v1taskInfo.award_status == 1) and (v2taskInfo.award_status ~= 1) then
			return false
		elseif (v1taskInfo.award_status ~= 1) and (v2taskInfo.award_status == 1) then
			return true
		elseif (v1taskInfo.award_status == 2) and (v2taskInfo.award_status ~= 2) then
			return true
		elseif (v1taskInfo.award_status ~= 2) and (v2taskInfo.award_status == 2) then
			return false
		else
			if v1.line > v2.line then
				return true
			else
				return false	
			end
		end
	end)
	for index, value in ipairs(taskInfo) do
		local pre= sys_txz_taskitem.Create(self.content,value)
		self.task_cell[#self.task_cell+1] = pre
	end
end

function C:MyRefresh()
	self.nowlevel_txt.text=M.GetNowLevel()
	local buytxztype=M.GetBuyBagType()
	if buytxztype==0 then
		GetTextureExtend(self.txzname_img,"hwtxz_imgf_pt")
		GetTextureExtend(self.txzicon_img,"hwtxz_icon_bttxz")
	else
		GetTextureExtend(self.txzname_img,"hwtxz_imgf_hw")
		GetTextureExtend(self.txzicon_img,"hwtxz_icon_hwtxz")
	end
	self.txzicon_img:SetNativeSize()
	local progressInfo=M.GetTXZProgressInfo()
	local needPro=progressInfo.need_process- progressInfo.now_process
	if needPro>0  then
		self.progress_txt.text="距离升级还差".. needPro .."经验"
	else
		self.progress_txt.text="距离升级还差0经验"
	end
	local value=progressInfo.now_process/progressInfo.need_process
	self.prgress_front_img:GetComponent("RectTransform").sizeDelta = {x = value * 445, y = 31}
	local nextLevelInfo=M.GetNextLevelInfo()
	dump(nextLevelInfo,"nextLevelInfo:  ")
	GetTextureExtend(self.nextcommon_img,nextLevelInfo.icon[1])
	self.nextcommon_txt.text=nextLevelInfo.num[1]
	if M.GetBuyBagType()==2 then
		GetTextureExtend(self.haiwangcommon_img,nextLevelInfo.icon[3])
		self.haiwangcommon_txt.text=nextLevelInfo.num[3]
	else
		GetTextureExtend(self.haiwangcommon_img,nextLevelInfo.icon[2])
		self.haiwangcommon_txt.text=nextLevelInfo.num[2]
	end
end
function C:OnGetAllBtnClick()
 	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	 local  task_config=M.GetTXZTaskConfigInfo()
	 local canGettaskIds={}
	 for index, value in ipairs(task_config) do
		local taskinfo= GameTaskModel.GetTaskDataByID(value.task)
		if value.task~=30004 and taskinfo.award_status==1 then
			canGettaskIds[#canGettaskIds+1] = value.task
		elseif value.task==30004 and M.GetBuyBagType()~=0 and taskinfo.award_status==1 then
			canGettaskIds[#canGettaskIds+1] = value.task
		end
	 end
	 dump(canGettaskIds,"可领取的全部奖励ids:  ")

	 if #canGettaskIds>0 then
		self.canGetQue=canGettaskIds
		self.canGetQueIndex=1
		Network.SendRequest("get_task_award",{id=self.canGetQue[self.canGetQueIndex]},nil,function ()
			self:SendGetOneTaskAward()
		end) 
	 end
end

function C:SendGetOneTaskAward()
	if self.canGetQue and self.canGetQueIndex then
		self.canGetQueIndex=self.canGetQueIndex+1
		if self.canGetQueIndex<=#self.canGetQue then
			Network.SendRequest("get_task_award",{id=self.canGetQue[self.canGetQueIndex]},nil,function ()
				self:SendGetOneTaskAward()
			end) 
		else
			self.canGetQue=nil
			self.canGetQueIndex=nil
		end
	end
	
end

function C:CloseTaskItemPre()
	if self.task_cell then
		for k,v in pairs(self.task_cell) do
			v:MyExit()
		end
	end
	self.task_cell = {}
end
