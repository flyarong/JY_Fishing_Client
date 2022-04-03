-- 创建时间:2020-11-18
-- Panel:FishFarmUpLevelPanel
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

FishFarmUpLevelPanel = basefunc.class()
local C = FishFarmUpLevelPanel
C.name = "FishFarmUpLevelPanel"
local M = FishFarmManager

local max_level = M.GetMaxLevelFishBowl()
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
    self.lister["model_fishbowl_info"] = basefunc.handler(self, self.on_model_fishbowl_info)
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

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.kr_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:UpLevelOnClick()
    end)
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:MyExit()
    end)

end

function C:InitUI()
	M.QueryFishbowlInfo("")
end

function C:MyRefresh()
	self:RefreshUI()
end

function C:RefreshUI()
	local data = M.GetFishbowlInfo()
	if data.level ~= max_level then
		local data_bowl = M.GetFishbowlConfigByLevel(data.level)
		local up_level_data = (data.level+1) > max_level and max_level or (data.level+1)
		--下一级
		local level_up_bowl_data = M.GetFishbowlConfigByLevel(up_level_data)
		self.now_txt.text = "当前容量:"..data_bowl.capacity
		self.up_txt.text = "当前容量:"..level_up_bowl_data.capacity
		local cfg = M.GetFishbowlConfigByLevel(data.level)
		self.Slider.gameObject:GetComponent("Slider").value = data.exp/cfg.exp
	else
		self.now_txt.text = "当前容量:"..M.GetFishbowlConfigByLevel(data.level).capacity
		self.up_txt.text = "当前容量已达最高等级"
		self.Slider.gameObject:GetComponent("Slider").value = 1
	end
	self.zc_txt.text = GameItemModel.GetItemCount("prop_fishbowl_stars")
	self.level_txt.text = "Lv." .. data.level
end


function C:UpLevelOnClick()
	if M.GetFishbowlInfo().level == max_level then return end
	local level = M.GetFishbowlInfo().level -- > max_level and max_level or (M.GetFishbowlInfo().level + 1)
	self.infor = M.GetFishbowlConfigByLevel(level)
	
	-- local consume_list = {}
	-- if infor and infor.consume then
	-- 	if #infor.consume > 2 then
	-- 		consume_list[1] = {infor.consume[1],infor.consume[2],}
	-- 		consume_list[2] = {infor.consume[3],infor.consume[4],}
	-- 	else
	-- 		consume_list[1] = {infor.consume[1],infor.consume[2],}
	-- 	end
	-- end

	if M.GetFishbowlInfo().exp < self.infor.exp  then
		HintPanel.ErrorMsg("当前经验不足，养鱼和售卖鱼苗获得经验")
	else
		if #self.infor.consume > 2 then
			if GameItemModel.GetItemCount("prop_fishbowl_stars") < self.infor.consume[4] then
				HintPanel.ErrorMsg("当前星星不足，养鱼和售卖鱼苗获得星星")
			else
				self:IsCanUpBowlLevel()
			end
		else
			self:IsCanUpBowlLevel()
		end
	end
end

function C:IsCanUpBowlLevel()
	if GameItemModel.GetItemCount("jing_bi") < self.infor.consume[2] then
				HallLogic.gotoPay()
	else
		Network.SendRequest("fishbowl_upgrade",nil,"请求数据",function (data)
			dump(data)
			if data.result == 0 then
				--特效
				Network.SendRequest("fishbowl_info")
				--self:MyRefresh()
			end
		end)
	end
end

function C:on_model_fishbowl_info(data)
	if data and data.result == 0 then
		self:MyRefresh()
	else
		self:MyExit()
	end
end