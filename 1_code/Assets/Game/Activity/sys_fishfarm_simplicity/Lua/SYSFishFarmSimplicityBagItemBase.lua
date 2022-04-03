-- 创建时间:2020-11-18
-- Panel:SYSFishFarmSimplicityBagItemBase
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

SYSFishFarmSimplicityBagItemBase = basefunc.class()
local C = SYSFishFarmSimplicityBagItemBase
C.name = "SYSFishFarmSimplicityBagItemBase"
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,index,info)
	self.index = index
	self.info = info
	dump(self.info,"<color=yellow><size=15>++++++++++self.config++++++++++</size></color>")
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
		
	self.slider_hungry = self.percent_mask_hungry.transform:GetComponent("RectTransform")
	self.slider_growth = self.percent_mask_growth.transform:GetComponent("RectTransform")
	self.stage = self.info.config.sum_stage_list[M.GetFishByState(self.info.config,0)]

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.sale_btn.gameObject).onClick = basefunc.handler(self, self.OnSaleClick)
	EventTriggerListener.Get(self.put_btn.gameObject).onClick = basefunc.handler(self, self.OnPutClick)
	self:MyRefresh()
end

function C:MyRefresh()
	if not table_is_null(self.info) then
		--鱼数量
		self.num_txt.text = " x"..self.info.num
		--鱼名字
		self.fish_name_txt.text = self.info.config.name
		--鱼icon
		self.fish_icon_img.sprite = GetTexture(self.info.config.icon)
		--产量(金币)
		self.cl_jingbi_txt.text = self.stage.jb_produce_dec
		--产量(星星)
		self.cl_star_txt.text = self.stage.xx_produce_dec
		--饥饿slider
		self.slider_hungry.sizeDelta = Vector2.New(0, 28)
		--成长slider
		self.slider_growth.sizeDelta = Vector2.New(0, 28)
		--鱼的阶段
		self.fish_status_txt.text = "["..self.stage.name.."]"
		--需要饲料数量
		self.food_txt.text = self.stage.feed_consume
		--成长process
		self.growth_process_txt.text = "0/" .. self.info.config.sum_stage
		--售卖收益
		for i=1,#self.stage.sale_award do
			if self.stage.sale_award[i].asset_type == "jing_bi" then
				self.sale_price_txt.text = StringHelper.ToCash(self.stage.sale_award[i].value)
				break
			end
		end
		self:RefreshHungerTime()
	end
end

function C:RefreshHungerTime()
	local temp = self.stage.hunger_time
	local hour = math.floor(temp/3600)
	local minute = math.floor((temp - hour*3600)/60)
	--[[if string.len(hour) == 1 then
		hour = "0"..hour
	end--]]
	if string.len(minute) == 1 then
		minute = "0"..minute
	end
	self.hungry_djs_txt.text = hour.."小时"..minute.."分钟"
end

function C:OnSaleClick()
	--售卖
	SYSFishFarmSimplicitySalePanel.Create("prop",self.info.config.name,self.stage.sale_award,nil,self.info.key)
end

function C:OnPutClick()
	if M.GetCurFishbowlFishNum() < M.GetFishbowlMaxCount() then
		--投放
		M.PutProp(self.info.key)
	else
		LittleTips.Create("您的水族馆容量已满，请升级水族馆放入更多的鱼吧")
	end 
end

