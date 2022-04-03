-- 创建时间:2020-11-18
-- Panel:SYSFishFarmSimplicityFishFarmItemBase
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

SYSFishFarmSimplicityFishFarmItemBase = basefunc.class()
local C = SYSFishFarmSimplicityFishFarmItemBase
C.name = "SYSFishFarmSimplicityFishFarmItemBase"
local M = SYSFishFarmSimplicityManager
function C.Create(parent,index,config)
	return C.New(parent,index,config)
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
	self:StopTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,index,data)
	self.index = index
	self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.slider_hungry = self.percent_mask_hungry.transform:GetComponent("RectTransform")
	self.slider_growth = self.percent_mask_growth.transform:GetComponent("RectTransform")
	self.config = M.GetFishConfig(self.data.fish_id)
	self.stage = self.config.sum_stage_list[M.GetFishByState(self.config,self.data.level)]

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.sale_btn.gameObject).onClick = basefunc.handler(self, self.OnSaleClick)
	EventTriggerListener.Get(self.feed_btn.gameObject).onClick = basefunc.handler(self, self.OnFeedClick)
	EventTriggerListener.Get(self.harvest_btn.gameObject).onClick = basefunc.handler(self, self.OnHarvestClick)
	self:MyRefresh()
end

function C:MyRefresh()
	if not table_is_null(self.config) and not table_is_null(self.data) then
		self:RefreshBtn()
		--鱼名字
		self.fish_name_txt.text = self.config.name
		--鱼icon
		self.fish_icon_img.sprite = GetTexture(self.config.icon)
		--鱼的阶段
		self.fish_status_txt.text = "["..self.stage.name.."]"
		--需要饲料数量
		self.food_txt.text = self.stage.feed_consume
		--成长process
		self.growth_process_txt.text = self.data.level .. "/" .. self.config.sum_stage
		--售卖收益
		for i=1,#self.stage.sale_award do
			if self.stage.sale_award[i].asset_type == "jing_bi" then
				self.sale_price_txt.text = StringHelper.ToCash( self.stage.sale_award[i].value )
				break
			end
		end
		--已产出(金币)
		self.ycl_jingbi_txt.text = StringHelper.ToCash(self.data.jing_bi or 0)
		--已产出(星星)
		self.ycl_star_txt.text = StringHelper.ToCash(self.data.prop_fishbowl_stars or 0)
		self:StartTimer(true)
	end
end

function C:OnSaleClick()
	--售卖
	SYSFishFarmSimplicitySalePanel.Create("obj",self.config.name,self.stage.sale_award,self.data.id,nil)
end

function C:OnFeedClick()
	--喂养
	local my_food = M.GetFeedNum()
	if my_food >= self.stage.feed_consume then
		M.FeedFish(self.data.id)
	else
		LittleTips.Create("当前饲料不足")
	end
end

function C:RefreshDJS()
	local str
	if self.data.level < self.config.sum_stage then
		local temp = 0
		local hour = 0
		local minute = 0
		local second = 0

		temp = self.data.hungry - os.time()
		if temp > 0 then
			hour = math.floor(temp/3600)
			minute = math.floor((temp - hour*3600)/60)
			second = temp - hour*3600 - minute*60
			if string.len(hour) == 1 then
				hour = "0"..hour
			end
			if string.len(minute) == 1 then
				minute = "0"..minute
			end
			if string.len(second) == 1 then
				second = "0"..second
			end
			str = hour..":"..minute..":"..second
		else
			str = "已饥饿"
		end
	else
		str = "已成熟"
	end
	if self.hungry_djs_txt.text ~= str then
		self:RefreshBtn()
	end
	self.hungry_djs_txt.text = str
	--饥饿slider
	local p1 = (((self.data.hungry - os.time() >= 0) and self.data.hungry - os.time()) or ((self.data.hungry - os.time() < 0) and 0)) / self.stage.hunger_time
	self.slider_hungry.sizeDelta = Vector2.New(p1*192, 28)
	--成长slider
	local p2 = self.data.level / self.config.sum_stage
	self.slider_growth.sizeDelta = Vector2.New(p2*192, 28)
end

function C:StartTimer(b)
	self:StopTimer()
	if b then
		self:RefreshDJS()
		self.djs_timer = Timer.New(function ()
			self:RefreshDJS()
		end,1,-1,false)
		self.djs_timer:Start()
	end
end

function C:StopTimer()
	if self.djs_timer then
		self.djs_timer:Stop()
		self.djs_timer = nil
	end
end

function C:RefreshBtn()
	if self.data.collect and os.time() >= self.data.collect then--可收获
		self.feed_btn.gameObject:SetActive(false)
		self.harvest_btn.gameObject:SetActive(true)
		self.feed_img.gameObject:SetActive(false)
	else
		if self.data.hungry - os.time() > 0 then--饥饿倒计时
			self.feed_btn.gameObject:SetActive(false)
			self.harvest_btn.gameObject:SetActive(false)
			self.feed_img.gameObject:SetActive(true)
		else--已饥饿
			self.feed_btn.gameObject:SetActive(true)
			self.harvest_btn.gameObject:SetActive(false)
			self.feed_img.gameObject:SetActive(false)
		end
	end
end

function C:GetNeedFeedNum()
	return self.stage.feed_consume
end

function C:OnHarvestClick()
	M.HarvestObj(self.data.id)
end