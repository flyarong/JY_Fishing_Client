-- 创建时间:2020-09-11
-- Panel:by3djc_rulse_2
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

by3djc_rulse_2 = basefunc.class()
local C = by3djc_rulse_2
C.name = "by3djc_rulse_2"

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
    self.lister["get_award_time_num_msg"] = basefunc.handler(self, self.get_award_time_num_msg)
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
	--Network.SendRequest("fish_3d_query_geted_award_pool_num")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:get_award_time_num_msg()
end

function C:get_award_time_num_msg()
	local  zmcj_time = BY3DJCManager.GetZMCJTime()
	if IsEquals(self.gameObject) then
		if zmcj_time then
			for i=1,2 do
				self["can_"..i.."_txt"].text = "持有：x"..zmcj_time[i] or 0
			end
		else
			self.can_1_txt.text = "持有：x0"
			self.can_2_txt.text = "持有：x0"
		end
	else
		return
	end
end
