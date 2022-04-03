-- 创建时间:2021-03-04
-- Panel:SYSLWGPHistoryPanel
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

SYSLWGPHistoryPanel = basefunc.class()
local C = SYSLWGPHistoryPanel
C.name = "SYSLWGPHistoryPanel"
local M = SYSLWGPManager

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
	
	self.lister["refresh_lwgp_history_data"]=basefunc.handler(self,self.on_refresh_lwgp_history_data)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ClearItemPre()
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
	ExtPanel.ExtMsg(self)
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
	self:MyRefresh()
	M.request_lwgp_query_history_data()
end

function C:MyRefresh()
end
function C:on_refresh_lwgp_history_data()
	self:ClearItemPre()

	local historyData=M.GetLwgpHistoryData()
	dump(historyData,"历史开奖数据： ")
	for index, value in ipairs(historyData) do
		local pre = SYSLWGPHistoryItemBase.Create(self.Content.transform,value)
		self.pre_cell[#self.pre_cell + 1] = pre
	end
end
function C:ClearItemPre()
	if self.pre_cell then
		for k,v in pairs(self.pre_cell) do
			v:MyExit()
		end
	end
	self.pre_cell = {}
end

