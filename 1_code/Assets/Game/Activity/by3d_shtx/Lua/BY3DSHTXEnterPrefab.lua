-- 创建时间:2020-10-27
-- Panel:BY3DSHTXEnterPrefab
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

BY3DSHTXEnterPrefab = basefunc.class()
local C = BY3DSHTXEnterPrefab
C.name = "BY3DSHTXEnterPrefab"
local M = BY3DSHTXManager
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["by3d_shtx_cur_task_data_is_queried"] = basefunc.handler(self, self.on_by3d_shtx_cur_task_data_is_queried)
	self.lister["by3d_shtx_cur_task_data_is_change"] = basefunc.handler(self, self.on_by3d_shtx_cur_task_data_is_change)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
	self.lister["fishing_ready_finish"] = basefunc.handler(self, self.on_fishing_ready_finish)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:StopTimer()
	self:KillTween()
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
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.Slider = self.slider.transform:GetComponent("Slider")
	self.is_on = true
	self.on.gameObject:SetActive(self.is_on)
	self.off.gameObject:SetActive(not self.is_on)
	self.tipRoot.gameObject:SetActive(false)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.on_EnterClick)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.on_GetClick)
	EventTriggerListener.Get(self.on_off_btn.gameObject).onClick = basefunc.handler(self, self.on_OnOffClick)
	if M.CheckIsInGuide() then
		self:RefreshUI_Guide()
	else
		M.QueryCurLayerTaskId()
	end

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_EnterClick()
	if M.CheckIsInGuide() then
	else
		BY3DSHTXPanel.Create()
	end
end

function C:on_by3d_shtx_cur_task_data_is_queried()
	if M.CheckIsInGuide() then
	else
		self:RefreshUI()
		self:ShowTipAffect()
	end
end

-- function C:JudgeFlagState()
-- 	if self.isInitShowAffect then
-- 		if not self.isNewGame then
-- 			self:ShowTipAffect()
-- 			self.isInitShowAffect = false
-- 			return
-- 		else
-- 			--延迟改变标识
-- 			self.delayTimer =Timer.New(
-- 				function()
-- 					if self.delayTimer then
-- 						self.isInitShowAffect=false
-- 						self.delayTimer:Stop()
-- 					end
-- 				end,
-- 				2,-1
-- 			)
-- 		end
-- 	else
-- 		self:ShowTipAffect()
-- 	end
-- end

function C:on_GetClick()
	M.GetAward()
end

function C:on_by3d_shtx_cur_task_data_is_change()
	if M.CheckIsInGuide() then
	else
		self:RefreshUI()
	end
end

function C:RefreshUI()
	local config = M.GetCurTaskConfig()
	local data = M.GetCurTaskData()
	local cur_layer = M.GetCurLayer()
	self.layer_txt.gameObject:SetActive(true)
	self.layer_txt.text = "第" .. cur_layer .. "层"
	self.icon_img.sprite = GetTexture(config.task_icon)
	if data then
		if data.award_status == 0 then
			self.task_txt.text = config.text
			self.Slider.value = data.now_process / data.need_process
			self.process_txt.text = StringHelper.ToCash(data.now_process) .. "/" .. StringHelper.ToCash(data.need_process)
		end
		if config.random == 0 then
			self.award_img.sprite = GetTexture(config.award_img[1])
			self.award_txt.text = config.award_txt[1]
		elseif config.random == 1 then
			self.award_img.sprite = GetTexture("问号宝箱图片")
			self.award_txt.text = "随机奖励"
		end
		self:RefreshIconSizeAndPosition()
		self.before.gameObject:SetActive(data.award_status == 0)
		self.after.gameObject:SetActive(data.award_status == 1)
	end
end

function C:RefreshIconSizeAndPosition()
	local config = M.GetCurTaskConfig()
	self.icon_img:SetNativeSize()
	local rect = self.icon_img.gameObject:GetComponent("RectTransform")
	if config.icon_id == 1 then
		rect.sizeDelta = Vector2.New(277.76, 230.72)
		self.icon_img.transform.localPosition = Vector3.New(-208, 0, 0)
	elseif config.icon_id == 2 then
		rect.sizeDelta = Vector2.New(120, 120)
		self.icon_img.transform.localPosition = Vector3.New(-208, 10, 0)
	end
end

function C:on_OnOffClick()
	if self.is_on then
		self.is_on = false
		self:offTween()
	else
		self.is_on = true
		self:onTween()
	end
	self.on.gameObject:SetActive(self.is_on)
	self.off.gameObject:SetActive(not self.is_on)
end

function C:onTween()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.bg.transform:DOLocalMoveX(0, 0.25))
end

function C:offTween()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.bg.transform:DOLocalMoveX(270, 0.25))
end

function C:KillTween()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
end

local config = {
	[1] = {
		task_id = 30019,
		layer_txt = "第1层",
		icon_img = "3dby_icon_wang1",
		task_txt = "捕获任意鱼5条",
		award_img = "ty_icon_flq2",
		award_txt = "福利券*20",
	},
	[2] = {
		task_id = 30020,
		layer_txt = "第2层",
		icon_img = "3dby_btn_sd",
		task_txt = "使用1次锁定",
		award_img = "ty_icon_flq2",
		award_txt = "福利券*5",
	},
	[3] = {
		task_id = 30021,
		layer_txt = "第3层",
		icon_img = "rw_icon_mrzz",
		task_txt = "累计消耗3万金币",
		award_img = "pay_icon_gold2",
		award_txt = "金币*5000",
	},
	[4] = {
		task_id = 30022,
		layer_txt = "第4层",
		icon_img = "rw_icon_mrzz",
		task_txt = "累计消耗5万金币",
		award_img = "pay_icon_gold3",
		award_txt = "金币*1万",
	},
	[5] = {
		task_id = 30023,
		layer_txt = "第5层",
		icon_img = "3dby_icon_wang1",
		task_txt = "累计开炮500发",
		award_img = "ty_icon_flq2",
		award_txt = "福利券*10",
	},
}

function C:RefreshUI_Guide()
	local tab = {}
	for i=1,5 do
		local data = GameTaskModel.GetTaskDataByID(config[i].task_id)
		if data and data.award_status ~= 2 then
			tab = config[i]
			break
		end
	end
	local data = GameTaskModel.GetTaskDataByID(tab.task_id)
	self.layer_txt.text = tab.layer_txt
	self.icon_img.sprite = GetTexture(tab.icon_img)
	if data.award_status == 0 then
		self.task_txt.text = tab.task_txt
		self.Slider.value = data.now_process / data.need_process
		self.process_txt.text = StringHelper.ToCash(data.now_process) .. "/" .. StringHelper.ToCash(data.need_process)
	end
	self.award_img.sprite = GetTexture(tab.award_img)
	self.award_txt.text = tab.award_txt
	self.icon_img:SetNativeSize()
	--local rect = self.icon_img.gameObject:GetComponent("RectTransform")
	--rect.sizeDelta = Vector2.New(277.76, 230.72)
	self.icon_img.transform.localPosition = Vector3.New(-208, 0, 0)
	self.before.gameObject:SetActive(data.award_status == 0)
	self.after.gameObject:SetActive(data.award_status == 1)
end

function C:on_model_task_change_msg(data)
	if M.CheckIsInGuide() then
		for k,v in pairs(M.guide_tasks) do
			if data.id == v then
				self:RefreshUI_Guide()
			end
		end
	end
end

function C:on_fishing_ready_finish()
	self.isFishingReady=true
	self:ShowTipAffect()
	if not M.CheckIsInGuide() then
		M.QueryCurLayerTaskId()
	end
end

function C:ShowTipAffect()
	if not self.isFishingReady then
		return
	end
	local cur_layer = M.GetCurLayer()
	dump(os.time(), "展示特效！！！！！！")
	local offsetLevel = 5 - cur_layer % 5
	self.tip_txt.text = "再上" .. offsetLevel .. "层可领"

	if cur_layer < 30 then
		self.flqnum_txt.text = "10"
	else
		self.flqnum_txt.text = "50"
	end
	self:StopTimer()
	self.update_time =
		Timer.New(
		function()
			dump(os.time(), "时间到！@！！！！！！！！！！！！！！")
			if self.tipRoot then
				self.tipRoot.gameObject:SetActive(false)
			end
			self:StopTimer()
		end,
		3,
		-1
	)
	self.tipRoot.gameObject:SetActive(true)
	self.update_time:Start()
end

function C:StopTimer()
	if self.update_time then
		self.update_time:Stop()
		self.update_time=nil
	end
end
