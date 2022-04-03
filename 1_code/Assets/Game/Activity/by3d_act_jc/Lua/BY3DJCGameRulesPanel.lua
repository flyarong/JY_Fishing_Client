-- 创建时间:2020-09-11
-- Panel:BY3DJCGameRulesPanel
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

BY3DJCGameRulesPanel = basefunc.class()
local C = BY3DJCGameRulesPanel
C.name = "BY3DJCGameRulesPanel"

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
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:DeletRight_pre()
	self:CloseItemPrefab()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
	self.config = BY3DJCManager.GetRulseConfig()
	self:CreateItemPrefab()
	self:RefreshSelet()
	self:CreateRightPrefab()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	for i=1,#self.config do
		local pre = BY3DJCGameRulesLeftPrefab.Create(self.Content.transform,self.config[i],i,self)
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:RefreshSelet(index)
	local index = index or 1
	for k,v in pairs(self.spawn_cell_list) do
		v:RefreshSelet(index)	
	end
end

function C:Selet(index)
	self:RefreshSelet(index)
	self:CreateRightPrefab(index)
end

function C:on_BackClick()
	self:MyExit()
end

function C:CreateRightPrefab(index)
	self:DeletRight_pre()
	local index = index or 1
	if index == 1 then
		self.Right_pre = newObject(self.config[index].RightPrefab,self.PrefabNode.transform)
	else
		self.Right_pre = by3djc_rulse_2.Create(self.PrefabNode.transform) --newObject(self.config[index].RightPrefab,self.PrefabNode.transform)
	end
end

function C:DeletRight_pre()
	if self.Right_pre then
		destroy(self.Right_pre.gameObject)
		self.Right_pre = nil
	end
end