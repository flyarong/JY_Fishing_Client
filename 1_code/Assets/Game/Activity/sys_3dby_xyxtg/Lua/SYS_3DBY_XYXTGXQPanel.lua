-- 创建时间:2021-01-29
-- Panel:SYS_3DBY_XYXTGXQPanel
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

SYS_3DBY_XYXTGXQPanel = basefunc.class()
local C = SYS_3DBY_XYXTGXQPanel
C.name = "SYS_3DBY_XYXTGXQPanel"
local M = SYS_3DBY_XYXTGManager

function C.Create(call,finish_call)
	return C.New(call,finish_call)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["xyxtg_history_data_had_got_msg"] = basefunc.handler(self,self.on_xyxtg_history_data_had_got_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.finish_call and type(self.finish_call) == "function" then
		self.finish_call()
	end
	self:CloseXqPrefab()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(call,finish_call)
	ExtPanel.ExtMsg(self)
	self.call = call
	self.finish_call = finish_call
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	if self.call and type(self.call) == "function" then
		self.call()
	end

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	self.page_index = 1
	self.spawn_cell_list = {}
	M.QueryXqData(self.page_index)

	self.sv = self.ScrollView.transform:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		local VNP = self.sv.verticalNormalizedPosition
		if VNP <= 0 then
			self:RefreshHistoryInfo()		
		end
	end
end

function C:MyRefresh()
	self:CreateXqPrefab()
end

function C:OnBackClick()
	self:MyExit()
end

function C:CreateXqPrefab(data)
	for i=1,#data do
		local pre = SYS_3DBY_XYXTGXQItemBase.Create(self.Content.transform,data[i])
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CloseXqPrefab()
	if self.spawn_cell_list then
		for k,v in pairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
end

function C:on_xyxtg_history_data_had_got_msg(data,page_index)
	dump(data,"<color=red>************</color>")
	if data and page_index then
		if page_index == self.page_index then
			self:CreateXqPrefab(data)
			self.page_index = self.page_index + 1
		end
	else
		LittleTips.Create("当前无新数据")
	end
end

function C:RefreshHistoryInfo()
	M.QueryXqData(self.page_index)
end
