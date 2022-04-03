-- 创建时间:2020-11-18
-- Panel:SYSFishFarmSimplicityFishFarmPanel
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

SYSFishFarmSimplicityFishFarmPanel = basefunc.class()
local C = SYSFishFarmSimplicityFishFarmPanel
C.name = "SYSFishFarmSimplicityFishFarmPanel"
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
    self.lister["fishbowl_collect_response"] = basefunc.handler(self,self.on_fishbowl_collect_response)
    self.lister["fishbowl_feed_response"] = basefunc.handler(self,self.on_fishbowl_feed_response)
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
	
	self.slider1 = self.Slider1.transform:GetComponent("Slider")
	self.slider2 = self.Slider2.transform:GetComponent("Slider")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.onekeyfeed_btn.gameObject).onClick = basefunc.handler(self, self.OnOneKeyFeedClick)
	EventTriggerListener.Get(self.add1_btn.gameObject).onClick = basefunc.handler(self, self.OnAddClick)
	EventTriggerListener.Get(self.add2_btn.gameObject).onClick = basefunc.handler(self, self.OnAddClick)
	EventTriggerListener.Get(self.go_get_btn.gameObject).onClick = basefunc.handler(self, self.OnGoGetClick)
	if M.GetCurFishbowlFishNum() <= 0 and self.type == "fishfarming" then
		self.have_fish.gameObject:SetActive(false)
		self.no_have_fish.gameObject:SetActive(true)
	else
		self.have_fish.gameObject:SetActive(true)
		self.no_have_fish.gameObject:SetActive(false)
	end
	self:MyRefresh()
end

function C:MyRefresh()
	if self.type == "fishfarmsimplicity" then
		self.bg1.gameObject:SetActive(true)
		self.bg2.gameObject:SetActive(false)
		self.Slider1.gameObject:SetActive(true)
		self.Slider2.gameObject:SetActive(false)
		self.ScrollView1.gameObject:SetActive(true)
		self.ScrollView2.gameObject:SetActive(false)
		self.capacity1_txt.text = "水族馆容量  " .. M.GetCurFishbowlFishNum() .. "/" .. M.GetFishbowlMaxCount()
		self.slider1.value = M.GetCurFishbowlFishNum() / M.GetFishbowlMaxCount()
		self:CreateItemPrefab1()
	elseif self.type == "fishfarming" then
		self.bg1.gameObject:SetActive(false)
		self.bg2.gameObject:SetActive(true)
		self.Slider1.gameObject:SetActive(false)
		self.Slider2.gameObject:SetActive(true)
		self.ScrollView1.gameObject:SetActive(false)
		self.ScrollView2.gameObject:SetActive(true)
		self.capacity2_txt.text = "水族馆容量  " .. M.GetCurFishbowlFishNum() .. "/" .. M.GetFishbowlMaxCount()
		self.slider2.value = M.GetCurFishbowlFishNum() / M.GetFishbowlMaxCount()
		self:CreateItemPrefab2()
	end
end

function C:CreateItemPrefab1()
	self.fish_list = M.GetFishbowlOfFishList()
	dump(self.fish_list,"<color=yellow><size=15>++++++++++self.fish_list++++++++++</size></color>")
	self:CloseItemPrefab()
	for i=1,#self.fish_list do
		local pre = SYSFishFarmSimplicityFishFarmItemBase.Create(self.Content1.transform,i,self.fish_list[i])
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CreateItemPrefab2()
	self.fish_list = M.GetFishbowlOfFishList()
	dump(self.fish_list,"<color=yellow><size=15>++++++++++self.fish_list++++++++++</size></color>")
	self:CloseItemPrefab()
	for i=1,#self.fish_list do
		local pre = SYSFishFarmSimplicityFishFarmItemBase.Create(self.Content2.transform,i,self.fish_list[i])
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

function C:OnOneKeyFeedClick()
	local my_food = M.GetFeedNum()
	dump(my_food,"<color=yellow><size=15>++++++++++my_food++++++++++</size></color>")
	local need_food = 0
	for k,v in pairs(self.spawn_cell_list) do
		need_food = need_food + v:GetNeedFeedNum()
	end
	local hungry_fish_num = 0
	for k,v in pairs(self.fish_list) do
		dump(v,"<color=yellow><size=15>++++++++++v++++++++++</size></color>")
		if tonumber(v.hungry) <= os.time() then
			hungry_fish_num = hungry_fish_num + 1
		end
	end
	if my_food >= need_food then
		if hungry_fish_num > 0 then--当前有饥饿的鱼
			--一键喂养
			M.FeedFish()
		else
			LittleTips.Create("当前没有饥饿的鱼哦")
		end
	else
		LittleTips.Create("当前饲料不足")
		--弹出饲料的获取途径界面
		FishFarmFeedPanel.Create()
	end
end

function C:on_on_model_fishbowl_backpack_change_msg()
	self:MyRefresh()
end

function C:on_fishbowl_collect_response()
	LittleTips.Create("收获成功!")
end

function C:on_fishbowl_feed_response()
	LittleTips.Create("喂养成功!")
end

function C:OnAddClick()
	--扩容
	FishFarmUpLevelPanel.Create()
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