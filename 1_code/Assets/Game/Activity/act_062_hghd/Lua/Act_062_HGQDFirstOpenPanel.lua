-- 创建时间:2021-10-10
-- Panel:Act_062_HGQDFirstOpenPanel
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

Act_062_HGQDFirstOpenPanel = basefunc.class()
local C = Act_062_HGQDFirstOpenPanel
C.name = "Act_062_HGQDFirstOpenPanel"
local M = Act_062_HGHDManager

function C.Create(parent, callback)
	return C.New(parent, callback)
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
    if self.cutdown_timer then
        self.cutdown_timer:Stop()
    end
    if self.callback then
        self.callback()
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

function C:ctor(parent, callback)
    ExtPanel.ExtMsg(self)
    self.callback = callback
    
    local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.gameObject:SetActive(false)
    LuaHelper.GeneratingVar(self.transform, self)
    if PlayerPrefs.GetInt(M.key .. MainModel.UserInfo.user_id .. "first",0) == M.GetEndTime() then
        if self.callback then
            self.callback()
        end
        destroy(self.gameObject)
        return
    else
        PlayerPrefs.SetInt(M.key .. MainModel.UserInfo.user_id .. "first",M.GetEndTime())
        self.gameObject:SetActive(true)
    end
      
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function C:InitUI()
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
    EventTriggerListener.Get(self.go_btn.gameObject).onClick = basefunc.handler(self, self.OnGoClick)
	self:MyRefresh()
end

function C:MyRefresh()
    local tab = {}
    for k,v in pairs(M.qd_config) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condi_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            tab = v
            break
        end
    end
    

    self.cutdown_timer = CommonTimeManager.GetCutDownTimer(M.GetEndTime(),self.remain_txt)

    for i=1,#tab.award_img[1] do
        self["award" .. i .. "_img"].sprite = GetTexture(tab.award_img[1][i])
        self["award" .. i .. "_txt"].text = tab.award_txt[1][i]
    end
end

function C:OnBackClick()
    local parm = {gotoui = "sys_act_base", goto_type = "hghd", goto_scene_parm = "panel"}
    GameManager.GotoUI(parm)
    self:MyExit()
end

function C:OnGoClick()
    local parm = {gotoui = "sys_act_base", goto_type = "hghd", goto_scene_parm = "panel"}
    GameManager.GotoUI(parm)
end