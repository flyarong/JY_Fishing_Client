-- 创建时间:2021-02-08
-- Panel:Act_XRXSFLTaskItemBase
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

Act_XRXSFLTaskItemBase = basefunc.class()
local C = Act_XRXSFLTaskItemBase
C.name = "Act_XRXSFLTaskItemBase"
local M = Act_XRXSFLManager

function C.Create(parent,config, panelSelf)
	return C.New(parent,config, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
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

function C:ctor(parent,config,panelSelf)
	ExtPanel.ExtMsg(self)
	self.config = config
	self.panelSelf = panelSelf
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
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
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	EventTriggerListener.Get(self.go_btn.gameObject).onClick = basefunc.handler(self, self.OnGoClick)
	self:MyRefresh()
end

function C:MyRefresh()
	if self.config.task_id == 1000352 then
		self.get_btn.gameObject.name = "@get_1_btn"
	end
	local data = GameTaskModel.GetTaskDataByID(self.config.task_id)
	self.task_txt.text = self.config.task_desc .. "<size=34><color=#ffffff>" .. data.now_process .. "/" .. data.need_process .. "</color></size>"
	self.award_txt.text = self.config.award_desc
	self.get_btn.gameObject:SetActive(data.award_status == 1 and not M.CheckIsOverdue())
	self.go_btn.gameObject:SetActive(data.award_status == 0 and not M.CheckIsOverdue())
	self.already_btn.gameObject:SetActive(data.award_status == 2 and not M.CheckIsOverdue())
	self.overdue_btn.gameObject:SetActive(M.CheckIsOverdue())
end

function C:OnGetClick()
	if self.config and self.config.task_id then
		M.GetTaskAward(self.config.task_id)
	end
end

function C:OnGoClick()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = "cpl_cjj", is_on_hint = true}, "CheckCondition")
	if a and b then
		if MainModel.myLocation ~= "game_Eliminate" then
			GameManager.CommonGotoScence({gotoui="game_Eliminate"})
			  
		else
			LittleTips.Create("您当前已在萌宠消消乐中")
		end
	else
		GameManager.GuideExitScene({gotoui = "game_Fishing3DHall"},self.panelSelf:MyExit())
	end
end