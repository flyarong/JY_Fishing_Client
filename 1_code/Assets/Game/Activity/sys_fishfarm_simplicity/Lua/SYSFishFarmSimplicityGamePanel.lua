-- 创建时间:2020-11-11
-- Panel:SYSFishFarmSimplicityGamePanel
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

SYSFishFarmSimplicityGamePanel = basefunc.class()
local C = SYSFishFarmSimplicityGamePanel
C.name = "SYSFishFarmSimplicityGamePanel"
local M = SYSFishFarmSimplicityManager
local left_page = {"水族馆","背包",}
local right_name = {"SYSFishFarmSimplicityFishFarmPanel","SYSFishFarmSimplicityBagPanel"}

function C.Create(type)
	return C.New(type)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:DeletRight_pre()
	if self.left_pre then
		self.left_pre:MyExit()
		self.left_pre = nil
	end
	if self.right_pre then
		self.right_pre:MyExit()
		self.right_pre = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(type)
	self.type = type
	local parent = GameObject.Find("Canvas/LayerLv3").transform
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.gofishfarm_btn.gameObject).onClick = basefunc.handler(self, self.OnGoFishFarmClick)
	EventTriggerListener.Get(self.jingbi_add_btn.gameObject).onClick = basefunc.handler(self, self.OnAddJingBiClick)
	EventTriggerListener.Get(self.feed_add_btn.gameObject).onClick = basefunc.handler(self, self.OnAddFeedClick)
	self:CreateItemPrefab()
	self:RefreshSelet()
	self:CreateRightPrefab()
	self:MyRefresh()
end

function C:MyRefresh()
	if self.type == "fishfarmsimplicity" then
		self.title_img.sprite = GetTexture("szg_bt_szg")
		self.banner_img.gameObject:SetActive(true)
		self.gofishfarm_btn.gameObject:SetActive(true)
		self.jb.gameObject:SetActive(true)
		self.xx.gameObject:SetActive(true)
		self.sl.gameObject:SetActive(true)
	elseif self.type == "fishfarming" then
		self.title_img.sprite = GetTexture("szg_yy_imgf_yy")
		self.banner_img.gameObject:SetActive(false)
		self.gofishfarm_btn.gameObject:SetActive(false)
		self.jb.gameObject:SetActive(false)
		self.xx.gameObject:SetActive(false)
		self.sl.gameObject:SetActive(false)
	end
	self.title_img:SetNativeSize()
	self.jingbi_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.star_txt.text = StringHelper.ToCash(M.GetStarsNum())
	self.feed_txt.text = StringHelper.ToCash(M.GetFeedNum())
end

function C:OnAddJingBiClick()
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function C:OnAddFeedClick()
	FishFarmFeedPanel.Create()
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnGoFishFarmClick()
	--跳转到水族馆场景
	GameManager.GuideExitScene({gotoui="game_FishFarm"})
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	for i=1,#left_page do
		local pre = SYSFishFarmSimplicityLeftPage.Create(self,self.Content.transform,i,left_page[i])
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

function C:RefreshSelet(index)
	local index = index or 1
	for k,v in pairs(self.spawn_cell_list) do
		v:RefreshSelet(index)	
	end
end

function C:Selet(index)
	if index > #left_page then
		index = 1
	end
	self:RefreshSelet(index)
	self:CreateRightPrefab(index)
end

function C:CreateRightPrefab(index)
	self:DeletRight_pre()
	local index = index or 1
	local panelName = right_name[index]
	if _G[panelName] then
		if _G[panelName].Create then 
			self.Right_pre = _G[panelName].Create(self,self.right_node.transform,self.type)
		else
			dump("<color=red>该脚本没有实现Create</color>")
		end
	else
		dump("<color=red>该脚本没有载入</color>")
	end
end

function C:DeletRight_pre()
	if self.Right_pre then
		self.Right_pre:MyExit()
		self.Right_pre = nil
	end
end


function C:OnAssetChange()
	self:MyRefresh()
end

