-- 创建时间:2020-08-13
-- Panel:Act_026_XRCDJ_CJPanel
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

Act_026_XRCDJ_CJPanel = basefunc.class()
local C = Act_026_XRCDJ_CJPanel
C.name = "Act_026_XRCDJ_CJPanel"
local M = Act_026_XRCDJManager

function C.Create(parent_transform, config)
	return C.New(parent_transform, config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["act_026_xrcdj_box_exchange_msg"] = basefunc.handler(self, self.on_box_exchange_msg)
    self.lister["act_026_xrcdj_task_change_msg"] = basefunc.handler(self, self.RefreshCenter)

    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["com_dial_cj_anim_finish_msg"] = basefunc.handler(self, self.com_dial_cj_anim_finish_msg)
    self.lister["act_026_xrcdj_query_finish_msg"] = basefunc.handler(self, self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.cj_pre then
		self.cj_pre:MyExit()
	end
	self:CloseCell()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent_transform, config)
	self.config = config
	self.award_config = M.GetAwardListByKey(config.award)
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.cj_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCJClick()
	end)
	self.up_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    	Event.Brocast("show_gift_panel")
	end)

	self.cj_img = self.cj_btn.transform:GetComponent("Image")
	self.cj_outline = self.cj_txt.transform:GetComponent("Outline")

	M.QueryData()
	-- self:MyRefresh()
end

function C:MyRefresh()
	self:CreateCell()
	local parm = {}
	parm.CellList = self.CellList
	parm.cell_size = {w=206, h=174}
	parm.map_size = {w=5, h=4}
	parm.key = "act_026_xrcdj"
	self.cj_pre = ComDialCJComponent.Create(parm)

	self:RefreshCenter()
end

function C:RefreshCenter()
	if not M.IsUnlock(self.config.id) then
		self.up_btn.gameObject:SetActive(true)
		self.task_txt.text = self.config.lock .. "  (" .. M.GetLJDay() .. "/" .. M.GetLJXYDay(self.config.id) .. ")\n"..self.config.lock2
	else
		self.up_btn.gameObject:SetActive(false)
		local task_data = M.GetTaskDataByTag(self.config.id)
		if task_data then
			if task_data.award_status == 0 or task_data.id ~= M.GetEndTaskIDByTag(self.config.id) then
				local task_cfg = M.GetTaskConfig(task_data.id)
				if task_data.id == 1000009 then
					self.task_txt.text = task_cfg.task_content .. " " .. math.floor(task_data.now_process / 100) .. "/" .. math.floor(task_data.need_process / 100)
				else
					self.task_txt.text = task_cfg.task_content .. " " .. task_data.now_process .. "/" .. task_data.need_process
				end
				self.hint_cj_num_txt.text = "抽奖次数+1"
			else
				self.task_txt.text = "已完成所有任务"
				self.hint_cj_num_txt.text = ""
				if M.IsFinishAllTask(self.config.id) then
					self.cj_img.sprite = GetTexture("ty_btn_ywc")
					self.cj_outline.effectColor = COLOR_HuiS_Outline
				end
			end
		else
			self.task_txt.text = "                         -"
		end
	end

	self.cj_num = GameItemModel.GetItemCount(self.config.item_key)
	self.cj_num_txt.text = "剩余次数：" .. self.cj_num
	if self.cj_num > 0 then
		self.hint_kuang.gameObject:SetActive(true)
	else
		self.hint_kuang.gameObject:SetActive(false)
	end

	local qt = M.GetFinishCJJD(1)-- 青铜
	local by = M.GetFinishCJJD(2)-- 白银
	local hj = M.GetFinishCJJD(3)-- 黄金
	self.hint_cj_jd_txt.text = string.format("三种转盘各抽一次奖额外奖励10元话费(青铜%s/%s 白银%s/%s 黄金%s/%s)", qt[1], qt[2], by[1], by[2], hj[1], hj[2])
end

function C:CreateCell()
	self:CloseCell()
	for i = 1, #self.award_config do
		local pre = ActXRCDJCJCellPrefab.Create(self.cell_root, self.award_config[i])
		self.CellList[#self.CellList + 1] = {pre=pre}
	end
end
function C:CloseCell()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v.pre:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:OnCJClick()
	if not self.cj_pre:IsCanCJ() then
		return
	end

	if not M.IsUnlock(self.config.id) then
		LittleTips.Create(self.config.lock)
	else
		if self.cj_num > 0 then
			Network.SendRequest("box_exchange",{id = self.config.box_id, num = 1}, "抽奖")
		else
			local task_data = M.GetTaskDataByTag(self.config.id)
			if task_data then
				if task_data.award_status == 0 then
					LittleTips.Create("完成任务可获得一次抽奖机会")
				else
					LittleTips.Create("已完成所有任务")
				end
			else
				LittleTips.Create("任务数据为空")
			end
		end
	end
end
function C:on_box_exchange_msg(data)
	local ii = 1
	for k,v in ipairs(self.award_config) do
		if v.id == data.award_id then
			ii = k
			break
		end
	end
	self.cj_pre:BeginCJAnim(ii)
	self:RefreshCenter()
end
-- task_newplayer_xrcdj1 task_newplayer_xrcdj2 task_newplayer_xrcdj3 获得抽奖券
function C:OnAssetChange(data)
	if data.change_type
		and (data.change_type == "box_exchange_active_award_37"
			or data.change_type == "box_exchange_active_award_38"
			or data.change_type == "box_exchange_active_award_39") then
		dump(data, "<color=red>OnAssetChange</color>")
		if data.data and #data.data > 0 then
			self.Award_Data = data
		end
	end
	self:RefreshCenter()
end

function C:com_dial_cj_anim_finish_msg(data)
	dump(data, "<color=red>com_dial_cj_anim_finish_msg</color>")
	if data and data.key == "act_026_xrcdj" and self.Award_Data then
		Event.Brocast("AssetGet", self.Award_Data)
		self.Award_Data = nil
	end
end