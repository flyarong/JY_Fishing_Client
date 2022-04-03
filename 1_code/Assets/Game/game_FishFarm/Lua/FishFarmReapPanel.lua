-- 创建时间:2020-11-12
-- Panel:FishFarmReapPanel
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

FishFarmReapPanel = basefunc.class()
local C = FishFarmReapPanel
C.name = "FishFarmReapPanel"
local M = FishFarmManager

function C.Create(data)
	return C.New(data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
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

function C:ctor(data)
	self.data = data
	local parent = GameObject.Find("Canvas/LayerLv1").transform
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
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.share_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnShareClick()
	end)
	self.bag_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBagClick()
	end)
	self.sale_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnSaleClick()
	end)
	self.up_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnUpClick()
	end)

	self.tool_data = FishFarmManager.GetObjToolData(self.data.obj_id)
	self.config = FishFarmManager.GetFishConfig(self.tool_data.fish_id)
	
	dump(self.tool_data)
	
	self:MyRefresh()
end

function C:MyRefresh()
	local award_list = M.GetSaleAwardByObjID(self.data.obj_id)
	local jb = 0
	for k,v in ipairs(award_list) do
		if v.asset_type == "jing_bi" then
			jb = jb + v.value
		end
	end
	self.sale_money_txt.text = jb

	self.fish_name_txt.text = self.config.name

	self.jb_txt.text = self.tool_data.jing_bi or 0
	self.xx_txt.text = self.tool_data.prop_fishbowl_stars or 0
	self.fish_img.sprite = GetTexture(self.config.icon)
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnShareClick()
	dump("OnShareClick")
end
function C:OnBagClick()
	dump("OnBagClick")
	Network.SendRequest("fishbowl_capture",{obj_id = self.data.obj_id}, "", function(data)
		dump(data, "fishbowl_capture")
	end)
end
function C:OnSaleClick()
	dump("OnSaleClick")
	Network.SendRequest("fishbowl_sale_obj",{obj_id = self.data.obj_id}, "", function(data)
		dump(data, "fishbowl_sale_obj")
	end)
end
function C:OnUpClick()
	dump("OnUpClick")
	LittleTips.Create("跃龙门还没有")
end
