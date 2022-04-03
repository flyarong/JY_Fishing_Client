--ganshuangfeng 比赛场等待界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"
MatchComWaitStartPanel = basefunc.class()
local M = MatchComWaitStartPanel
M.name = "MatchComWaitStartPanel"
local lister
local listerRegisterName = "MatchComWaitStartPanel"
local can_share_time = -1
local share_interval = 20
local is_start = false
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
    MainModel.UserInfo.shared_matchStatus = 5
    self:MyInit()
    self:MyRefresh()
end

function M:MyInit()
    ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_bisai_bisaidengdai.audio_name)
    LuaHelper.GeneratingVar(self.transform, self)
    self.close_btn.onClick:AddListener(
        function()
            self:OnClickCloseSignup()
        end
    )
    self:MakeLister()
    self.parm.logic.setViewMsgRegister(lister, listerRegisterName)
    self.timer = Timer.New(basefunc.handler(self, self.updateCountdown), 1, -1, true)
    self.timer:Start()
    self.allPlayer = 0
    self.curPlayer = 0
    self.countdown = 0
    self.share_countdown = 0
    is_start = false
    self:RefreshSliderAndReward()
end

function M:RefreshSliderAndReward()
    if GameMatchModel.data.game_id then
        self.transform:Find("ImgTitle").gameObject:SetActive(false)
        self.transform:Find("Slider").gameObject:SetActive(true)
        if not self.RankReward then
            self.RankReward = MatchComRankRewardPanel.Create(GameMatchModel.GetGameIDToConfig(GameMatchModel.data.game_id), GameMatchModel.GetGameIDToAward(GameMatchModel.data.game_id))
            self.RankReward.transform.position = self.transform:Find("RankReward").position
        end
    else
        self.transform:Find("Slider").gameObject:SetActive(false)
    end
end

function M:updateCountdown()
    if self.countdown and self.countdown > 0 then
        self.countdown = self.countdown - 1
        self:refreshCountDown()
    end
end

function M:refreshShareCountDown()
    self.share_txt.text = self.share_countdown .. "秒后可分享"
    if self.share_countdown <= 0 then
        local share_btn_img = self.share_btn.gameObject:GetComponent("Image")
        share_btn_img.sprite = GetTexture("com_btn_5")
        share_btn_img:SetNativeSize()
        self.share_btn.enabled = true
        self.share_txt.gameObject:SetActive(false)
        self.share1_txt.gameObject:SetActive(true)
    end
end

function M:refreshCountDown()
    self.close_txt.text = self.countdown .. "秒后可返回"
    if self.countdown <= 0 then
        self.close_btn.interactable = true
        self.close_btn.gameObject:SetActive(true)
        self.close_txt.gameObject:SetActive(false)
    end
end

function M:refreshAllPlayer(num)
    if self.parm.model.data and self.parm.model.data.model_status==self.parm.model.Model_Status.wait_begin  then
        if not num or num == self.allPlayer then
            return
        end
        self.allPlayer = num
        if IsEquals(self.all_player_txt) then
            self.all_player_txt.text = "满" .. num .. "人开赛"
        end
    end
end
function M:refreshCurPlayer(num)
    if self.parm.model.data and self.parm.model.data.model_status == self.parm.model.Model_Status.wait_begin then
        if not num or num == self.curPlayer or num == 0 then
            return
        end
        if num > self.allPlayer then num = self.allPlayer end
        if is_start then return end
        if self.curPlayer == self.allPlayer then is_start = true end

        if not self.old_num then
            if num < self.curPlayer then
                self.old_num = num
                return
            end
        else
            if num < self.old_num then
                num,self.old_num = self.old_num,num
            end
        end

        self.curPlayer = num
        self.num_txt.text = num
        local startFillAmount = self.fill_img.fillAmount
        local endFillAmount = self.curPlayer / self.allPlayer
        if startFillAmount ~= endFillAmount then
            self.waitTimer = self.parm.ani.ChangeWaitUI(self.fill_img, self.effect, startFillAmount, endFillAmount)
        end
    end
end

function M:refreshCancelSignBtn(isCancelSignup, countdown)
    if isCancelSignup == 0 then
        self.close_btn.gameObject:SetActive(false)
        return
    end

    self.close_btn.gameObject:SetActive(true)
    if not countdown then
        return
    end
    local time = math.ceil(countdown)
    if time ~= self.countdown then
        self.countdown = time
        self.close_btn.interactable = false
        self.close_btn.gameObject:SetActive(false)
        self.close_txt.gameObject:SetActive(true)
    end
    self:refreshCountDown()
end

function M:refreshShareBtn()
    if false then
        if can_share_time < 0 then
            can_share_time = os.time() + share_interval
        end
        self.share_btn.gameObject:SetActive(true)
        local countdown = can_share_time - os.time()
        local time = math.ceil(countdown)
        if time ~= self.share_countdown then
            self.share_countdown = time
            local share_btn_img = self.share_btn.gameObject:GetComponent("Image")
            share_btn_img.sprite = GetTexture("com_btn_8")
            share_btn_img:SetNativeSize()
            self.share_btn.enabled = false
            self.share_txt.gameObject:SetActive(true)
            self.share1_txt.gameObject:SetActive(false)
        end
        self:refreshShareCountDown()
    end
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function M:MyRefresh()
    if self.parm.model.data then
        self:refreshAllPlayer(self.parm.model.data.total_players)
        self:refreshCurPlayer(self.parm.model.data.signup_num)
        self:refreshCancelSignBtn(self.parm.model.data.is_cancel_signup, self.parm.model.data.countdown)
        self:RefreshSliderAndReward()
    end
end

--[[退出功能，供logic和model调用，只做一次]]
function M:MyExit()
    DSM.PopAct()
    can_share_time = -1
    if self.timer then
        self.timer:Stop()
    end
    if self.waitTimer then
        self.waitTimer:Stop()
    end
    if self.share_timer then
        self.share_timer:Stop()
    end
    
    if self.RankReward then
        self.RankReward:Close()
    end
    lister = nil
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
    lister = {}
    lister["model_nor_mg_req_cur_signup_num_response"] = basefunc.handler(self, self.nor_mg_req_cur_signup_num_response)
    lister["model_nor_mg_cancel_signup_fail_response"] = basefunc.handler(self, self.nor_mg_cancel_signup_fail_response)
end

function M:nor_mg_req_cur_signup_num_response(result)
    if result == 0 then
        self:refreshCurPlayer(self.parm.model.data.signup_num)
    else
        print("<color=red>mg_req_cur_signup_num_response</color>",result)
    end
end

function M:nor_mg_cancel_signup_fail_response(result)
    --错误处理 （弹窗）
    HintPanel.ErrorMsg(result)
end

function M:OnClickCloseSignup()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    Network.SendRequest("nor_mg_cancel_signup", {})
end

function M:OnClickShare()
    self:ShareURL()
end

function M:ShareImage()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local function finishcall()
        --分享后重置时间
        can_share_time = -1
        self:refreshShareBtn()
    end
end

function M:ShareURL()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local finishcall =
        function()
        self.share_timer =
            Timer.New(
            function()
                --分享后重置时间
                can_share_time = -1
                self:refreshShareBtn()
            end,
            1,1
        )
        self.share_timer:Start()
    end

    local match_name = GameMatchModel.macthUIConfig.config[GameMatchModel.data.game_id].game_name
    local shareLink = string.format(share_link_config.share_link[7].link[1], match_name, MainLogic.GetPTDeeplinkKeyword())
    ShareLogic.ShareGM(
        shareLink,
        function(str)
            print("<color=red>分享完成....str = " .. str .. "</color>")
            MainModel.SendShareFinish("shared_match")
            finishcall()
        end
    )
end
