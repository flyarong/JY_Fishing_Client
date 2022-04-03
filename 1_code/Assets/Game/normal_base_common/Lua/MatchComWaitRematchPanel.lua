--ganshuangfeng 比赛场等待界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"
MatchComWaitRematchPanel = basefunc.class()
local M = MatchComWaitRematchPanel
M.name = "MatchComWaitRematchPanel"
local lister
local listerRegisterName="DdzMatchWaitRematchListerRegister"
local instance
function M.Create(parm)
	DSM.PushAct({panel = M.name})
	SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()
	if instance then
        instance:MyExit()
    end
    instance = M.New(parm)
    return instance
end

function M.CloseUI()
    if instance then
        instance:MyClose()
    end
end

function M:ctor(parm)
	self.parm = parm
    local parent = GameObject.Find("Canvas/LayerLv1").transform
    self:MakeLister()
    local obj = newObject(M.name, parent)
    local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    self:MyInit()
    self:MyRefresh()
end

--[[初始化功能，创建好panel后在Award中调用，只做一次]]
function M:MyInit()
	ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_bisai_bisaidengdai.audio_name)
	LuaHelper.GeneratingVar(self.transform, self)
	self.back_btn.onClick:AddListener(
        function()
			self:OnClickCloseSignup()
        end
    )
	self:MakeLister()
	self.parm.logic.setViewMsgRegister(lister,listerRegisterName)
	self.timer = Timer.New(basefunc.handler(self,self.UpdateCountdown) , 1, -1, true)
	self.timer:Start()
	self.countdown=0
	self.curPlayerNum = 0
	local gameId = GameMatchModel.GetCurrGameID()
	if gameId and GameMatchModel.IsGMS(gameId) then
		MainModel.CheckPushNotification()
	end
end

function M:UpdateCountdown()
	if self.countdown  and self.countdown>0 then
		self.countdown= self.countdown-1
		self:RefreshCountdown()
	elseif self.countdown  and self.countdown == 0 then
		self.hint_zero_txt.text = "请稍等，比赛即将开始"
	end
end

function M:RefreshCountdown()
	local list = split(os.date("%M:%S", self.countdown), ":")
		self.countdown_1_txt.text = list[1]
		self.countdown_2_txt.text = list[2]
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function M:MyRefresh()
	local game_id = GameMatchModel.GetCurrGameID()
	if game_id then
		if not self.RankReward then
			log("---------------->>> Current game id:" .. game_id)
			self.RankReward = MatchComRankRewardPanel.Create(GameMatchModel.GetGameIDToConfig(game_id), GameMatchModel.GetGameIDToAward(game_id))
			if IsEquals(self.RankReward.transform) then
				self.RankReward.transform.position = self.transform:Find("RankReward").position
			end
		end

		Network.SendRequest("nor_mg_get_match_status",{id = game_id})
		self.countdown_root.gameObject:SetActive(true)
		self.back_btn.gameObject:SetActive(true)
	elseif not game_id then
		self.countdown_root.gameObject:SetActive(false)
		self.back_btn.gameObject:SetActive(false)
	end
	self:refreshCurPlayer(self.parm.model.data.signup_num)
end

--[[退出功能，供logic和model调用，只做一次]]
function M:MyExit()
	DSM.PopAct()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
	
    if self.RankReward then
        self.RankReward:Close()
	end
	if self.parm then
		self.parm.logic.clearViewMsgRegister(listerRegisterName)
	end
	self.parm = nil
	GameObject.Destroy(self.gameObject)
	instance = nil
end

function M:MyClose()
    self:MyExit()
end

function M:MakeLister()
	lister={}
	lister["model_nor_mg_req_cur_signup_num_response"] = basefunc.handler(self, self.model_nor_mg_req_cur_signup_num_response)
	lister["model_nor_mg_get_match_status_response"] = basefunc.handler(self,  self.model_nor_mg_get_match_status_response)
end

function M:model_nor_mg_req_cur_signup_num_response(result)
    if result == 0 then
        self:refreshCurPlayer(self.parm.model.data.signup_num)
    else
        --错误处理 （弹窗）
        -- HintPanel.ErrorMsg(result)
        print("<color=red>mg_req_cur_signup_num_response</color>",result)
    end
end

function M:model_nor_mg_get_match_status_response()
	local data = self.parm.model.data
	if data and data.model_status == self.parm.model.Model_Status.wait_begin then
	   if data.start_time and data.start_time > 0 then
			self.countdown = data.start_time
			self:UpdateCountdown()
		end
    end
end

function M:OnClickCloseSignup(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local pre = HintPanel.Create(2,"比赛即将开始，现在离开可能错过比赛，请记得提前来参赛哦！",function ()
		Network.SendRequest("nor_mg_cancel_signup", {})
	end)
	pre:SetButtonText(nil, "离开一会儿")
end

function M:refreshCurPlayer(num)
    if not num or num == self.curPlayerNum then
        return
	end
	self.curPlayerNum = num
	self.hint_zero_txt.text = "已报名人数：" .. num
end
