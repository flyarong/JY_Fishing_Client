-- 创建时间:2020-08-03
-- Panel:BY3DZDKPEnterPanel
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

BY3DZDKPEnterPanel = basefunc.class()
local C = BY3DZDKPEnterPanel
C.name = "BY3DZDKPEnterPanel"
local M = BY3DZDKPManager

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["set_gun_auto_state"] = basefunc.handler(self, self.on_set_gun_auto_state)
    self.lister["zdkp_sy_gun_auto_msg"] = basefunc.handler(self, self.on_zdkp_sy_gun_auto_msg)
    self.lister["by3d_zdkp_query_auto_msg"] = basefunc.handler(self, self.on_by3d_zdkp_query_auto_msg)
    self.lister["by3d_zdkp_sy_auto_msg"] = basefunc.handler(self, self.on_by3d_zdkp_sy_auto_msg)
    self.lister["client_system_variant_data_change_msg"] = basefunc.handler(self, self.on_model_vip_upgrade_change_msg)
    self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self, self.on_model_vip_upgrade_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopTime()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
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
	self.auto_yes_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnAutoClick(true)
	end)
	self.auto_no_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnAutoClick(false)
	end)
	self.sy_down.gameObject:SetActive(false)

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshAuto()
	self:RefreshSY()
	if M.IsHintTJOpen() then
		--self.sy_hint.gameObject:SetActive(true)
		M.QueryAutoData()
	else
		--self.sy_hint.gameObject:SetActive(false)
		self:StopTime()
	end	
end

function C:RefreshAuto()
	local userdata = FishingModel.GetPlayerData()
    if userdata and userdata.is_auto then
    	self.auto_yes_btn.gameObject:SetActive(false)
    	self.auto_no_btn.gameObject:SetActive(true)
    else
    	self.auto_yes_btn.gameObject:SetActive(true)
    	self.auto_no_btn.gameObject:SetActive(false)
    end
end

function C:RefreshSY()
	self.is_sy_state = false
end

function C:OnAutoClick(is_auto)
	-- if not self.is_sy_state and M.IsHintTJOpen() then
	-- 	if M.m_data.is_query_wc then
	-- 		BY3DZDKPHintPanel.Create(function ()
	-- 			self:SetChangeAuto(true)
	-- 		end)
	-- 	else
	-- 		if M.m_data.result and M.m_data.result ~= 0 then
	-- 			Network.SendRequest("fsg_3d_query_auto_fire", nil, "")
	-- 		else
	-- 			LittleTips.Create("数据查询还未完成")
	-- 		end
	-- 	end
	-- else
	self:SetChangeAuto(is_auto and (VIPManager.get_vip_level() >= 1))
	if VIPManager.get_vip_level() < 1 then
		GameManager.GotoUI({gotoui="hall_activity", goto_scene_parm="panel"})
	end
	-- end
end

function C:on_model_vip_upgrade_change_msg()
	self:MyRefresh()
end

function C:SetChangeAuto(is_auto)
    local userdata = FishingModel.GetPlayerData()
    if is_auto then
        userdata.is_auto = true
        userdata.auto_index = 1
    else
        userdata.is_auto = false
        userdata.auto_index = 1
    end
    Event.Brocast("set_gun_auto_state", { seat_num=FishingModel.GetPlayerSeat() })
end
function C:on_by3d_zdkp_query_auto_msg()
	self.sy_time = M.GetSYTime()
	if self.sy_time > 0 then
		self.is_sy_state = true
		self:StartTime()
	end
end
function C:on_by3d_zdkp_sy_auto_msg()
	self.is_sy_state = true
	self:SetChangeAuto(true)
	self.sy_time = M.GetSYTime()
	self:StartTime()
end
function C:on_set_gun_auto_state(parm)
	if parm.seat_num == FishingModel.GetPlayerSeat() then
		self:RefreshAuto()
	end
end
function C:on_zdkp_sy_gun_auto_msg()
	Network.SendRequest("fsg_3d_use_auto_fire", nil, "试用自动开炮")
end
function C:StartTime()
	--self.sy_hint.gameObject:SetActive(false)
	self:StopTime()
	self.sy_down.gameObject:SetActive(true)
	self.update_time = Timer.New(function ()
		self:UpdateUI(true)
	end, 1, -1)
	self.update_time:Start()
	self:UpdateUI()
end

function C:StopTime()
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
	self.sy_down_txt.text = ""
end
function C:UpdateUI(b)
	if b then
		self.sy_time = self.sy_time - 1
	end

	if self.sy_time <= 0 then
		self:StopTime()
		self.is_sy_state = false
		self.sy_down.gameObject:SetActive(false)
		--self.sy_hint.gameObject:SetActive(true)
		self:SetChangeAuto(false)
		return
	end

	local mm = math.floor(self.sy_time / 60)
	local ss = self.sy_time % 60
    self.sy_down_txt.text = string.format("%02d", mm) .. ":" .. string.format("%02d", ss)
end
