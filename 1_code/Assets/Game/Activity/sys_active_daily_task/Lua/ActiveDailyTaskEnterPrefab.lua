-- 创建时间:2020-04-16
-- Panel:ActiveDailyTaskEnterPrefab
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

ActiveDailyTaskEnterPrefab = basefunc.class()
local C = ActiveDailyTaskEnterPrefab
C.name = "ActiveDailyTaskEnterPrefab"

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
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
    self.lister["ActiveDailyTaskPanel_back"] = basefunc.handler(self,self.on_ActiveDailyTaskPanel_back)
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
	self.enter_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		PlayerPrefs.SetString(ActiveDailyTaskManager.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
		ActiveDailyTaskPanel.Create()
		self:MyRefresh()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	if ActiveDailyTaskManager.GetHintState({gotoui = ActiveDailyTaskManager.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		if IsEquals(self.LFL) then
			self.LFL.gameObject:SetActive(true)
		end
	else
		if IsEquals(self.LFL) then
			self.LFL.gameObject:SetActive(false)
		end
		--dump(PlayerPrefs.GetString(ActiveDailyTaskManager.key .. MainModel.UserInfo.user_id,0),"<color=red>MMMMMMMMMMMMMMMMMMMMMMMMMM</color>")
		--dump(os.date("%Y%m%d",os.time()),"<color=red>MMMMMMMMMMMM1---MMMMMMMMMMMMMM</color>")
		
		if PlayerPrefs.GetString(ActiveDailyTaskManager.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.Red.gameObject:SetActive(false)
		else
			self.Red.gameObject:SetActive(true)
		end 
	end
end


function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == ActiveDailyTaskManager.key then 
		self:MyRefresh()
	end 
end

function C:on_ActiveDailyTaskPanel_back()
	self:MyRefresh()
end