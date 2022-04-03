-- 创建时间:2020-05-20
-- Panel:Act_040_MSLBEnterPrefab_InFLPanel
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

Act_040_MSLBEnterPrefab_InFLPanel = basefunc.class()
local C = Act_040_MSLBEnterPrefab_InFLPanel
C.name = "Act_040_MSLBEnterPrefab_InFLPanel"
local M = Act_040_MSLBManager
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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["model_mslb_data_change_msg"] = basefunc.handler(self,self.on_model_mslb_data_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	M.update_time_benefits(false)
	self:RemoveListener()
	destroy(self.gameObject)
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
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	EventTriggerListener.Get(self.BG_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	
	M.QueryData()
	M.update_time_benefits(true)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_model_mslb_data_change_msg()
	self.time_txt.text = "(还剩下"..Act_040_MSLBManager.GetTotalRemainNum().."天可领)"
	if M.GetIsReceive() == 1 then
		self.alreadyget_img.gameObject:SetActive(true)
		self.get_btn.gameObject:SetActive(false)
	else
		self.alreadyget_img.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(true)
	end
end

function C:OnGetClick()
	Act_040_MSLBPanel.Create()
end