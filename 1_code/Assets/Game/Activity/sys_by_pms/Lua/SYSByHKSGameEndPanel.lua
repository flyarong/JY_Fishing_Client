-- 创建时间:2021-10-26
-- Panel:SYSByHKSGameEndPanel
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

SYSByHKSGameEndPanel = basefunc.class()
local C = SYSByHKSGameEndPanel
C.name = "SYSByHKSGameEndPanel"
local M = SYSByPmsManager

function C.Create(data)
	return C.New(data)
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
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.timer then
        self.timer:Stop()
        self.timer = nil
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

function C:ctor(data)
    self.data = data
    dump(self.data,"<color>+++++++++++++++++++++self.data++++++++++++++++++++</color>")
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
    EventTriggerListener.Get(self.continue_btn.gameObject).onClick = basefunc.handler(self, self.OnContinueClick)
    EventTriggerListener.Get(self.retry_btn.gameObject).onClick = basefunc.handler(self, self.OnRetryClick)
    M.QueryCurHKSGameInfo()
    self:RefreshJF()
    self:RefreshPM()
    

    if self.timer then
        self.timer:Stop()
        self.timer = nil
    end
    self.timer = Timer.New(function ()
        self:MyExit()
        if self.timer then
            self.timer:Stop()
            self.timer = nil
        end
    end,120,-1,false,true)
    self.timer:Start()

	self:MyRefresh()
end

function C:MyRefresh()
    local _tab = M.GetCanSignHKSTimes()
    self.remainBG.gameObject:SetActive(true)
    if _tab.free >= 1 then
        self.retry_btn.gameObject:SetActive(true)
        self.retry_img.gameObject:SetActive(false)
        self.retry_txt.text = "再来一场"
        self.remain_time_txt.text = "免费次数:" .. _tab.free .. "次"
    else
        if M.CheckHKSGiftIsBought() then
            if _tab.no_free >= 1 then
                self.retry_btn.gameObject:SetActive(true)
                self.retry_img.gameObject:SetActive(false)
                self.retry_txt.text = "再来一场"
                self.remain_time_txt.text = "额外次数:" .. _tab.no_free .. "次"
            else
                self.retry_btn.gameObject:SetActive(false)
                self.retry_img.gameObject:SetActive(true)
                self.retry_txt.text = "挑战次数已用完"
                self.remain_time_txt.text = ""
                self.remainBG.gameObject:SetActive(false)
            end
        else
            self.retry_btn.gameObject:SetActive(true)
            self.retry_img.gameObject:SetActive(false)
            self.retry_txt.text = "额外挑战"
            self.remain_time_txt.text = "免费次数:0次"
        end
    end
end

function C:OnContinueClick()
    self:MyExit()
end

function C:OnRetryClick()
    local _tab = M.GetCanSignHKSTimes()
    if (_tab.free + _tab.no_free) >= 1 then
        GameButtonManager.RunFun({gotoui = "sys_by_pms", data={id = 5}}, "signup_hks")
        self:MyExit()
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

function C:RefreshJF()  
    self.now_txt.text = self.data.score / 100
    if (self.data.his_score == -1 and self.data.score ~= -1) or (self.data.his_score ~= -1 and self.data.score ~= -1 and self.data.score > self.data.his_score) then
        self.arrow1_img.gameObject:SetActive(true)
        self.high_txt.text = self.data.score / 100
    else
        self.arrow1_img.gameObject:SetActive(false)
        self.high_txt.text = self.data.his_score / 100
    end
end

function C:RefreshPM()
    if (self.data.his_rank == -1 and self.data.cur_rank ~= -1) or (self.data.his_rank ~= -1 and self.data.cur_rank ~= -1 and self.data.cur_rank < self.data.his_rank) then
        self.arrow2_img.gameObject:SetActive(true)
        self.rank_txt.text = self.data.cur_rank 
    else
        self.arrow2_img.gameObject:SetActive(false)
        self.rank_txt.text = self.data.his_rank 
    end

    if self.rank_txt.text == "-1" then
        self.rank_txt.text = "未上榜"
    end
    local rank
    if (self.data.his_rank == -1 and self.data.cur_rank ~= -1) or (self.data.his_rank ~= -1 and self.data.cur_rank ~= -1 and self.data.cur_rank < self.data.his_rank) then
        rank = self.data.cur_rank 
    else
        rank = self.data.his_rank 
    end
    local award_list = SYSByPmsManager.GetPMSAwardCfgByRank(nil,rank,"hks")
    if table_is_null(award_list) then
        self.award_pm.gameObject:SetActive(false)
        self.tip_pm.gameObject:SetActive(true)
    else
        self.award_pm.gameObject:SetActive(true)
        self.awardpm_img.sprite = GetTexture(award_list[1].icon)
        local item1 = GameItemModel.GetItemToKey(award_list[1].type)
        self.awardpm_txt.text = StringHelper.ToCash(award_list[1].num)
    end 
end