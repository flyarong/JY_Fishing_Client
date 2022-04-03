-- 创建时间:2020-03-05
-- Panel:Fishing3DActCaijinEnterPrefab
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

Fishing3DActCaijinEnterPrefab = basefunc.class()
local C = Fishing3DActCaijinEnterPrefab
C.name = "Fishing3DActCaijinEnterPrefab"
local M = BY3DActCaijinManager

local tips_speed = 200
local wait_time = 2

local TipsState = 
{
	Close = 0, -- 关闭 
	Enter = 1, -- 进入
	Wait = 2, -- 等待
	Exit = 3, -- 退出
}

local img_type = {"pt","qt","by","hj","bj","zz",}

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
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["model_by3d_act_caijin_change"] = basefunc.handler(self, self.on_caijin_change)
	self.lister["model_by3d_act_caijin_all_info"] = basefunc.handler(self, self.on_all_info)
	self.lister["model_by3d_act_caijin_lottery"] = basefunc.handler(self, self.on_caijin_lottery)
	self.lister["level_info_got"] = basefunc.handler(self,self.on_level_info_got)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:KillDotween()
	self:StopTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:OnExitScene()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self) 
	self.transform.localPosition = Vector3.zero

	self.tipsState = TipsState.Close
	self.curWaitTime = 0


	--self.updateTimer:Start()
	self:setTipsPanelPosX(0)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	--M.QueryCaijinAllInfo()
end

function C:InitUI()
	self.prog_default_rect = self.prog_bar.rect

	self.enter_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self.lock_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LittleTips.Create("等级3开启，在3D捕鱼中开炮可提升等级！")
	end)
	
	M.QueryCaijinAllInfo()
end

function C:on_all_info()
	dump( "<color=red>on_caijin_all_info</color>")
	
	local data = M.GetCaijinData()

	if data.result ~= 0 then 
		Event.Brocast("ui_button_state_change_msg")
		return
	end
	if data.game_id == 0 then
		Event.Brocast("ui_button_state_change_msg")
		return
	end
	self:MyRefresh()
end


function C:on_caijin_change()
	local a,b = GameButtonManager.RunFun({gotoui="sys_by_level"}, "GetLevel")
    if a and b >= 3 then
		self:refreshLotteryButton()
		self:refreshLotteryTips()
	end
end

function C:on_caijin_lottery()

	local data = M.GetCaijinData()

	self:MyRefresh()
end

function C:refreshLotteryButton()
	local type = self:findCurentType()
	self:setButtonType(type)
	--self.enter_btn.gameObject:SetActive(type > 0)
end

function C:refreshLotteryTips()
	self:addLotteryTip()
	self:refreshLotteryTipsInfo()
end

function C:addLotteryTip()
	if self.tipsState == TipsState.Close then
		self:Enter_tween()
		self.tips_panel.gameObject:SetActive(true)
		--self.tipsState = TipsState.Enter
	elseif self.tipsState == TipsState.Enter then
	elseif self.tipsState == TipsState.Wait then
		self.curWaitTime = wait_time
	elseif self.tipsState == TipsState.Exit then
		self:Enter_tween()
		self.tips_panel.gameObject:SetActive(true)
		--self.tipsState = TipsState.Enter
	end
end

function C:refreshLotteryTipsInfo()
	local data = M.GetCaijinData()
	self.gold_change_txt.text = "+"..StringHelper.ToCash(data.score_change)

	local type = self:findCurentType()
	local next = type + 1
	if next > #M.caijin_config.caijin_type_config[data.game_id] then
		self:SetProgress(1, 1)
	else
		self:SetProgress(data.score, M.caijin_config.caijin_type_config[data.game_id][next].score_limit)
	end

end

function C:SetProgress(cur, total)
	percent = cur / total

	if percent < 0 then
		percent = 0
	elseif percent > 1 then
		percent = 1
	end

	if percent > 0 and percent < 0.08 then
		percent = 0.08
	end 

	self.prog_bar.sizeDelta = {x = self.prog_default_rect.width * percent, y = self.prog_default_rect.height}
end

function C:update()
	--[[local cur_tick = os.clock()
	local dt = cur_tick - self.last_tick

	if self.tipsState == TipsState.Close then
		self.tips_panel.gameObject:SetActive(true)
		self:setTipsPanelPosX(0)
	elseif self.tipsState == TipsState.Enter then
		self.tips_panel.gameObject:SetActive(true)
		self:setTipsPanelPosX(self.tips_panel.gameObject.transform.localPosition.x + dt * tips_speed)
		if self.tips_panel.gameObject.transform.localPosition.x >= self.tips_panel.gameObject.transform.rect.width then
			self:setTipsPanelPosX(self.tips_panel.gameObject.transform.rect.width)
			self.tipsState = TipsState.Wait
			self.curWaitTime = wait_time
		end
	elseif self.tipsState == TipsState.Wait then
		self.tips_panel.gameObject:SetActive(true)
		self.curWaitTime = self.curWaitTime - dt
		if self.curWaitTime <= 0 then
			self.curWaitTime = 0
			self.tipsState = TipsState.Exit
		end
	elseif self.tipsState == TipsState.Exit then
		self.tips_panel.gameObject:SetActive(true)
		self:setTipsPanelPosX(self.tips_panel.gameObject.transform.localPosition.x - dt * tips_speed)
		if self.tips_panel.gameObject.transform.localPosition.x <= 0 then
			self:setTipsPanelPosX(0)
			self.tipsState = TipsState.Close
		end
	else
		assert(0)
	end--]]
	if self.tipsState == TipsState.Wait then
		--dump(self.curWaitTime,"<color=yellow>++++++++++curWaitTime+++++++++</color>")
		self.curWaitTime = self.curWaitTime - 0.5
		if self.curWaitTime <= 0 then
			self.curWaitTime = 0
			self.tipsState = TipsState.Exit
			self:StopTimer()
			self:Exit_tween()
		end
	end
	--self.last_tick = cur_tick
end

function C:setTipsPanelPosX(x)
	local v = Vector3.New(x, self.tips_panel.gameObject.transform.localPosition.y, self.tips_panel.gameObject.transform.localPosition.z)
	self.tips_panel.gameObject.transform.localPosition = v
end

function C:setButtonType(type)
	if type > 0 then
		self.btn_type_img.gameObject:SetActive(true)
		self.btn_type_img.sprite = GetTexture("jjcjy_imgf_"..img_type[type])
	else
		self.btn_type_img.gameObject:SetActive(false)
	end
end

function C:OnEnterClick()
	Fishing3DActCaijinPanel.Create()
end

function C:MyRefresh()
	self:IsUnLock()
	self:refreshLotteryButton()
	self:refreshLotteryTipsInfo()
	self:update()
end

function C:findCurentType()
	local d = M.GetCaijinData()
	if M.caijin_config.caijin_type_config[d.game_id] then
		local total = #M.caijin_config.caijin_type_config[d.game_id]
		for i = total, 1, -1 do
			if M.caijin_config.caijin_type_config[d.game_id] and M.caijin_config.caijin_type_config[d.game_id][i] and M.caijin_config.caijin_type_config[d.game_id][i].score_limit and d.score >= M.caijin_config.caijin_type_config[d.game_id][i].score_limit then
				return M.caijin_config.caijin_type_config[d.game_id][i].type
			end
	    end
	end

    return 0
end


function C:IsUnLock()
	local a,b = GameButtonManager.RunFun({gotoui="sys_by_level"}, "GetLevel")
    if a and b >= 3 then
		if IsEquals(self.lock_btn) then
			self.lock_btn.gameObject:SetActive(false)
		end
		if IsEquals(self.enter_btn) then
			self.enter_btn.gameObject:SetActive(true)
		end
	end
end


function C:on_level_info_got()
	self:IsUnLock()
end

function C:KillDotween()
	local ok = xpcall(function ()
		if self.seq1 then
			self.seq1:Kill()
			self.seq1 = nil
		end	
	end, function (err)
		
	end)
end

--进入动画
function C:Enter_tween()
	self:KillDotween()
	self.seq1 = DoTweenSequence.Create()
	self.seq1:Append(self.tips_panel.transform:DOLocalMoveX(300,(300 - self.tips_panel.transform.localPosition.x)/300))
	self.seq1:AppendCallback(function ()
		self.curWaitTime = wait_time
		self.tipsState = TipsState.Wait
		self:StopTimer()
		self.updateTimer = Timer.New(basefunc.handler(self, self.update), 0.5, -1, nil, true)
		self.updateTimer:Start()
	end)
end

--退出动画
function C:Exit_tween()
	self:KillDotween()
	self.seq1 = DoTweenSequence.Create()
	self.seq1:Append(self.tips_panel.transform:DOLocalMoveX(0,1))
	self.seq1:AppendCallback(function ()
		self.tipsState = TipsState.Close
	end)
end

function C:StopTimer()
	if self.updateTimer then
		self.updateTimer:Stop()
		self.updateTimer = nil
	end
end