-- 创建时间:2021-10-18
-- Panel:Act_063_XRHBPanel
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

Act_063_XRHBPanel = basefunc.class()
local C = Act_063_XRHBPanel
C.name = "Act_063_XRHBPanel"
local M = Act_063_XRHBManager

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
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
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
        self.cutdown_timer = nil
    end
    self:ClosePre()
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
	local parent = GameObject.Find("Canvas/LayerLv3").transform
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
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
    EventTriggerListener.Get(self.exchange_btn.gameObject).onClick = basefunc.handler(self, self.OnExchangeClick)
    self.cutdown_timer = CommonTimeManager.GetCutDownTimer(M.GetEndTime(),self.remain_txt)
	self:MyRefresh()
end

function C:MyRefresh()
    self:CreatePre()
end

local m_sort = function (v1,v2)
    local sort_tab = {1,0,2}
    local data1 = GameTaskModel.GetTaskDataByID(v1.task_id)
    local data2 = GameTaskModel.GetTaskDataByID(v2.task_id)
    local status1
    local status2
    if data1 then
        local b = basefunc.decode_task_award_status(data1.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data1, M.get_count(v1.task_id))
        status1 = b[v1.level]
    end
    if data2 then
        local b = basefunc.decode_task_award_status(data2.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data2, M.get_count(v2.task_id))
        status2 = b[v2.level]
    end
    status1 = sort_tab[status1 + 1]
    status2 = sort_tab[status2 + 1]
    if status1 < status2 then
        return false
    elseif status1 > status2 then
        return true
    else
        if v1.index < v2.index then
            return false
        else
            return true
        end
    end
end

function C:CreatePre()
    self:ClosePre()
    local config = M.GetConfig()
    MathExtend.SortListCom(config, m_sort)
    for i=1,#config do
        local pre = Act_063_XRHBItemBase.Create(self.Content.transform, config[i])
        self.pre_cell[#self.pre_cell + 1] = pre
    end
end

function C:ClosePre()
    if self.pre_cell then
        for k,v in pairs(self.pre_cell) do
            v:MyExit()
        end
    end
    self.pre_cell = {}
end

function C:OnBackClick()
    self:MyExit()
end

function C:on_model_task_change_msg(data)
    if data and self:IsCareId(data.id) then
        self:MyRefresh()
    end
end

function C:IsCareId(id)
    local config = M.GetConfig()
    for k,v in pairs(config) do
        if v.task_id == id then
            return true
        end
    end
    return false
end

function C:OnExchangeClick()
    if Act_042_XSHBManager and Act_042_XSHBManager.CheckIsShow({condi_key = "actp_own_task_p_txz"}) then
        Act_042_XSHBPanel.Create()
    end
end