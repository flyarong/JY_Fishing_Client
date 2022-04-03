-- 创建时间:2020-07-21
-- Panel:ActiveDailyTask_JYFLEnterPrefab
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

ActiveDailyTask_JYFLEnterPrefab = basefunc.class()
local C = ActiveDailyTask_JYFLEnterPrefab
C.name = "ActiveDailyTask_JYFLEnterPrefab"
local M = ActiveDailyTaskManager
function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ActiveDailyTaskPanel_back"] = basefunc.handler(self,self.on_ActiveDailyTaskPanel_back)
    self.lister["ActiveDailyTaskManager_tag_change"] = basefunc.handler(self,self.MyRefresh)
    self.lister["sys_active_daily_task_msg_finish_msg"] = basefunc.handler(self,self.MyRefresh)
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

function C:ctor(parent, cfg)
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
	self.get_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	self.BG_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	local str
	if M.IsCanGetAward() then
		str = "领    奖"
	else
		str = "前    往"
	end
	self.get_txt.text = str
	if IsEquals(self.red) then
		self.red.gameObject:SetActive(M.IsCanGetAward())
	end
end

function C:OnGetClick()
	GameManager.GotoUI({gotoui = ActiveDailyTaskManager.key, goto_scene_parm="panel"})	
end

function C:on_ActiveDailyTaskPanel_back()
	self:MyRefresh()
end