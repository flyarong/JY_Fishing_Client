-- 创建时间:2021-01-29
-- Panel:SYS_3DBY_XYXTGPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

SYS_3DBY_XYXTGPanel = basefunc.class()
local C = SYS_3DBY_XYXTGPanel
C.name = "SYS_3DBY_XYXTGPanel"
local M = SYS_3DBY_XYXTGManager

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["xyxtg_all_data_had_got_msg"] = basefunc.handler(self,self.on_xyxtg_all_data_had_got_msg)
    self.lister["xyxtg_bet_data_had_got_msg"] = basefunc.handler(self,self.on_xyxtg_bet_data_had_got_msg)
    self.lister["xyxtg_bet_had_cancel_msg"] = basefunc.handler(self,self.on_xyxtg_bet_had_cancel_msg)
    self.lister["xyxtg_award_had_got_msg"] = basefunc.handler(self,self.on_xyxtg_award_had_got_msg)
    self.lister["client_system_variant_data_change_msg"] = basefunc.handler(self, self.on_client_system_variant_data_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopMoveTimer()
	self:CloseMiniGamePrefab()
	self:CloseBetMoneyPrefab()
	self:CloseBetTimesPrefab()
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
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.sv = self.transform:Find("Scroll View"):GetComponent("ScrollRect")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.OnHelpClick)
	EventTriggerListener.Get(self.xq_btn.gameObject).onClick = basefunc.handler(self, self.OnXQClick)
	EventTriggerListener.Get(self.start_btn.gameObject).onClick = basefunc.handler(self, self.OnStartClick)
	EventTriggerListener.Get(self.stop_btn.gameObject).onClick = basefunc.handler(self, self.OnStopClick)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	EventTriggerListener.Get(self.jb_btn.gameObject).onClick = basefunc.handler(self, self.OnJBClick)
	EventTriggerListener.Get(self.cs_btn.gameObject).onClick = basefunc.handler(self, self.OnCSClick)
	EventTriggerListener.Get(self.left_btn.gameObject).onClick = basefunc.handler(self, self.OnLeftClick)
	EventTriggerListener.Get(self.right_btn.gameObject).onClick = basefunc.handler(self, self.OnRightClick)
	EventTriggerListener.Get(self.jj_help_btn.gameObject).onClick = basefunc.handler(self, self.OnJJHelpClick)
	self.minigame_prefablist = M.GetMiniGamePrefabList()
	self.bet_times_limit = M.GetBetTimesLimit()
	M.QueryTGData()
end

function C:MyRefresh()
	self.tg_data = M.GetTGData()
	self.before_node.gameObject:SetActive((self.tg_data.remain_round == 0) and (tonumber(self.tg_data.award_money) == 0))
	self.after_node.gameObject:SetActive((self.tg_data.remain_round > 0) or ((self.tg_data.remain_round == 0) and (tonumber(self.tg_data.award_money) > 0)))
	if (self.tg_data.remain_round == 0) and (tonumber(self.tg_data.award_money) == 0) then
		self.xq_btn.transform.localPosition = Vector3.New(553,-95,0)
	else
		self.xq_btn.transform.localPosition = Vector3.New(373,-95,0)
	end
	self.stop_btn.gameObject:SetActive(self.tg_data.remain_round > 0)
	self.get_btn.gameObject:SetActive((self.tg_data.remain_round == 0) and (tonumber(self.tg_data.award_money) > 0))
	self.remain_txt.text = "剩余托管次数: " .. self.tg_data.remain_round
	self.game_name = self.game_name or self.tg_data.game_name or M.GetGameNameByGamePrefab(self.minigame_prefablist[1])
	self:RunChange()
	self:CerateMiniGamePrefab()
	self:RefreshHighLight()
	self:RefreshJBTXT()
	self:RefreshCSTXT()
	self:RefreshCostTXT()
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnHelpClick()
	local help_info = {"1.托管寻宝时，你可以继续在任何地方进行其他游戏，不会有任何影响哦","2.你可以设置各种条件，确保你的寻宝组合达到你想要最优化，好运也是靠实力的！","3.若在托管寻宝中离线，则重新上线后，会继续未完成的托管状态。"}
	local str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform, "IllustratePanel_New",
		function ()
			self:SetPartical(false)
		end,
		function ()
			self:SetPartical(true)
		end
	)
end

function C:OnXQClick()
	SYS_3DBY_XYXTGXQPanel.Create(
		function ()
			self:SetPartical(false)
		end,
		function ()
			self:SetPartical(true)
		end)
end

function C:OnStartClick()
	if not CommonMiniGameManager.CheckMiniGameIsOnHint(string.sub(M.GetGamePrefabByGameName(self.game_name),1,-7)) then return end
	if MainModel.UserInfo.jing_bi >= (self.jb * self.cs) then
		M.TGStart(self.game_name,self.jb,self.cs)
	else
		local pre = HintPanel.Create(2,"当前金币不足支付预付金币，不可进行托管",function ()
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end)
		pre:SetButtonText(nil,"充 值")
	end
end

function C:OnStopClick()
	HintPanel.Create(2,"是否结束自动寻宝，并获得当前赢金?",function ()
		M.TGStop()
	end)
end

function C:on_xyxtg_all_data_had_got_msg()
	self:MyRefresh()
end

function C:on_xyxtg_bet_data_had_got_msg()
	self:MyRefresh()
end

function C:on_xyxtg_bet_had_cancel_msg()
	self:MyRefresh()
end

function C:on_xyxtg_award_had_got_msg()
	self:MyRefresh()
end

function C:OnGetClick()
	M.GetAward()
end

function C:RunChange()
	local cur = self.got_txt.text or 0
	local target = self.tg_data.award_money
	GameComAnimTool.stop_number_change_anim(self.anim_tab)
	self.anim_tab = GameComAnimTool.play_number_change_anim(self.got_txt, tonumber(cur), tonumber(target), 3)
end

function C:CerateMiniGamePrefab()
	self:CloseMiniGamePrefab()
	for i=1,#self.minigame_prefablist do
		local pre = newObject(self.minigame_prefablist[i], self.mini_Content.transform)
		GameObject.Instantiate(self.highlight,pre.transform)
		GameObject.Instantiate(self.TX,pre.transform)
		pre.transform.localScale = Vector3.one * 0.8
		local pre_rect = pre.transform:GetComponent("RectTransform")
		pre_rect.sizeDelta = Vector2.New(370,370)
		local btn = pre.transform:Find("Button").gameObject:GetComponent("Button")
		local btn_click = function ()
			if self.tg_data.remain_round == 0 and tonumber(self.tg_data.award_money) == 0 then
				self.game_name = M.GetGameNameByGamePrefab(self.minigame_prefablist[i])
		        self:RefreshHighLight()
		        self:RefreshJBTXT()
		        self:RefreshCSTXT()
		        self:RefreshCostTXT()
			else
				LittleTips.Create("您当前正在托管寻宝中,不可切换")
			end
		end
		btn.onClick:AddListener(btn_click)
	    local HintLock_lv = pre.transform:Find("HintLock_lv").gameObject
	    CommonMiniGameManager.InitMiniGameEnterMask(string.sub(self.minigame_prefablist[i],1,-7),HintLock_lv,btn_click)
	    self.minigame_cell[#self.minigame_cell + 1] = pre
	end
end

function C:CloseMiniGamePrefab()
	if self.minigame_cell then
		for k,v in pairs(self.minigame_cell) do
			destroy(v.gameObject)
		end
	end
	self.minigame_cell = {}
end

function C:RefreshHighLight()
	self.selet_img.sprite = GetTexture(M.GetSeletImgByGameName(self.game_name))
	self.selet_img:SetNativeSize()
	for i=1,#self.minigame_cell do
		self.minigame_cell[i].transform:Find("@icon").gameObject:SetActive(self.game_name == M.GetGameNameByGamePrefab(self.minigame_prefablist[i]))
		self.minigame_cell[i].transform:Find("@icon_hui").gameObject:SetActive(self.game_name ~= M.GetGameNameByGamePrefab(self.minigame_prefablist[i]))
		self.minigame_cell[i].transform:Find("@TX(Clone)").gameObject:SetActive(self.game_name == M.GetGameNameByGamePrefab(self.minigame_prefablist[i]))
	end
	--[[for i=1,#self.minigame_cell do
		self.minigame_cell[i].transform:Find("@highlight(Clone)").gameObject:SetActive(self.game_name == M.GetGameNameByGamePrefab(self.minigame_prefablist[i]))
	end--]]
end

function C:CreateBetMoneyPrefab()
	self:CloseBetMoneyPrefab()
	local betmoney_tab = M.GetGameConfigByGameName(self.game_name)
	for i=1,#betmoney_tab do
		local pre = GameObject.Instantiate(self.jb_item,self.jb_Content.transform)
		pre.gameObject:SetActive(true)
		local jb_txt = pre.transform:Find("@jb").gameObject:GetComponent("Text")
		jb_txt.text = StringHelper.ToCash(betmoney_tab[i].bet_money)
		local btn = pre.transform:GetComponent("Button")
		btn.onClick:AddListener(function()
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=betmoney_tab[i].permission, is_on_hint = false}, "CheckCondition")
	        if a and b then
				self:RefreshJBTXT(i)
				self:RefreshCostTXT()
	        end
	        self.ScrollView_jb.gameObject:SetActive(false)
	    end)
	    self.bet_money_cell[#self.bet_money_cell + 1] = pre
	end
end

function C:CloseBetMoneyPrefab()
	if self.bet_money_cell then
		for k,v in pairs(self.bet_money_cell) do
			destroy(v.gameObject)
		end
	end
	self.bet_money_cell = {}
end

function C:CreateBetTimesPrefab()
	self:CloseBetTimesPrefab()
	for i=1,#self.bet_times_limit do
		local pre = GameObject.Instantiate(self.cs_item,self.cs_Content.transform)
		pre.gameObject:SetActive(true)
		local cs_txt = pre.transform:Find("@cs").gameObject:GetComponent("Text")
		cs_txt.text = self.bet_times_limit[i].bet_times .. "次"
		local btn = pre.transform:GetComponent("Button")
		btn.onClick:AddListener(function()
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=self.bet_times_limit[i].permission, is_on_hint = false}, "CheckCondition")
	        if a and b then
				self:RefreshCSTXT(i)
				self:RefreshCostTXT()
	        end
	        self.ScrollView_cs.gameObject:SetActive(false)
	    end)
	    self.bet_times_cell[#self.bet_times_cell + 1] = pre
	end
end

function C:CloseBetTimesPrefab()
	if self.bet_times_cell then
		for k,v in pairs(self.bet_times_cell) do
			destroy(v.gameObject)
		end
	end
	self.bet_times_cell = {}
end

function C:OnJBClick()
	if self.ScrollView_jb.gameObject.activeSelf then
		self.ScrollView_jb.gameObject:SetActive(false)
		self:CloseBetMoneyPrefab()
	else
		self.ScrollView_jb.gameObject:SetActive(true)
		self:CreateBetMoneyPrefab()
	end
end

function C:OnCSClick()
	if self.ScrollView_cs.gameObject.activeSelf then
		self.ScrollView_cs.gameObject:SetActive(false)
		self:CloseBetTimesPrefab()
	else
		self.ScrollView_cs.gameObject:SetActive(true)
		self:CreateBetTimesPrefab()
	end
end

function C:RefreshCostTXT()
	self.cost_txt.text = "<size=28><color=#A0FEFF>将预付 </color></size><size=32><color=#FFAE00>" .. StringHelper.ToCash(self.jb * self.cs) .. "金币</color></size> <size=28><color=#A0FEFF>用于托管寻宝</color></size>"
end

function C:RefreshJBTXT(index)
	local betmoney_tab = M.GetGameConfigByGameName(self.game_name)
	self.jb = betmoney_tab[index or M.GetTJBetMoney(betmoney_tab)].bet_money
	self.jb_txt.text = StringHelper.ToCash(self.jb)
end

function C:RefreshCSTXT(index)
	self.cs = self.bet_times_limit[index or 1].bet_times
	self.cs_txt.text = self.bet_times_limit[index or 1].bet_times .. "次"
end

function C:OnLeftClick()
	self:MoveTween(true,0)
end

function C:OnRightClick()
	self:MoveTween(true,1)
end

function C:MoveTween(b,target_num)
	self:StopMoveTimer()
	if b then
		self.movetimer = Timer.New(function ()
			if self.sv.horizontalNormalizedPosition == target_num then
				self:StopMoveTimer()
			else
				self.sv.horizontalNormalizedPosition = Mathf.Lerp(self.sv.horizontalNormalizedPosition,target_num,0.1)
			end
		end,0.0005,30,false)
		self.movetimer:Start()
	end
end

function C:StopMoveTimer()
	if self.movetimer then
		self.movetimer:Stop()
		self.movetimer = nil
	end
end

--控制特效的显示隐藏,因为层级问题
function C:SetPartical(b)
	self.partical.gameObject:SetActive(b)
	if not b then
		for i=1,#self.minigame_cell do
			self.minigame_cell[i].transform:Find("@TX(Clone)").gameObject:SetActive(false)
		end
	else
		for i=1,#self.minigame_cell do
			self.minigame_cell[i].transform:Find("@TX(Clone)").gameObject:SetActive(self.game_name == M.GetGameNameByGamePrefab(self.minigame_prefablist[i]))
		end
	end
end

function C:on_client_system_variant_data_change_msg()
	self:MyRefresh()
end

function C:OnJJHelpClick()
	local pre = HintPanel.Create(2,"精简模式：不显示游戏过程，直接展示结果。想获得更好的游戏体验，请前往小游戏体验！",function ()
		GameManager.GuideExitScene({gotoui = "game_MiniGame"},function ()
			self:MyExit()
		end)
	end)
	pre:SetButtonText(nil, "前 往")
end