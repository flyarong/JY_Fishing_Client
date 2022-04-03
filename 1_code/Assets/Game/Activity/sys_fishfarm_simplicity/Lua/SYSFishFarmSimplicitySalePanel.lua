-- 创建时间:2020-11-12
-- Panel:SYSFishFarmSimplicitySalePanel
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

SYSFishFarmSimplicitySalePanel = basefunc.class()
local C = SYSFishFarmSimplicitySalePanel
C.name = "SYSFishFarmSimplicitySalePanel"
local M = SYSFishFarmSimplicityManager
function C.Create(type,name,data,id,key)
	return C.New(type,name,data,id,key)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(type,name,data,id,key)
	self.type = type
	self.name = name
	self.data = data
	self.id = id
	self.key = key
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
	if self.type == "obj" then
		self.sale_num = 1
		self.rect1.gameObject:SetActive(false)
	else
		self.sale_num = GameItemModel.GetItemCount(self.key)
		self.rect1.gameObject:SetActive(true)
	end
	self.sale_num_max = self.sale_num

	EventTriggerListener.Get(self.yes_btn.gameObject).onClick = basefunc.handler(self, self.OnYesClick)
	EventTriggerListener.Get(self.no_btn.gameObject).onClick = basefunc.handler(self, self.OnNoClick)
	EventTriggerListener.Get(self.jian_btn.gameObject).onClick = basefunc.handler(self, self.OnJianClick)
	EventTriggerListener.Get(self.jia_btn.gameObject).onClick = basefunc.handler(self, self.OnJiaClick)

	self.award_list = {}
	for i=1,#self.data do
		local obj = GameObject.Instantiate(self.item,self.node.transform)
		obj.gameObject:SetActive(true)
		local tab = {}
		LuaHelper.GeneratingVar(obj.transform, tab)
		local cfg = GameItemModel.GetItemToKey(self.data[i].asset_type)
		tab.award_txt.text = StringHelper.ToCash(self.data[i].value * self.sale_num) .. cfg.name
		tab.award_img.sprite = GetTexture(cfg.image)
		self.award_list[#self.award_list + 1] = tab
	end
	self.desc_txt.text = "确认出售"..self.name.."吗?将获得下列道具…"

	dump(self.data)
	self:MyRefresh()
end

function C:MyRefresh()
	for i=1,#self.data do
		local cfg = GameItemModel.GetItemToKey(self.data[i].asset_type)
		self.award_list[i].award_txt.text = StringHelper.ToCash(self.data[i].value * self.sale_num) .. cfg.name
	end
	self.num_txt.text = self.sale_num
	if self.sale_num < 2 then
		self.jian_btn.gameObject:SetActive(false)
		self.no_jian.gameObject:SetActive(true)
	else
		self.jian_btn.gameObject:SetActive(true)
		self.no_jian.gameObject:SetActive(false)
	end

	if self.sale_num == self.sale_num_max then
		self.jia_btn.gameObject:SetActive(false)
		self.no_jia.gameObject:SetActive(true)
	else
		self.jia_btn.gameObject:SetActive(true)
		self.no_jia.gameObject:SetActive(false)
	end
end

function C:OnYesClick()
	--售卖
	if self.type == "obj" then
		M.SaleObj(self.id)
	elseif self.type == "prop" then
		M.SaleProp({self.key}, {self.sale_num})
	end
	self:MyExit()
end

function C:OnNoClick()
	self:MyExit()
end

function C:OnJianClick()
	self.sale_num = self.sale_num - 1
	self:MyRefresh()
end
function C:OnJiaClick()
	self.sale_num = self.sale_num + 1
	self:MyRefresh()
end