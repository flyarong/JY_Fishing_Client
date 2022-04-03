-- 创建时间:2020-08-02
-- Panel:VipShowJHLBPanel
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

VipShowJHLBPanel = basefunc.class()
local C = VipShowJHLBPanel
C.name = "VipShowJHLBPanel"
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
	self:CreateItemPrefab()
end

function C:MyRefresh()
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	local cfg = M.GetJHLBData()
	self:Sort(cfg)
	for i=1,#cfg do
		local pre = VipShowJHLBItemBase.Create(self.Content.transform,cfg[i],self)
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
	if v1.gift_id > v2.gift_id then
		return true
	else
		return false
	end
end

function C:Sort(tab)
	MathExtend.SortListCom(tab, m_sort)
end


function C:Close()
	Event.Brocast("VIP_CloseTHENOpen")
end


function C:CheckCanShow()
	local temp = 0
	for k,v in pairs(M.GetJHLBData()) do
		if MainModel.GetGiftShopStatusByID(v.gift_id) == 0 then
			temp = temp + 1
		end
	end
	if temp >= #M.GetJHLBData() then
		self:Close()
	end
end