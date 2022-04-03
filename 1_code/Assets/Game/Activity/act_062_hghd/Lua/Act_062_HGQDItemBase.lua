-- 创建时间:2021-10-12
-- Panel:Act_062_HGQDItemBase
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

Act_062_HGQDItemBase = basefunc.class()
local C = Act_062_HGQDItemBase
C.name = "Act_062_HGQDItemBase"
local M = Act_062_HGHDManager

function C.Create(parent, config, level, all_count)
	return C.New(parent, config, level, all_count)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, config, level, all_count)
	ExtPanel.ExtMsg(self)
    self.config = config
    self.level = level
    self.all_count = all_count
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    self.gameObject:GetComponent("RectTransform").sizeDelta = Vector2.New(1040,100)
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	self:MyRefresh()
end

function C:MyRefresh()
    self.day_img.sprite = GetTexture("hgqd_imgf_" .. self.level)
    for i=1,#self.config.award_img do
        self["award" .. i .. "_img"].sprite = GetTexture(self.config.award_img[i])
        self["award" .. i .. "_txt"].text = self.config.award_txt[i]
        if self.config.award_img[i] == "3dby_icon_p3" or self.config.award_img[i] == "3dby_icon_p5" or self.config.award_img[i] == "3dby_icon_p6" then
            self["award" .. i .. "_img"].transform.localScale = Vector3.New(2,2,1)
        elseif self.config.award_img[i] == "3dby_btn_sd" or self.config.award_img[i] == "3dby_btn_bd" then
            self["award" .. i .. "_img"].transform.localScale = Vector3.New(0.8,0.8,1)
        else
            self["award" .. i .. "_img"].transform.localScale = Vector3.New(1,1,1)
        end
    end
    local data = GameTaskModel.GetTaskDataByID(self.config.task_id)
    if data then
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, self.all_count)
        self.get_btn.gameObject:SetActive(b[self.level] == 1)
        self.already_img.gameObject:SetActive(b[self.level] == 2)
        self.get_img.gameObject:SetActive(b[self.level] == 0)
        if b[self.level - 1] and b[self.level - 1] == 2 and b[self.level] == 0 then
            self.get_txt.text = "明日领取"
        else    
            self.get_txt.text = "签到领取"
        end
    end
end

function C:OnGetClick()
    Network.SendRequest("get_task_award_new", {id = self.config.task_id, award_progress_lv = self.level})
end