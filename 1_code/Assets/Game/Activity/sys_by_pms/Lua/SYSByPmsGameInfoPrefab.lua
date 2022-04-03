-- 创建时间:2020-04-27
-- Panel:SYSByPmsGameInfoPrefab
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

SYSByPmsGameInfoPrefab = basefunc.class()
local C = SYSByPmsGameInfoPrefab
C.name = "SYSByPmsGameInfoPrefab"
local M = SYSByPmsManager

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
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    
    self.lister["model_sys_by_pms_game_data"] = basefunc.handler(self, self.model_sys_by_pms_game_data)

    self.lister["model_sys_by_pms_rank_change"] = basefunc.handler(self, self.model_sys_by_pms_rank_change)
    self.lister["model_sys_by_pms_score_change"] = basefunc.handler(self, self.model_sys_by_pms_score_change)
    self.lister["model_sys_by_pms_bullet_change"] = basefunc.handler(self, self.model_sys_by_pms_bullet_change)
    self.lister["SYSByPms_on_backgroundReturn_msg"] = basefunc.handler(self, self.on_backgroundReturn)
    self.lister["SYSByPms_on_background_msg"] = basefunc.handler(self, self.on_background_msg)
    -- self.lister["SYSByPms_ReConnecte"] = basefunc.handler(self,self.on_SYSByPms_ReConnecte)
    -- self.lister["model_sys_by_pms_game_data_ReConnecte"] = basefunc.handler(self,self.on_model_sys_by_pms_game_data_ReConnecte)
    self.lister["BYPMS_on_query_bullet_rank_part"] = basefunc.handler(self,self.on_RefreshCurRank)

end

function C:RemoveListener()
	--[[print(debug.traceback())
	dump("<color=yellow>|||||||||||||||||||||||||||||||</color>")--]]
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	M.UpdataBulletChange(false)
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	self:StopTime()
	self:RemoveListener()
	destroy(self.gameObject)
end
function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)
	--[[print(debug.traceback())
	dump("<color=yellow>|||||||||||||||-------------||||||||||||||||</color>")--]]
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
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.on_EnterClick)
	self.dot_lv = M.GetCurDotLv()
	self.award_config = SYSByPmsManager.GetPMSAwardByID(SYSByPmsManager.GetSignupData())--获取奖励config
	self.slider = self.slider:GetComponent("Slider")
    self:UpdataTimer(true)
	self:UpdateTimeUI(true)
	if M.GetCurRank() == -1 then
		self.rank_txt.text = "未上榜"
	else
		self.rank_txt.text = M.GetCurRank()
	end


	M.UpdataBulletChange(true)
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshScore()
	self:RefreshDot()
	self:RefreshRank()
end
function C:RefreshScore()
	self.score_txt.text = "" .. M.GetCurScore()
end
function C:RefreshRank()
	if M.GetCurRank() == -1 then
		self.rank_txt.text = "未上榜"
	else
		self.rank_txt.text = M.GetCurRank()
	end
end
function C:RefreshDot()
	if self.dot_lv then
		self.icon_img.gameObject:SetActive(true)
		self.icon_img.sprite = GetTexture(self.award_config[self.dot_lv].icon)	
	else
		self.icon_img.gameObject:SetActive(false)
	end
end
function C:model_sys_by_pms_game_data()
	self:model_sys_by_pms_rank_change()
	self:model_sys_by_pms_score_change()
	self:model_sys_by_pms_bullet_change()


end
function C:model_sys_by_pms_rank_change()
	self:RefreshRank()
end

function C:model_sys_by_pms_score_change()
	self:RefreshScore()
	local lv = M.GetCurDotLv()
	if (self.dot_lv and lv ~= self.dot_lv) or (not self.dot_lv and lv) then
		self.dot_lv = lv
		SYSByPmsGameJLTSPanel.Create(self.icon_img.transform)
		self.seq = DoTweenSequence.Create()
		self.seq:AppendInterval(2.8)
		self.seq:AppendCallback(function ()
			self:RefreshDot()
		end)
	end
end

function C:model_sys_by_pms_bullet_change()
	local cur_bullet = M.GetCurBullet()
	local max_bullet = M.GetMaxBullet()
	self.slider_txt.text = cur_bullet .. "/" .. max_bullet

	local process = cur_bullet / max_bullet
	self.slider.value = process
end

-- 倒计时
function C:StopTime()
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
end
function C:GetCall(t)
	local tt = t
	local cur = 0
	return function (st)
		cur = cur + st
		if cur >= tt then
			cur = cur - tt
			return true
		end
		return false
	end
end
function C:Update()
	for k,v in pairs(self.time_call_map) do
		if v.time_call(1) then
			v.run_call()
		end
	end
end

function C:UpdataTimer(b)
	self:StopTime()
	self.cur_time = M.GetCurTime()
	if b then
		self.update_time = Timer.New(function ()
	    	self:UpdateTimeUI()
	    end, 1, -1, nil, true)
	    self.update_time:Start()
	end
end

function C:UpdateTimeUI(b)
	if not self.cur_time then
		self:StopTime()
		return
	end
	if not b then
		self.cur_time = self.cur_time - 1
	end
	local ff = math.floor(self.cur_time / 60)
	local mm = self.cur_time - ff * 60
	--self.time_txt.text = StringHelper.formatTimeDHMS2(self.cur_time)
	self.time_txt.text = string.format("%02d:%02d",ff,mm)
	if self.cur_time <= 0 then
		self:StopTime()
	end
end

function C:OnExitScene()
	self:MyExit()
end

--切回前台
function C:on_backgroundReturn()
	self:UpdataTimer(true)
	self:UpdateTimeUI(true)

	self:RefreshScore()
	self:RefreshDot()
end

--重连不播"奖励提升"
function C:on_SYSByPms_ReConnecte()
end

function C:on_model_sys_by_pms_game_data_ReConnecte()
	self:model_sys_by_pms_rank_change()
	self:on_SYSByPms_ReConnecte()
	self:model_sys_by_pms_bullet_change()

--[[	self.cur_time = M.GetCurTime()
    self.update_time = Timer.New(function ()
    	self:UpdateTimeUI()
    end, 1, -1, nil, true)
    self.update_time:Start()
	self:UpdateTimeUI(true)--]]
end

function C:on_background_msg()
	--self:StopTime()
end


function C:on_RefreshCurRank(rank)
	if rank then
		if rank == -1 then
			self.rank_txt.text = "未上榜"
		else	
			self.rank_txt.text = rank
		end
	end
end

function C:on_EnterClick()
	SYSByPmsGameRankPanel_JFPM.Create()
end