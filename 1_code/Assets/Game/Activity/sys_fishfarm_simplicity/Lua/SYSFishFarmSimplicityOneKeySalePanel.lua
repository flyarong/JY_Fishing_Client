-- 创建时间:2020-11-12
-- Panel:SYSFishFarmSimplicityOneKeySalePanel
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

SYSFishFarmSimplicityOneKeySalePanel = basefunc.class()
local C = SYSFishFarmSimplicityOneKeySalePanel
C.name = "SYSFishFarmSimplicityOneKeySalePanel"
local M = SYSFishFarmSimplicityManager
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
	EventTriggerListener.Get(self.yes_btn.gameObject).onClick = basefunc.handler(self, self.OnYesClick)
	EventTriggerListener.Get(self.no_btn.gameObject).onClick = basefunc.handler(self, self.OnNoClick)
	self.list = M.GetItemCountMoneyList()
	self.indexs = {}
	for i=1,#self.list do
		self.indexs[#self.indexs + 1] = 0
	end
	self.jingbi_txt.text = 0
	self:CreateItemPrefab()
	self:MyRefresh()
end

function C:MyRefresh()
	
end

function C:OnYesClick()
	--售卖
	if not table_is_null(self.props) then
		local num = {}
		for k,v in ipairs(self.props) do
			num[#num + 1] = GameItemModel.GetItemCount(v)
		end
		M.SaleProp(self.props, num)
		self:MyExit()
	else
		LittleTips.Create("请先选择鱼苗类型，再进行售卖鱼苗。")
	end
end

function C:OnNoClick()
	self:MyExit()
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	for i=1,#self.list do
		local pre = SYSFishFarmSimplicityOneKeySaleItemBase.Create(self,self.node.transform,i,self.list[i])
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

function C:RefreshJingBi(index,bool)
	if bool then
		self.indexs[index] = index
	else
		self.indexs[index] = 0
	end
	local jingbi = 0
	for k,v in pairs(self.indexs) do
		if v > 0 then
			jingbi = jingbi + self.list[v].award.jing_bi
		end
	end
	self.jingbi_txt.text = jingbi
	self.props = self.props or {}
	for m,n in pairs(self.indexs) do
		if n > 0 then
			for k,v in pairs(M.GetItemKeyByFsihType(n)) do
				self.props[#self.props + 1] = v
			end
		end
	end
end