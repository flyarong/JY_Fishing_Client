-- 创建时间:2021-10-26
-- Panel:SYSByHKSGamePanel
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

SYSByHKSGamePanel = basefunc.class()
local C = SYSByHKSGamePanel
C.name = "SYSByHKSGamePanel"
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
    self.lister["SYSBYPMS_is_anim_finish_msg"] = basefunc.handler(self,self.on_SYSBYPMS_is_anim_finish_msg)
    self.lister["SYSBYPMS_the_match_is_exit_msg"] = basefunc.handler(self,self.on_SYSBYPMS_the_match_is_exit_msg)
    self.lister["SYSBYPMS_signup_is_success_msg"] = basefunc.handler(self,self.on_SYSBYPMS_signup_is_success_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.pre2 then
            self.pre2:MyExit()
            self.pre2 = nil
        end
    if self.pre1 then
        self.pre1:MyExit()
        self.pre1 = nil
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
    self:CheckCreateWhoHKS()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:CheckCreateWhoHKS()
    if M.CheckCreateWhoHKS() == 1 then
        if not self.pre1 then

        else
            self:PreDestroy(2)
        end
        self.pre1 = SYSByHKSGameInfoPrefab.Create(self.transform)
        self:PreDestroy(1)
    elseif M.CheckCreateWhoHKS() == 2 then
        if not self.pre2 then

        else
            self:PreDestroy(1)
        end
        self.pre2 = SYSByHKSGameSignUpPrefab.Create(self.transform)
        self:PreDestroy(2)
    end
end

function C:on_SYSBYPMS_is_anim_finish_msg()
    self:CheckCreateWhoHKS()
end

function C:PreDestroy(_type)
    if _type == 1 then
        if self.pre2 then
            self.pre2:MyExit()
            self.pre2 = nil
        end
    elseif _type == 2 then
        if self.pre1 then
            self.pre1:MyExit()
            self.pre1 = nil
        end
    end
end

function C:on_SYSBYPMS_the_match_is_exit_msg()
    self:CheckCreateWhoHKS()
end

function C:on_SYSBYPMS_signup_is_success_msg()
    self:CheckCreateWhoHKS()
end