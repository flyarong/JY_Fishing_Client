-- 创建时间:2020-10-22
-- Panel:BY3DPHBGamePanel
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

BY3DPHBGamePanel = basefunc.class()
local C = BY3DPHBGamePanel
C.name = "BY3DPHBGamePanel"
local M = BY3DPHBManager
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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.OnHelpClick)
	self.leftCfg = M.GetLeftPagecfg()
	self:CreateItemPrefab()
	self:RefreshSelet()
	self:CreateRightPrefab()
end

function C:MyRefresh()
end

function C:OnBackClick()
	self:MyExit()
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	for i=1,#self.leftCfg do
		local pre = BY3DPHBLeftPage.Create(self,self.Content.transform,i,self.leftCfg[i])
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
	if index > #self.leftCfg then
		index = 1
	end
	self:RefreshSelet(index)
	self:CreateRightPrefab(index)
end

function C:CreateRightPrefab(index)
	self:DeletRight_pre()
	local index = index or 1
	dump(M.GetCurRightPanelName(index),"<color=yellow>++++++++panel_type+++++++</color>")
	local panelName = M.GetCurRightPanelName(index)
	local right_config = M.GetCurRightConfig(index)
	if _G[panelName] then
		if _G[panelName].Create then 
			self.Right_pre = _G[panelName].Create(self,self.right_node.transform,right_config)
		else
			dump("<color=red>该脚本没有实现Create</color>")
		end
	else
		dump(panelName,"<color=red>该脚本没有载入</color>")
	end
end

function C:DeletRight_pre()
	if self.Right_pre then
		self.Right_pre:MyExit()
		self.Right_pre = nil
	end
end

function C:OnHelpClick()
	BY3DPHBRulesPanel.Create(self.Right_pre)
end

function C:ChangeBgImg(img_name)
	self.bg_img.sprite = GetTexture(img_name)
end