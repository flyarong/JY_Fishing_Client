-- 创建时间:2021-10-25
-- Panel:FishingMatchHallHKSPanel
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

FishingMatchHallHKSPanel = basefunc.class()
local C = FishingMatchHallHKSPanel
C.name = "FishingMatchHallHKSPanel"
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
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["finish_gift_shop"] = basefunc.handler(self,self.on_finish_gift_shop)
    self.lister["model_pms_game_info_change_msg"] = basefunc.handler(self,self.on_model_pms_game_info_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.cutdown_timer then
        self.cutdown_timer:Stop()
    end
    if self.cutdown_timer2 then
        self.cutdown_timer2:Stop()
    end
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
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
    self.help_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnHelpClick()
    end)
    self.rank_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnRankClick()
    end)
    self.signup_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnSignClick()
    end)

	M.GetHKSGameInfo()
    M.update_time_query_PMS_Info()--每1分钟请求一次数据
end

function C:MyRefresh()
    local tab = os.date("*t")
    local target_month
    local target_year
    if tab.month + 1 <= 12 then
        target_month = tab.month + 1
        target_year = tab.year
    else
        target_month = 1
        target_year = tab.year + 1
    end
    local temp = {year = target_year,month = target_month,day = 1,hour = 0,min = 0,sec = 0,isdst = false}
    local begin_time = os.time(temp) - 86400
    local end_time = os.time(temp)
    if os.time() < begin_time then
        if self.cutdown_timer then
            self.cutdown_timer:Stop()
        end
        local _temp = os.date("*t",begin_time)
        self.time_txt.text = string.format("%d年%d月%d日%02d:%02d:%02d", _temp.year, _temp.month, _temp.day, _temp.hour, _temp.min, _temp.sec)
        self.hint1_txt.text = "开赛时间:"
        self.time_rect.transform.localPosition = Vector3.New(-120,self.time_rect.transform.localPosition.y,self.time_rect.transform.localPosition.z)
    elseif os.time() >= begin_time and os.time() <= end_time then
        if self.cutdown_timer then
            self.cutdown_timer:Stop()
        end
        self.cutdown_timer = CommonTimeManager.GetCutDownTimer(end_time,self.time_txt,true,function ()
            self:MyRefresh()
        end,{remain_second = 86400,function ()
            self:MyRefresh()
        end})
        self.hint1_txt.text = "结束时间:"
        self.time_rect.transform.localPosition = Vector3.New(0,self.time_rect.transform.localPosition.y,self.time_rect.transform.localPosition.z)
    end

    if begin_time - os.time() > 86400 then
        self.signup_btn.gameObject:SetActive(false)
        self.signup_img.gameObject:SetActive(true)
        self.signup2_txt.text = math.floor((begin_time - os.time())/86400) .. "天后开赛"
    elseif (begin_time - os.time()) > 0 and (begin_time - os.time()) <= 86400 then
        self.signup_btn.gameObject:SetActive(false)
        self.signup_img.gameObject:SetActive(true)
        if self.cutdown_timer2 then
            self.cutdown_timer2:Stop()
        end
        self.cutdown_timer2 = CommonTimeManager.GetCutDownTimer(begin_time,self.signup2_txt,true,function ()
            self:MyRefresh()
        end,nil,"后开赛")
    else
        local _tab = M.GetCanSignHKSTimes()
        dump(_tab,"<color=yellow><size=15>++++++++++_tab++++++++++</size></color>")
        if (_tab.free + _tab.no_free) >= 1 then
            self.signup_btn.gameObject:SetActive(true)
            self.signup_img.gameObject:SetActive(false)
            self.signup1_txt.text = "免费报名"
        else
            if M.CheckHKSGiftIsBought() then
                self.signup_btn.gameObject:SetActive(false)
                self.signup_img.gameObject:SetActive(true)
                self.signup2_txt.text = "挑战次数已用完"
            else
                self.signup_btn.gameObject:SetActive(true)
                self.signup_img.gameObject:SetActive(false)
                self.signup1_txt.text = "额外挑战"
            end
        end
    end
end

function C:OnHelpClick()
    SYSByPmsGameRulesPanel.Create("hks")
end

function C:OnRankClick()
    local index = M.CheckCurIsInHKSDay()
    SYSByPmsHallRankPanel.Create("hks",index)
end

function C:OnSignClick()
    local _tab = M.GetCanSignHKSTimes()
    if (_tab.free + _tab.no_free) >= 1 then
        if MainModel.UserInfo.vip_level >= 4 then
            GameButtonManager.RunFun({gotoui = "sys_by_pms", data={id = 5}}, "signup_hks")
        else
            LittleTips.Create("VIP等级不满足条件")
        end
    else
        if not M.CheckHKSGiftIsBought() then
            SYSBYHKSGiftPanel.Create()
        end
    end 
end

function C:on_finish_gift_shop(id)
    if id == M.GetHKSGiftID() then
        self:MyRefresh()
    end
end

function C:on_model_pms_game_info_change_msg()
    self:MyRefresh()
end