-- 创建时间:2021-01-04
-- Panel:SYS_JBP_JYFLEnterPrefab
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

SYS_JBP_JYFLEnterPrefab = basefunc.class()
local C = SYS_JBP_JYFLEnterPrefab
C.name = "SYS_JBP_JYFLEnterPrefab"
local M = SYS_JBPManager

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
    self.lister["jbp_value_has_change_msg"] = basefunc.handler(self,self.on_jbp_value_has_change_msg)
    self.lister["jbp_data_has_come_msg"] = basefunc.handler(self,self.on_jbp_data_has_come_msg)
    self.lister["jbp_award_had_got_msg"] = basefunc.handler(self,self.on_jbp_award_had_got_msg)
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

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.On_GetClick)
	self:MyRefresh()
end

function C:MyRefresh()
	self.lfl.gameObject:SetActive(M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get)
end

function C:On_GetClick()
	SYS_JBPPanel.Create()
end

function C:on_jbp_value_has_change_msg()
	self:MyRefresh()
end

function C:on_jbp_data_has_come_msg()
	self:MyRefresh()
end

function C:on_jbp_award_had_got_msg()
	self:MyExit()
end