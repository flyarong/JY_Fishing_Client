-- 创建时间:2020-04-16
-- Panel:ActiveDailyTaskPanel
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

FishFarmDailyTaskPanel = basefunc.class()
local C = FishFarmDailyTaskPanel
C.name = "FishFarmDailyTaskPanel"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}

	self.lister["sys_fishfarm_daytask_task_msg_finish_msg"] = basefunc.handler(self,self.MyRefresh)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["sys_fishfarm_daytask_task_msg_change_msg"] = basefunc.handler(self,self.RefreshItemPrefab)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseItemPrefab()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv2").transform
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
	self.back_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)

	self.spawn_cell_map = {}
	self.task_sort_list = {} -- 排序
	local task_cfg = FishFarmDailyTaskManager.GetTaskConfig()
	for i=1,#task_cfg do
		local pre = FishFarmDailyTaskItemBase.Create(self.TaskNode.transform, task_cfg[i].task_id, self)
		self.spawn_cell_map[task_cfg[i].task_id] = pre
		self.task_sort_list[i] = task_cfg[i].task_id
	end

	FishFarmDailyTaskManager.QueryData(true)
end

function C:MyRefresh()
	self:RefreshItemPrefab()
end

function C:RefreshItemPrefab()
	self.task_sort_list = FishFarmDailyTaskManager.GetTaskDataAndSort()
	for k,v in ipairs(self.task_sort_list) do
		if self.spawn_cell_map[v] then
			self.spawn_cell_map[v]:UpdateData(k)
		end
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_map then
		for k,v in pairs(self.spawn_cell_map) do
			v:MyExit()
		end
	end
	self.spawn_cell_map = {}
end

