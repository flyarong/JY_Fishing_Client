-- 创建时间:2020-07-29
-- Panel:FishFarmSalePanel
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

FishFarmSalePanel = basefunc.class()
local C = FishFarmSalePanel
C.name = "FishFarmSalePanel"

function C.Create(fish_map)
	return C.New(fish_map)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(fish_map)
	self.fish_map = fish_map
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
	EventTriggerListener.Get(self.sale_btn.gameObject).onClick = basefunc.handler(self, self.on_SaleClick)
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)

	local all_money = 0
	for i=1, 5 do
		local cfg = FishFarmModel.GetFishConfig(i)
		local n = self.fish_map[i] or 0
		self["fish"..i.."_txt"].text = cfg.name .. " x" .. n
		all_money = all_money + cfg.money * n
	end
	self.tips_txt.text = "全部出售可获得    "..all_money.."金币"
	self:MyRefresh()
end

function C:MyRefresh()
end


function C:on_SaleClick()
	Network.SendRequest("fishbowl_sale", nil, "")
	self:MyExit()
end

function C:on_BackClick()
	self:MyExit()
end