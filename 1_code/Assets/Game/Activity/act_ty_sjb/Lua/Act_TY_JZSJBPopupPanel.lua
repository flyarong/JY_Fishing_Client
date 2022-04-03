-- 创建时间:2021-09-22
-- Panel:Act_TY_JZSJBPopupPanel
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

Act_TY_JZSJBPopupPanel = basefunc.class()
local C = Act_TY_JZSJBPopupPanel
C.name = "Act_TY_JZSJBPopupPanel"
local M = Act_TY_JZSJBManager

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
    self.lister["query_rank_data_response"] = basefunc.handler(self,self.on_query_rank_data_response)
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
	self.gameObject:SetActive(false)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
    EventTriggerListener.Get(self.go_btn.gameObject).onClick = basefunc.handler(self, self.OnGoClick)
    Network.SendRequest("query_rank_data",{rank_type = M.m_data.rank_type,page_index = 1},"")
end

function C:MyRefresh(all_data)
    self.gameObject:SetActive(true)
    local config = M.GetConifg()
    local cutDownTime = M.GetActivityEndTime()
    self.cutdown_timer = CommonTimeManager.GetCutDownTimer(cutDownTime,self.remain_txt)
    local data = M.GetRankData(M.m_data.rank_type)
    self.rank_txt.text = "您当前在" .. config.act_name .. "中排名<color=#FF0000>第" .. data.rank .. "</color>"
    local need = all_data.rank_data[data.rank - 1].score - data.score
    self.score_txt.text = "距离前1名还差<color=#FF0000>" .. need .. "</color>" .. M.GetCurItemName(1)
    self.desc_txt.text = "购买" .. config.act_gift_name .. "可获得" .. M.GetCurItemName(1) .. "<color=#FF0000>加成特权</color>!"
end

function C:OnBackClick()
    self.MyExit()
end

function C:OnGoClick()
    local config = M.GetConifg()
    GameManager.CommonGotoScence({gotoui = "act_ty_gifts",goto_scene_parm = "panel",goto_type = config.act_gift_key})
    self.MyExit()
end

function C:on_query_rank_data_response(_,data)
    if data and data.result == 0 then
        if data.rank_type == M.m_data.rank_type then
            for i,v in ipairs(data.rank_data) do
                if M.have_point then 
                    if math.floor(v.score/M.m_data.type_info) == (v.score/M.m_data.type_info) then
                        v.score = v.score/M.m_data.type_info
                    else
                        v.score = string.format("%.1f", v.score/M.m_data.type_info)
                    end
                else
                    v.score = math.floor(v.score/M.m_data.type_info)
                end 
            end
            self:MyRefresh(data)
        end
    end
end