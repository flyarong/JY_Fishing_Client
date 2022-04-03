-- 创建时间:2020-07-29
-- Panel:SYSTGXTEnterPrefab
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

SYSTGXTEnterPrefab = basefunc.class()
local C = SYSTGXTEnterPrefab
C.name = "SYSTGXTEnterPrefab"
local M = SYSTGXTManager
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
    self.lister["sys_tgxt_red_state_change_msg"] = basefunc.handler(self,self.sys_tgxt_red_state_change_msg)   
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
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterClick)
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshRed()
	self:RefreshFL()
end

function C:OnEnterClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

	local b = M.GetLocalData("red1")
	M.SetLocalData("dj")
	M.SetLocalData("cash")
	M.SetLocalData("red1", 1)

	if b == 0 then
		self:on_EnterClick1()
	else
		self:on_EnterClick2()
	end
end
function C:sys_tgxt_red_state_change_msg()
	self:MyRefresh()
end
function C:on_EnterClick2()
	SYSTGXTPanel.Create()
end

function C:on_EnterClick1()
	SYSTGXTPanel.Create()
	SYSTGXTMyAwardPanel.Create()
end

function C:RefreshRed()
	if M.GetLocalData("dj") == 0 then
		self.red.gameObject:SetActive(true)
	else
		self.red.gameObject:SetActive(false)
	end
end
function C:RefreshFL()
	if M.GetLocalData("red1") == 0 then	
		self.LFL.gameObject:SetActive(true)				
	else
		self.LFL.gameObject:SetActive(false)	
	end
end
