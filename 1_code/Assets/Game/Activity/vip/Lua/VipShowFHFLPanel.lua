-- 创建时间:2020-07-27
-- Panel:VipShowFHFLPanel
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

VipShowFHFLPanel = basefunc.class()
local C = VipShowFHFLPanel
C.name = "VipShowFHFLPanel"
local M = VIPManager
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
    self.lister["get_task_award_new_response"] = basefunc.handler(self,self.on_get_task_award_new_response)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
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
	self:MyRefresh()
	self.cur_lv_txt.text = "VIP"..M.get_vip_level()
	self:CreateItemPrefab()
end

function C:MyRefresh()
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	local cfg = M.GetFHFLData()
	self:Sort(cfg)
	dump(cfg)
	for i=1,#cfg do
		local pre = VipShowFHFLItemBase.Create(self.Content.transform,cfg[i],self)
		if pre then
			self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
		end
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


local m_sort = function(v1,v2)
	local data = GameTaskModel.GetTaskDataByID(M.GetFHFLTaskID())
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status(b, data, #M.GetFHFLData())

	if b[v1.index] ~= 1 and b[v2.index] == 1 then
		return true
	elseif b[v1.index] == 1 and b[v2.index] ~= 1 then
		return false
	else
		if b[v1.index] == 2 and b[v2.index] == 0 then
			return true
		elseif b[v1.index] == 0 and b[v2.index] == 2 then
			return false
		else
			if v1.index < v2.index then
				return false
			else
				return true
			end
		end
	end


end

function C:Sort(tab)
	MathExtend.SortListCom(tab, m_sort)
end

function C:Close()
	Event.Brocast("VIP_CloseTHENOpen")
end

function C:on_get_task_award_new_response(_,data)
	if data and data.id and self:CheckIsCareId(data.id) then
		self:CreateItemPrefab()
		self:CheckCanShow()
	end
end

function C:on_model_task_change_msg(data)
	dump(data,"<color=red>//////////////////////</color>")
	if data and data.id and self:CheckIsCareId(data.id) then
		self:CreateItemPrefab()
		self:CheckCanShow()
	end
end

function C:CheckIsCareId(id)
	local data = M.GetFHFLData()
	for i=1,#data do
		if data[i].task_id == id then
			return true
		end
	end
	return false
end

function C:CheckCanShow()
	local data = GameTaskModel.GetTaskDataByID(M.GetFHFLTaskID())
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status(b, data, #M.GetFHFLData())
	for i=1,#b do
		if b[i] and b[i] ~= 2 then
			return
		end
	end
	self:Close()
end