-- 创建时间:2020-11-12
-- Panel:FishFarm3DUI
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

FishFarm3DUI = basefunc.class()
local C = FishFarm3DUI
C.name = "FishFarm3DUI"
local M = FishFarmManager

local FishFarmStatus = {
	CS = "成熟",
	SB = "收宝",
	WS = "喂食",
	ZC = "正常",
}

function C.Create(parent, data)
	return C.New(parent, data)
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
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
	self:StopFace()
	self:kill_seq_new_fish()

	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, data)
	self.data = data
	self.parent = parent
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
	self.update_time = Timer.New(function ()
		self:RefreshState()
	end, 1, -1, nil, true)
	self.update_time:Start()

	self.click_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnClick()
	end)
	self.status_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnStatusClick()
	end)
	self:MyRefresh()
end

function C:GetStatus()
	local cur_t = MainModel.GetCurTime()
	if self.tool_data.level == self.config.sum_stage then
		return FishFarmStatus.CS
	else
		if self.tool_data.collect and self.tool_data.collect > 0 and cur_t >= self.tool_data.collect then
			return FishFarmStatus.SB
		elseif cur_t >= self.tool_data.hungry then
			return FishFarmStatus.WS
		else
			return FishFarmStatus.ZC
		end
	end
end

function C:MyRefresh()
	self.tool_data = FishFarmManager.GetObjToolData(self.data.obj_id)
	self.config = FishFarmManager.GetFishConfig(self.tool_data.fish_id)

	self:RefreshState()
end

function C:RefreshState()
	local s = self:GetStatus()
	if s == self.cur_status then
		return
	end
	self.cur_status = s
	self.status.gameObject:SetActive(true)
	if s == FishFarmStatus.CS then
		self.status_img.sprite = GetTexture("szzg_iocn_bh")
	elseif s == FishFarmStatus.SB then
		self.status_img.sprite = GetTexture("szzg_iocn_sb")
	elseif s == FishFarmStatus.WS then
		self.status_img.sprite = GetTexture("szzg_iocn_yl")
	else
		self.status.gameObject:SetActive(false)
	end
	self.status_img:SetNativeSize()
end

function C:UpdateTransform(pos)
	self.transform.position = FishFarmModel.Get2DToUIPoint(pos)
end

function C:OnClick()
	local s = self:GetStatus()
	if s == FishFarmStatus.CS then
		FishFarmReapPanel.Create(self.data)
	else
		FishFarmInfoPanel.Create(self.data)
	end
end

function C:OnStatusClick()
	local s = self:GetStatus()
	if s == FishFarmStatus.CS then
		Network.SendRequest("fishbowl_capture",{obj_id = self.tool_data.id}, "", function(data)
			dump(data, "fishbowl_capture")
		end)
	elseif s == FishFarmStatus.SB then
		Network.SendRequest("fishbowl_collect",{obj_id = self.tool_data.id}, "")
	elseif s == FishFarmStatus.WS then
		self.state = M.GetFishByState(self.config, self.tool_data.level)
		local cfg = self.config.sum_stage_list[self.state]
		if cfg.feed_consume <= GameItemModel.GetItemCount("prop_fishbowl_feed") then
			Network.SendRequest("fishbowl_feed",{obj_id = self.tool_data.id}, "", function(data)
				dump(data, "fishbowl_feed")
			end)
		else
			LittleTips.Create("饲料不够!")
		end

	else
		dump(self.tool_data, "正常状态")
	end
end

function C:PlayNewAddFish()
	if not self.fishbowl_new_fish then
		self.fishbowl_new_fish = newObject("fishbowl_new_fish", self.transform)
	end
	self:kill_seq_new_fish()

	self.fishbowl_new_fish.gameObject:SetActive(true)
	self.new_fish_seq = DoTweenSequence.Create()
    self.new_fish_seq:AppendInterval(2)
    self.new_fish_seq:OnKill(function ()
    	self.fishbowl_new_fish.gameObject:SetActive(false)
    end)
    self.new_fish_seq:OnForceKill(function()
    end)
end
function C:kill_seq_new_fish()
	if self.new_fish_seq then
		self.new_fish_seq:Kill()
		self.new_fish_seq = nil
	end
end

function C:PlayCollect(data)
	Event.Brocast("ui_fish_bowl_collect_msg", {pos=self.transform.position, data=data})
end

function C:PlayFaceAnim(cfg)
	self.face_obj = GameObject.Instantiate(GetPrefab(cfg.effect), self.transform)
	self.face_obj.transform.localPosition = Vector3.New(0, 0, 0)
	self.face_obj.transform.localRotation = Quaternion.Euler(0, 0, 0)

	if cfg.voice and cfg.voice ~= "" then
		ExtendSoundManager.PlaySound(cfg.voice .. ".mp3", 1)
	end

	if cfg.type == 1 then--文字
		self.face_obj.transform:Find("Image/@desc_txt"):GetComponent("Text").text = cfg.decs
	elseif cfg.type == 2 then--表情
	end

	self.face_time = Timer.New(function ()
		self:StopFace()
	end, cfg.run_time, 1, nil, true)
	self.face_time:Start()
end
function C:StopFace()
	if self.face_time then
		self.face_time:Stop()
		self.face_time = nil
		Event.Brocast("ui_fish_bowl_stop_fishface_msg", {obj_id=self.data.obj_id})
	end
end