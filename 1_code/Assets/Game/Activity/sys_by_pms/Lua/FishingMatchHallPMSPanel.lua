-- 创建时间:2020-04-24
-- Panel:FishingMatchHallPMSPanel
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

FishingMatchHallPMSPanel = basefunc.class()
local C = FishingMatchHallPMSPanel
C.name = "FishingMatchHallPMSPanel"
C.instance = nil
function C.Create(parent_transform)
	if C.instance then
		C.instance:MyRefresh()
		return
	end
	C.instance = C.New(parent_transform)
	return C.instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self,self.on_AssetChange)
    self.lister["model_pms_game_info_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self,self.on_model_vip_upgrade_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ClearCellList()
	C.instance = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent_transform)
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	SYSByPmsManager.GetPMSGameInfo()--请求剩余次数和排名数据
	SYSByPmsManager.update_time_query_PMS_Info()--每1分钟请求一次数据
	--self:MyRefresh()
end


function C:MyRefresh()
	self.pms_game_info = SYSByPmsManager.GetCurPMSGameInfo()
	self.today_remain_time_txt.text = self.pms_game_info.num

	self:ClearCellList()
	self.pms_list_cfg = SYSByPmsManager.GetFishingPMSListAndSort()
	dump(self.pms_list_cfg,"<color=red>++++++++++++++++++++++++++++++++++++++</color>")
	for k,v in ipairs(self.pms_list_cfg) do		
		local pre = FishingMatchHallPMSItem.Create(self.Content, v, self, k)
		self.CellList[#self.CellList + 1] = pre
	end

end
function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:OnOpenClick(index)
	FishingMatchHallBSXQPanel.Create(index,self,self.pms_list_cfg[index])
end

function C:OnSignupClick(index)
	local cfg = self.pms_list_cfg[index]
	dump(self.pms_list_cfg,"<color=blue>++++++++++++++++++++++++++++++++++++</color>")
	GameButtonManager.RunFun({gotoui = "sys_by_pms", data={id=cfg.id}}, "signup")
end

function C:on_AssetChange()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:RefreshTJ()
		end
	end
end

function C:on_model_vip_upgrade_change_msg()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:RefreshTJ()
		end
	end
end