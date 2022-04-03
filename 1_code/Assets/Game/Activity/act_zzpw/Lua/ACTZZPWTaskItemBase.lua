-- 创建时间:2021-09-13
-- Panel:ACTZZPWTaskItemBase
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

ACTZZPWTaskItemBase = basefunc.class()
local C = ACTZZPWTaskItemBase
C.name = "ACTZZPWTaskItemBase"
local M = ACTZZPWManager

function C.Create(parent,data,index)
	return C.New(parent,data,index)
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

function C:ctor(parent,data,index)
	ExtPanel.ExtMsg(self)
    self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

    if index % 2 == 0 then
        self.bg.gameObject:SetActive(true)
    end
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
    local data = GameTaskModel.GetTaskDataByID(self.data.task_id)
    if data then
        local showNowProcess = data.now_process
        local showNeedProcess = data.need_process
        if self.data.is_cz then
            showNowProcess = data.now_process / 100 
            showNeedProcess = data.need_process / 100 
        end
        if data.award_status == 0 then
            self.task_txt.text = self.data.task_desc .. "(" .. showNowProcess .. "/" .. showNeedProcess .. ")"
            self.award_txt.text = "段位点数+" .. self.data.award[2]
            self.num_txt.text = "+" .. self.data.award[1] 
        else
            self.task_txt.text = "<color=#00FF00>" .. self.data.task_desc .. "(" .. showNowProcess .. "/" .. showNeedProcess .. ")</color>"
            self.award_txt.text = "<color=#00FF00>段位点数+" .. self.data.award[2] .. "</color>"
            self.num_txt.text = "<color=#00FF00>+" .. self.data.award[1] .. "</color>"
        end
    else
        self.task_txt.text = self.data.task_desc
        self.award_txt.text = "段位点数+" .. self.data.award[2]
        self.num_txt.text = "+" .. self.data.award[1] 
    end
end
