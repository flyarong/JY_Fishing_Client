-- 创建时间:2021-05-08
-- Panel:sys_txz_taskitem
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

sys_txz_taskitem = basefunc.class()
local C = sys_txz_taskitem
C.name = "sys_txz_taskitem"
local M=SYS_TXZ_Manager

function C.Create(parent,config)
	return C.New(parent,config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    -- self.lister["model_get_task_award_response"] =basefunc.handler(self,self.on_get_task_award_response)

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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,config)
	ExtPanel.ExtMsg(self)
	local parent =parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.config=config
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	if self.config.type==1 then
		GetTextureExtend(self.taskType_img,"rw_bg_hwmr")
	elseif self.config.type==2 then
		GetTextureExtend(self.taskType_img,"rw_bg_mr")
	elseif self.config.type==3 then
		GetTextureExtend(self.taskType_img,"rw_bg_mz")
	end
	self.taskType_img:SetNativeSize()
	self.taskdes_txt.text=self.config.task_name
	self.addvalue_txt.text="+"..self.config.addvalue
	
	EventTriggerListener.Get(self.getaward_btn.gameObject).onClick = basefunc.handler(self, self.OnGetAwardClick)
	EventTriggerListener.Get(self.goto_btn.gameObject).onClick = basefunc.handler(self, self.OnGoToBtnClick)

	self:MyRefresh()
end

function C:MyRefresh()
	local task_data=GameTaskModel.GetTaskDataByID(self.config.task)
	if self.config.task==30010 or self.config.task==30017 then
		----分钟显示处理
		self.progress_1_txt.text=math.floor(task_data.now_process/60 ) .."/".. math.floor(task_data.need_process/60 )
		self.progress_2_txt.text=math.floor(task_data.now_process/60 ) .."/".. math.floor(task_data.need_process/60 )
	elseif self.config.task == 30018 then
		self.progress_1_txt.text = task_data.now_process / 100 .."/".. task_data.need_process / 100
		self.progress_2_txt.text = task_data.now_process / 100 .."/".. task_data.need_process / 100
	else
		self.progress_1_txt.text=task_data.now_process.."/".. task_data.need_process
		self.progress_2_txt.text=task_data.now_process.."/".. task_data.need_process
	end

	
	if self.config.gotoUI then
		self.progress_1_txt.gameObject:SetActive(false)
		self.progress_2_txt.gameObject:SetActive(task_data.award_status==0)
		self.getaward_btn.gameObject:SetActive(task_data.award_status==1)
		self.haveGot_btn.gameObject:SetActive(task_data.award_status==2)
		self.goto_btn.gameObject:SetActive(task_data.award_status==0)
	else
		self.progress_1_txt.gameObject:SetActive(task_data.award_status==0)
		self.progress_2_txt.gameObject:SetActive(false)
		self.getaward_btn.gameObject:SetActive(task_data.award_status==1)
		self.haveGot_btn.gameObject:SetActive(task_data.award_status==2)
		self.goto_btn.gameObject:SetActive(false)
	end
end

-- function C:on_get_task_award_response(data)
-- 	if data and data.result==0 then
-- 		if data.id==self.config.task then
-- 			self:MyRefresh()
-- 		end
-- 	end
-- end
function C:OnGetAwardClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	---海王每日登录判断是否购买
	--[[if self.config.task==30004 then
		if M.GetBuyBagType()==0 then
			LittleTips.Create("你尚未购买海王礼包！")
			return
		end
	end
	Network.SendRequest("get_task_award",{id=self.config.task})--]]
	SYS_TXZ_ChoosePanel.Create()
end
function C:OnGoToBtnClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if self.config.gotoUI then
		GameManager.CommonGotoScence({gotoui=self.config.gotoUI[1],	goto_scene_parm = self.config.gotoUI[2] or true})
		
	end
end
