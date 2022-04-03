-- 创建时间:2021-10-18
-- Panel:Act_063_XRHBEnterPrefab
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

Act_063_XRHBEnterPrefab = basefunc.class()
local C = Act_063_XRHBEnterPrefab
C.name = "Act_063_XRHBEnterPrefab"
local M = Act_063_XRHBManager

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
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
    EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterClick)
    if M.GetEndTime() - os.time() <= 259200 then
        self.remain_txt.gameObject:SetActive(true)
    else
        self.remain_txt.gameObject:SetActive(false)
    end
    self.cutdown_timer = CommonTimeManager.GetCutDownTimer(M.GetEndTime(),self.remain_txt,true,nil,{remain_second = 259200,fun = function ()
        self.remain_txt.gameObject:SetActive(true)
    end})
	self:MyRefresh()
end

function C:MyRefresh()
    if M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
        self.lfl.gameObject:SetActive(true)
    else
        self.lfl.gameObject:SetActive(false)
        if PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
            self.red.gameObject:SetActive(false)
        else
            self.red.gameObject:SetActive(true)
        end 
    end
end

function C:OnEnterClick()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
    Act_063_XRHBPanel.Create()
    self:MyRefresh()
end

function C:on_global_hint_state_change_msg(parm)
    if parm.gotoui == M.key then 
        self:MyRefresh()
    end
end