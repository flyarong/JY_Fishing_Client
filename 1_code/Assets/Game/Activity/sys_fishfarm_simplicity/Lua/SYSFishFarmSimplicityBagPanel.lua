-- 创建时间:2020-11-18
-- Panel:SYSFishFarmSimplicityBagPanel
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

SYSFishFarmSimplicityBagPanel = basefunc.class()
local C = SYSFishFarmSimplicityBagPanel
C.name = "SYSFishFarmSimplicityBagPanel"
local M = SYSFishFarmSimplicityManager
function C.Create(panelSelf,parent,type)
	return C.New(panelSelf,parent,type)
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
    self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self,self.on_model_vip_upgrade_change_msg)
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

function C:ctor(panelSelf,parent,type)
	self.panelSelf = panelSelf
	self.type = type
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
	EventTriggerListener.Get(self.onekeysale_btn.gameObject).onClick = basefunc.handler(self, self.OnOneKeySaleClick)
	EventTriggerListener.Get(self.go_get_btn.gameObject).onClick = basefunc.handler(self, self.OnGoGetClick)
	if #M.GetBagList("prop_fishbowl_fry") <= 0 and self.type == "fishfarming" then
		self.have_fish.gameObject:SetActive(false)
		self.no_have_fish.gameObject:SetActive(true)
	else
		self:CheckIsShowOneKeySaleBtn()
		self.have_fish.gameObject:SetActive(true)
		self.no_have_fish.gameObject:SetActive(false)
	end
	self:MyRefresh()
end

function C:MyRefresh()
	if self.type == "fishfarmsimplicity" then
		self.bg1.gameObject:SetActive(true)
		self.bg2.gameObject:SetActive(false)
		self.ScrollView1.gameObject:SetActive(true)
		self.ScrollView2.gameObject:SetActive(false)
		self:CreateItemPrefab1()
	elseif self.type == "fishfarming" then
		self.bg1.gameObject:SetActive(false)
		self.bg2.gameObject:SetActive(true)
		self.ScrollView1.gameObject:SetActive(false)
		self.ScrollView2.gameObject:SetActive(true)
		self:CreateItemPrefab2()
	end
end

function C:CreateItemPrefab1()
	self.fish_list = M.GetBagList("prop_fishbowl_fry")
	self:CloseItemPrefab()
	for i=1,#self.fish_list do
		local pre = SYSFishFarmSimplicityBagItemBase.Create(self.Content1.transform,i,self.fish_list[i])
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CreateItemPrefab2()
	self.fish_list = M.GetBagList("prop_fishbowl_fry")
	self:CloseItemPrefab()
	for i=1,#self.fish_list do
		local pre = SYSFishFarmSimplicityBagItemBase.Create(self.Content2.transform,i,self.fish_list[i])
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

function C:OnOneKeySaleClick()
	--一键售卖
	SYSFishFarmSimplicityOneKeySalePanel.Create()
end

function C:CheckIsShowOneKeySaleBtn()
	self.onekeysale_btn.gameObject:SetActive(M.CheckIsShowOneKeySaleBtn())
end

function C:on_on_model_fishbowl_backpack_change_msg()
	self:MyRefresh()
end

function C:on_model_vip_upgrade_change_msg()
	self:CheckIsShowOneKeySaleBtn()
end

function C:OnGoGetClick()
	local game_id = GameFishing3DManager.GetTJGameID()
	Network.SendRequest("fsg_3d_signup", {id = game_id}, "请求报名", function (data)
	    if data.result == 0 then
	        GameManager.GotoSceneName("game_Fishing3D", {game_id = game_id})
	    else
	        HintPanel.ErrorMsg(data.result)
	    end
	end)
end