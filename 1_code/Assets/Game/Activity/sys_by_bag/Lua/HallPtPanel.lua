-- 创建时间:2020-06-04
-- Panel:HallPtPanel
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

HallPtPanel = basefunc.class()
local C = HallPtPanel
C.name = "HallPtPanel" 
local M = SYSByBagManager

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
    self.lister["NewPersonPanel_OnBackClik_msg"] = basefunc.handler(self,self.MyExit)
    self.lister["model_by_bag_gun_info_change"] = basefunc.handler(self,self.MyRefresh)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
--FFF949
function C:MyExit()
	self:CloseCellList()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)

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
	M.QueryGunInfo()
end

function C:MyRefresh()
	self:RefreshCellList()
	self.pt_txt.text ="<color=#FFF949>".. M.GetGunNum().."</color>" .. "<size=30>/".. M.GetGunMaxNum().."</size>"
end


function C:CheckCellList()
	local data = M.m_data.GunInfo
	if not data then
		data = {}
		data.barrel_list = {}
	end
	self.barrel_list = data.barrel_list
	local cell_data = {}

	local callSortGun = function(v1,v2)
		--排序
		if v1.is_get == 1 and v2.is_get ~= 1 then
			return false
		elseif v1.is_get ~= 1 and v2.is_get == 1 then
			return true
		end
		if v1.order and v2.order then
			if v1.order > v2.order then
				return true
			elseif v1.order < v2.order then
				return false
			end
		end
		if v1.id < v2.id then
			return false
		else return true end
	end

	for k,v in pairs (M.UIConfig.barrel_config) do
		cell_data[#cell_data+1] = basefunc.deepcopy(v)
		if MainModel.IsLowPlayer() and cell_data[#cell_data].ext_buy_parm then
			cell_data[#cell_data].buy_parm = cell_data[#cell_data].ext_buy_parm
		end
	end
	for k,v in pairs (self.barrel_list) do
		--服务器数据
		if v.id and cell_data[v.id] then
			if tonumber(v.time) == 0 or tonumber(v.time) > os.time() then
				cell_data[v.id].is_get = 1
				cell_data[v.id].time = v.time
			else
				cell_data[v.id].is_get = 0
			end
		end
	end
	MathExtend.SortListCom(cell_data,callSortGun)
	return cell_data
end

-- 道具
function C:RefreshCellList()
	self:CloseCellList()
	self.cell_data = self:CheckCellList()
	dump(self.cell_data,"<color>++++++++++++++++++++++++++++++</color>")
	for k,v in pairs(self.cell_data) do
		local pre = HallPtItem.Create(v, self.Content)
		self.CellList[#self.CellList + 1] = pre
	end
end

function C:CloseCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:MyExit()
		end
	end
	self.CellList = {}
end
