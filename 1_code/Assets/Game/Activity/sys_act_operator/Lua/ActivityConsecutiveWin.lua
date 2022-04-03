-- 创建时间:2019-01-03
local basefunc = require "Game/Common/basefunc"

ActivityConsecutiveWin = basefunc.class()

ActivityConsecutiveWin.name = "ActivityConsecutiveWin"
ActivityConsecutiveWin.data = {}

local m_data = ActivityConsecutiveWin.data
local instance

ConsecutiveWinState = {
	ShowChallenge = 1, -- x连胜挑战中
	ShowBubble = 2,-- 入口
	ShowResult = 3,-- 结算
	None = 4,
}

function ActivityConsecutiveWin.Create()
	if not instance then
		instance = ActivityConsecutiveWin.New()
	end
	return instance
end

function ActivityConsecutiveWin:InitEventListener()
	self.eventList = {}
	self.eventList["activity_refresh_data_msg"] = basefunc.handler(self, self.RefreshData)
	self.eventList["activity_fp_msg"] = basefunc.handler(self, self.OnGameStart)
	self.eventList["logic_activity_fg_gameover_msg"] = basefunc.handler(self, self.OnGameOver)
	self.eventList["activity_close_clearing_msg"] = basefunc.handler(self, self.OnCloseClearing)
	self.eventList["fg_get_activity_award_response"] = basefunc.handler(self, self.OnGetAwardResponse)
end

function ActivityConsecutiveWin:RegisterListener()
	if self.eventList then
		for n, f in pairs(self.eventList) do
			Event.AddListener(n, f)
		end
	end
end

function ActivityConsecutiveWin:RemoveListener()
	if self.eventList then
		for n, f in pairs(self.eventList) do
			Event.RemoveListener(n, f)
		end
	end
end
--启动事件--
function ActivityConsecutiveWin:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	self.gameObject = newObject("OperatorActivity_ConsecutiveWin", parent)
	self.transform = self.gameObject.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self.awardTemplate = self.transform:Find("Award").gameObject
	self.anchor_1 = self.transform:Find("Panel/common/anchor_1")
	self.anchor_2 = self.transform:Find("Panel/common/anchor_2")

	self.entrance = self.transform:Find("entrance")

	self.childs = {}
	self.childs["scrollMsg"] = self.transform:Find("scroll_msg")
	self.scrollBar = self.childs.scrollMsg:Find("bar")

	self.panel = self.transform:Find("Panel")
	self.childs["common"] = self.panel:Find("common")
	self.childs["curWinState"] = self.panel:Find("curWinState")
	self.childs["mileStone"] = self.panel:Find("mileStone")
	self.childs["completed"] = self.panel:Find("completed")

	self.childs["background"] = self.background_img.transform
	self.childs["share"] = self.transform:Find("share")
	
	EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseBtnClicked)
	EventTriggerListener.Get(self.take_btn.gameObject).onClick = basefunc.handler(self, self.OnTakeBtnClicked)
	EventTriggerListener.Get(self.next_btn.gameObject).onClick = basefunc.handler(self, self.OnNextBtnClicked)
	EventTriggerListener.Get(self.takeFinal_btn.gameObject).onClick = basefunc.handler(self, self.OnTakeBtnClicked)
	EventTriggerListener.Get(self.share_btn.gameObject).onClick = basefunc.handler(self, self.OnShareBtnClicked)
	EventTriggerListener.Get(self.gate_btn.gameObject).onClick = basefunc.handler(self, self.OnGateBtnClicked)

	self:HideAndShow()
	self:InitEventListener()
	self:RegisterListener()

	self:Init( OperatorActivityLogic.GetData() )

	if not ActivityConsecutiveWin.CanBeAwarded() or not self.config then
		Event.Brocast("close_operator_activity", "ls")
	else
		self:MyRefresh()
	end
	Event.Brocast("global_sysqx_uichange_msg", {key="ls", panelSelf=self})
end

function ActivityConsecutiveWin:Init(data)
	dump(data, "<color=yellow>ActivityConsecutiveWin:Init</color>")
	self:ResetData()

	if data then
		self.activity_data = OperatorActivityModel.GetActivity(data.game_id, ActivityType.Consecutive_Win)
		self:InitData(data.game_id)
		self:RefreshData(data)

		if data.model_status then
			if data.model_status == "gaming" and data.status and data.status == "fp" then
				self:OnGameStart()
			elseif data.model_status == "gameover" then
				--self:OnGameOver()
			end
		end
	end
end

function ActivityConsecutiveWin:ResetData()
	print("<color=yellow>ooooooWinoooooo  ResetData</color>")
	m_data.curState = ConsecutiveWinState.None
	m_data.round = 0 -- 轮次
	m_data.max_round = 0 -- 最大轮次
	m_data.cur_process = 0 -- 当前进度
	m_data.max_process = 0 -- 最大进度
	m_data.lastWinCount = 0 -- 上次进度
	m_data.min_process = 0
	m_data.hide_cb = nil
	self.config = nil
	self.awardCfg = nil
end

function ActivityConsecutiveWin:InitData(gameId)
	if gameId and not self.config then
		self.game_id = gameId
		self.config = OperatorActivityModel.GetActivity(gameId, ActivityType.Consecutive_Win)
		dump(self.config, "<color=yellow>ooooooWinoooooo  InitData</color>")

		if self.config then
			local param = self.config.activity_parm
			self.winCfg = {}
			for i = 1, #param do
				self.winCfg[i] = param[i].ls_num
			end
			m_data.min_process = self.winCfg[1]
			m_data.max_process = self.winCfg[#self.winCfg]

			self.awardCfg = {}
			for i=1, #self.config.activity_award do
				self.awardCfg[i] = self.config.activity_award[i][1]
			end
		end
	end
end

function ActivityConsecutiveWin:MyRefresh()
	dump(m_data, "<color=yellow>ooooooWinoooooo  MyRefresh</color>")
	if m_data.round < m_data.max_round then
		self:ShowBubble()
	else
		self:HideDescHint()
		self.entrance.gameObject:SetActive(false)
	end
end
-- 连胜挑战中 提示UI(有动画的)
function ActivityConsecutiveWin:ShowLSHint()
	dump(m_data, "<color=yellow>ooooooWinoooooo  ShowLSHint</color>")
	self:ShowChallenge()
end
-- 连胜的详情界面
function ActivityConsecutiveWin:ShowDescHint()
	dump(m_data, "<color=yellow>ooooooWinoooooo  ShowDescHint</color>")
	m_data.curState = ConsecutiveWinState.ShowResult
	self.panel.gameObject:SetActive(true)
	if m_data.cur_process < m_data.min_process then
		self:ShowKeepMoving()
	elseif m_data.cur_process < m_data.max_process then
		self:ShowMileStone()
	else
		self:ShowChallengeComplete()
	end

	self:SetAwardedTimes()
end
function ActivityConsecutiveWin:HideDescHint()
	dump(m_data, "<color=yellow>ooooooWinoooooo  HideDescHint</color>")
	m_data.curState = ConsecutiveWinState.ShowBubble
	ActivityConsecutiveWin.CallBackOnHide()
	self.panel.gameObject:SetActive(false)
end

function ActivityConsecutiveWin:RefreshData(data)
	dump(data, "<color=yellow>ooooooWinoooooo  RefreshData</color>")
	if data and data.activity_data then
		m_data.lastWinCount = m_data.cur_process
		for _, item in ipairs(data.activity_data) do
			m_data[item.key] = item.value
		end
		-- 最后领完后，进度重置为0
		m_data.cur_process = (m_data.round < m_data.max_round and m_data.cur_process or 0)
		self:MyRefresh()
	end
end

function ActivityConsecutiveWin:SetAwardedTimes()
	self.gotAward_txt.text = "本场次今日已领奖：" .. m_data.round .. "/" .. m_data.max_round
	if (m_data.cur_process - m_data.min_process + 1) < #self.awardCfg then
		self.gotAward_txt.transform.localPosition = self.anchor_1.localPosition
	else
		self.gotAward_txt.transform.localPosition = self.anchor_2.localPosition
	end

	self.share_btn.gameObject:SetActive(m_data.cur_process >= m_data.min_process)
end

function ActivityConsecutiveWin:ShowBubble()
	local nextCount = m_data.cur_process
	for i, v in ipairs(self.winCfg) do
		if v > nextCount then
			nextCount = v
			break
		end
	end

	self.progress_txt.text = m_data.cur_process .. "/" .. nextCount
	if OperatorActivityModel.IsActivated(self.game_id, ActivityType.Consecutive_Win) then
		self.bubble_txt.text = "挑战连胜，赢大奖！"
		self.gate_btn.transform:Find("tip").gameObject:SetActive(m_data.cur_process > m_data.lastWinCount)
	else
		self.bubble_txt.text = "连胜活动已结束。"
		self.gate_btn.transform:Find("tip").gameObject:SetActive(true)
	end
	self.entrance.gameObject:SetActive(true)
end

function ActivityConsecutiveWin:ShowChallenge()
	if m_data.cur_process < m_data.max_process and m_data.cur_process >= m_data.min_process then
		self.childs["scrollMsg"].gameObject:SetActive(true)

		self.winCount_img.sprite = GetTexture("ls_imgf_" .. (m_data.cur_process + 1))
		self.winCount_img:SetNativeSize()
		self.scrollOffX = (self.scrollBar:GetComponent("RectTransform").rect.width + Screen.width)/2
		self.scrollBar.localPosition = Vector3.New(self.scrollOffX, 0, 0)
		self.acc = 2 * self.scrollOffX/0.25
		self.moveSpeed = -self.acc * 0.5
		self.taskMove = Timer.New(basefunc.handler(self, self.TipMoveIn), 0.02, -1, false)
		self.taskMove:Start()
	end
end

function ActivityConsecutiveWin:ShowKeepMoving()
	if self.awardCfg and #self.awardCfg > 0 then
		self.tip_txt.text = "当前连胜：" .. m_data.cur_process
		self.condition_txt.text = m_data.min_process .. "连胜可领"
		self.ws_tip_txt.text = "" --"达到".. m_data.min_process .. "连胜后，每次选择继续挑战并取得连胜，都可获得更高奖励。\n不同场次的连胜分开记录，同一场次每日最多进行" .. m_data.max_round .. "次挑战。"
		self:GenAward(self.awardCfg[1], self.childs["curWinState"]:Find("awardNode"), nil, true)
		self.activityEnd_txt.gameObject:SetActive(not OperatorActivityModel.IsActivated(self.game_id, ActivityType.Consecutive_Win))
		self:HideAndShow({"common", "curWinState", "background"})
	end
end

function ActivityConsecutiveWin:ShowMileStone()
	if self.awardCfg and (m_data.cur_process - m_data.min_process + 1) < #self.awardCfg then
		local curAward = self.awardCfg[m_data.cur_process - m_data.min_process + 1]
		local nextAward = self.awardCfg[m_data.cur_process - m_data.min_process + 2]
		local data = AwardManager.GetAssetsList({curAward, nextAward})
		local t = ActivityConsecutiveWin.FormatNum(nextAward.value/curAward.value)
		self.tip_txt.text = ""
		self.subTip_txt.text = "当前" .. m_data.cur_process .. "连胜"
		self.cur_award_txt.text = data[1].desc
		self.ms_tip_txt.text = "" --"选择连续挑战后，在下一场游戏中胜利可提升连胜进度，失败则失去连胜进度。\n不同场次的连胜分开记录，同一场次每日最多领取" .. m_data.max_round .. "次奖励。"
		--self:GenAward(curAward, self.childs["mileStone"]:Find("awardNode1"), nil, false)
		self:GenAward(nextAward, self.childs["mileStone"]:Find("awardNode2"), t, true)
		self:HideAndShow({"common", "mileStone", "background"})
	end
end

function ActivityConsecutiveWin:ShowChallengeComplete()
	if self.awardCfg and #self.awardCfg > 0 then
		self.tip_txt.text = "恭喜你！完成" .. m_data.cur_process .. "连胜挑战！"
		self:GenAward(self.awardCfg[#self.awardCfg], self.childs["completed"]:Find("awardNode"), nil, true)
		self:HideAndShow({"common", "completed", "background"})
	end
end

function ActivityConsecutiveWin:ShowShare()
	if self.awardCfg and #self.awardCfg > 0 then
		local award = self.awardCfg[math.min(m_data.cur_process - m_data.min_process + 1, #self.awardCfg)]
		local data = AwardManager.GetAssetsList({award})[1]
		local desc = data.desc
		if data.type == "jing_bi" then
			desc = data.value .. "金币"
		else
			desc = StringHelper.ToCash(data.value)
		end
		LSSharePop.Create(desc, m_data.cur_process)
	end
end

function ActivityConsecutiveWin:HideAll()
	for varName, trans in pairs(self.childs) do
		trans.gameObject:SetActive(false)
	end
end
function ActivityConsecutiveWin:HideAndShow(cNames)
	-- 隐藏所有
	self:HideAll()
	-- 显示列表中的UI
	self:ShowChilds(cNames)
end
function ActivityConsecutiveWin:ShowChilds(cNames)
	if cNames then
		for i = 1, #cNames do
			if self.childs[ cNames[i] ] then
				self.childs[ cNames[i] ].gameObject:SetActive(true)
			end
		end
	end
end

function ActivityConsecutiveWin:GenAward(config, parent, times, bigIcon)
	local obj = GameObject.Instantiate(self.awardTemplate, parent)
	local data = AwardManager.GetAssetsList({config})[1]
	local mulIcon = obj.transform:Find("multiply")
	obj:SetActive(true)
	obj.transform.localPosition = Vector3.zero

	if not times then
		mulIcon.gameObject:SetActive(false)
	else
		mulIcon.gameObject:SetActive(true)
		mulIcon:Find("times"):GetComponent("Text").text = times .. "倍"
	end

	local icon = obj.transform:Find("icon")
	local img = icon:GetComponent("Image")
	local orgH = icon:GetComponent("RectTransform").rect.height
	local iconImg = "ls_icon_"
	local desc = data.desc
	if data.type == "jing_bi" then
		iconImg = iconImg .. (bigIcon and "jb2" or "jb1")
		desc = data.value .. "金币"
	else
		iconImg = iconImg .. (bigIcon and "hb3" or "hb2")
		desc = StringHelper.ToCash(data.value)
	end
	obj.transform:Find("desc_bg/desc"):GetComponent("Text").text = desc
	img.sprite = GetTexture(iconImg) --GetTexture(data.image)
	img:SetNativeSize()
	
	local newH = icon:GetComponent("RectTransform").rect.height
	local scale = orgH/newH
	icon.localScale = Vector3.New(scale, scale, 1)

	local isActivated = OperatorActivityModel.IsActivated(self.game_id, self.config.activity_id)
	self.next_btn.gameObject:SetActive(isActivated)
	self.disable_btn.gameObject:SetActive(not isActivated)
	self.disable_btn.enabled = false

	if m_data.cur_process >= m_data.min_process and m_data.cur_process < m_data.max_process then
		obj.transform:Find("bar").gameObject:SetActive(true)
		obj.transform:Find("bar/ls_award_txt"):GetComponent("Text").text = (m_data.cur_process + 1) .. "连胜奖励"
	else
		obj.transform:Find("bar").gameObject:SetActive(false)
	end
end

function ActivityConsecutiveWin:TipMoveIn()
	self:TipMove()
	if self.moveSpeed > 0 then
		self.scrollBar.localPosition = Vector3.New(0, 0, 0)
		self.taskMove:Stop()
		self.taskMove = Timer.New(function()
			self.taskMove = nil

			if self.scrollBar then
				self.moveSpeed = 0
				self.acc = -2 * self.scrollOffX/0.25
				self.taskMove = Timer.New(basefunc.handler(self, self.TipMoveOut), 0.02, -1, false)
				self.taskMove:Start()
			end
		end, 2, 1, false)
		self.taskMove:Start()
	end
end

function ActivityConsecutiveWin:TipMoveOut()
	self:TipMove()
	if self.scrollBar.localPosition.x <= -self.scrollOffX then
		self.taskMove:Stop()
		self.taskMove = nil
		self.childs["scrollMsg"].gameObject:SetActive(false)
	end
end

function ActivityConsecutiveWin:TipMove()
	self.scrollBar.localPosition = self.scrollBar.localPosition + Vector3.New(self.moveSpeed * 0.02 + self.acc * 0.0002, 0, 0)
	self.moveSpeed = self.moveSpeed + self.acc * 0.02
end

-------------------------------------------------------------------------------------------
function ActivityConsecutiveWin:OnGameStart()
	dump(m_data, "<color=yellow>ooooooWinoooooo  OnGameStart</color>")
	self:ShowLSHint()
end

function ActivityConsecutiveWin:OnGameOver()
	dump(m_data, "<color=yellow>ooooooWinoooooo  OnGameOver</color>")
	if m_data.cur_process >= m_data.min_process then
		self:ShowDescHint()
	end
	self:MyRefresh()
end

function ActivityConsecutiveWin:SendGetAward()
	self.rewardId = m_data.cur_process - m_data.min_process + 1
	Network.SendRequest("fg_get_activity_award", nil, "发送请求")
end

function ActivityConsecutiveWin:OnGetAwardResponse(_, data)
	dump(data, "<color=yellow>ooooooWinoooooo  OnGetAwardResponse</color>")
	self:HideDescHint()
	self:MyRefresh()

	if data and data.result == 0 then
		if self.awardCfg[self.rewardId] then
			Event.Brocast("AssetGet",{data = {{asset_type=self.awardCfg[self.rewardId].asset_type, value=self.awardCfg[self.rewardId].value}}, callback = ActivityConsecutiveWin.CallBackOnHide})
		end
	else
		HintPanel.Create(1, "领奖失败!活动结束后奖励将通过邮件发送。", ActivityConsecutiveWin.CallBackOnHide, ActivityConsecutiveWin.CallBackOnHide)
	end
end

function ActivityConsecutiveWin:OnCloseClearing()
	if OperatorActivityModel.IsActivated(self.game_id, ActivityType.Consecutive_Win) then
		self:MyRefresh()
	else
		Event.Brocast("close_operator_activity", "ls")
	end
end

function ActivityConsecutiveWin.SetHideCallBack(cb)
	m_data.hide_cb = cb
end

function ActivityConsecutiveWin.CallBackOnHide()
	if m_data.hide_cb then
		m_data.hide_cb()
		m_data.hide_cb = nil
	end
end

-- 活动是否没有做完
function ActivityConsecutiveWin.CanBeAwarded()
	return (m_data.round and m_data.max_round and m_data.round < m_data.max_round)
end

--------------------------------------- events -----------------------------------------------
function ActivityConsecutiveWin:OnGateBtnClicked()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:ShowDescHint()
end

function ActivityConsecutiveWin:OnCloseBtnClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:HideDescHint()
end

function ActivityConsecutiveWin:OnTakeBtnClicked()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if m_data.cur_process < m_data.max_process then
		local panel = HintPanel.Create(4, "领取奖励将放弃继续挑战的机会！", function()
			self:SendGetAward()
		end)
		panel:SetBtnTitle("确认领取", "继续挑战")
	else
		self:SendGetAward()
	end
end

function ActivityConsecutiveWin:OnNextBtnClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:HideDescHint()
end

function ActivityConsecutiveWin:OnShareBtnClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:ShowShare()
end

function ActivityConsecutiveWin:MyClose()
	print("<color=yellow>ooooooWinoooooo  MyClose</color>")
	if not instance then
		print(debug.traceback())
		return
	end
	self.childs = nil
	if self.taskMove then
		self.taskMove:Stop()
		self.taskMove = nil
	end

	self:RemoveListener()
	self:ResetData()

	instance = nil
	destroy(self.gameObject)
end

function ActivityConsecutiveWin:IsBigUI()
	return m_data.curState == ConsecutiveWinState.ShowResult
end

function ActivityConsecutiveWin.FormatNum(num)
	local intNum = math.floor(num)
	if (num - intNum) > 0 then
		intNum = math.floor(num * 10)
		if ((num * 10) - intNum) > 0 then
			return string.format("%.2f", num)
		else
			return string.format("%.1f", num)
		end
	else
		return intNum
	end
end
