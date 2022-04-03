-- 创建时间:2020-11-25
-- Panel:FishFarmBagFishPanel
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

FishFarmBagFishPanel = basefunc.class()
local C = FishFarmBagFishPanel
C.name = "FishFarmBagFishPanel"
local M = SYSFishFarmSimplicityManager
function C.Create(panelSelf,parent)
	return C.New(panelSelf,parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["on_model_fishbowl_backpack_change_msg"] = basefunc.handler(self,self.on_on_model_fishbowl_backpack_change_msg)
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

function C:ctor(panelSelf,parent)
	self.panelSelf = panelSelf
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
	EventTriggerListener.Get(self.sale_btn.gameObject).onClick = basefunc.handler(self, self.OnSaleClick)
	self:MyRefresh()
end

function C:MyRefresh()
	self:CreateItemPrefab()
	if #self.spawn_cell_list > 0 then
		self:Selet(1)
		self.right.gameObject:SetActive(true)
	else
		self.right.gameObject:SetActive(false)
	end
end


function C:CreateItemPrefab()
	self.fish_list = M.GetBagList("prop_fishbowl_fish")
	self:CloseItemPrefab()
	for i=1,#self.fish_list do
		local pre = FishFarmBagItemBase.Create(self,self.Content.transform,i,self.fish_list[i],"fish")
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

function C:Selet(index)
	if index > #self.fish_list then
		index = 1
	end
	self:RefreshSelet(index)
	self:CheckRightInfo(index)
end

function C:RefreshSelet(index)
	local index = index or 1
	for k,v in pairs(self.spawn_cell_list) do
		v:RefreshUI(index)	
	end
end

function C:CheckRightInfo(index)
	local index = index or 1
	for k,v in pairs(self.spawn_cell_list) do
		v:GetInfo(index)
	end
end

function C:RefreshRightInfo(info)
	dump(info,"<color=yellow><size=15>++++++++++info++++++++++</size></color>")
	self.icon_img.sprite = GetTexture(info.config.icon)
	self.name_txt.text = info.config.name
	self.limit_txt.text = info.config.fish_limit .. "条"
	self.stage = info.config.sum_stage_list[M.GetFishByState(info.config,0)]
	self.jingbi_txt.text = self.stage.jb_produce_dec
	self.star_txt.text = self.stage.xx_produce_dec
	self.info = info
end

function C:on_on_model_fishbowl_backpack_change_msg()
	self:MyRefresh()
end

function C:OnSaleClick()
	-- 售卖
	SYSFishFarmSimplicitySalePanel.Create("prop",self.info.config.name,self.stage.sale_award,nil,self.info.key)
end