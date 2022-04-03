-- 创建时间:2021-09-26
-- Panel:Act_061_XYHLTaskItem
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

Act_061_XYHLTaskItem = basefunc.class()
local C = Act_061_XYHLTaskItem
C.name = "Act_061_XYHLTaskItem"
local M = Act_061_XYHLManager

function C.Create(parent,config)
	return C.New(parent,config)
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

function C:ctor(parent,config)
	ExtPanel.ExtMsg(self)
    self.config = config
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
    self.slider = self.Slider.transform:GetComponent("Slider")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	self:MyRefresh()
end

function C:MyRefresh()
    self.desc_txt.text = self.config.task_desc
    self.award_img.sprite = GetTexture(self.config.award_img)
    self.award_txt.text = self.config.award_txt
    if self.config.tip_txt then
        self.tip_txt.gameObject:SetActive(true)
        self.tip_txt.text = self.config.tip_txt
    else
        self.tip_txt.gameObject:SetActive(false)
    end
    local data = GameTaskModel.GetTaskDataByID(self.config.task_id)
    if data then
        if self.config.level then
            if self.config.is_money then
                self.process_txt.text = math.min(data.now_total_process/100,self.config.need_process/100) .. "/" .. self.config.need_process/100
            else
                self.process_txt.text = math.min(data.now_total_process,self.config.need_process) .. "/" .. self.config.need_process
            end
            self.slider.value = data.now_total_process / self.config.need_process
            local b = basefunc.decode_task_award_status(data.award_get_status)
            b = basefunc.decode_all_task_award_status(b, data, M.get_count(self.config.task_id))
            local award_status = b[self.config.level]
            self.get_btn.gameObject:SetActive(award_status == 1)
            self.go_img.gameObject:SetActive(award_status == 0)
            self.already_img.gameObject:SetActive(award_status == 2)
        else
            if self.config.is_money then
                self.process_txt.text = math.min(data.now_process/100,self.config.need_process/100) .. "/" .. self.config.need_process/100
            else
                self.process_txt.text = math.min(data.now_process,self.config.need_process) .. "/" .. self.config.need_process
            end
            self.slider.value = data.now_process / self.config.need_process
            self.get_btn.gameObject:SetActive(data.award_status == 1)
            self.go_img.gameObject:SetActive(data.award_status == 0)
            self.already_img.gameObject:SetActive(data.award_status == 2)
        end
    end
end

function C:OnGetClick()
    if self.config.level then
        Network.SendRequest("get_task_award_new", {id = self.config.task_id, award_progress_lv = self.config.level})
    else
        Network.SendRequest("get_task_award", {id = self.config.task_id})
    end
end