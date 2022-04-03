-- 创建时间:2020-12-11
-- Panel:Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTEnterPrefab
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

Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTEnterPrefab = basefunc.class()
local C = Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTEnterPrefab
C.name = "Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTEnterPrefab"
local M = Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTManager
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
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopChangeTimer()
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
	
	self.more_hd.gameObject:SetActive(true)
	self.more_fl.gameObject:SetActive(false)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterClick)
	self:ChangeTimer(true)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnEnterClick()
	Act_040_BY_AND_CJJ_TO_DDZ_CONDUCTPanel.Create()
end

function C:ChangeTimer(b)
	self:StopChangeTimer()
	if b then
		self.change_timer = Timer.New(function ()
			self:ChangeTips()
		end,3,-1,false)
	end
end

function C:StopChangeTimer()
	if self.change_timer then
		self.change_timer:Stop()
		self.change_timer = nil
	end
end

function C:ChangeTips()
	self.more_hd.gameObject:SetActive(not self.more_hd.gameObject.activeSelf)
	self.more_fl.gameObject:SetActive(not self.more_fl.gameObject.activeSelf)
end