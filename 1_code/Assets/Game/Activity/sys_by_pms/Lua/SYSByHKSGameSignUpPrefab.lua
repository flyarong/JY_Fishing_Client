-- 创建时间:2021-10-27
-- Panel:SYSByHKSGameSignUpPrefab
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

SYSByHKSGameSignUpPrefab = basefunc.class()
local C = SYSByHKSGameSignUpPrefab
C.name = "SYSByHKSGameSignUpPrefab"
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
    self.signup_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnSignClick()
    end)

    CommonHuxiAnim.Start(self.signup_btn.gameObject,1)
	self:MyRefresh()
end

function C:MyRefresh()
    if M.QueryHKSnum() == 10 then
        if M.CheckHKSGiftIsBought() then
            self.title_txt.text = "免费参加"
        else
            self.title_txt.text = "额外挑战"
        end
    else
        self.title_txt.text = "免费参加"
    end
end


function C:OnSignClick()
    if M.QueryHKSnum() == 10 then
        if M.CheckHKSGiftIsBought() then
            GameButtonManager.RunFun({gotoui = "sys_by_pms", data={id = 5}}, "signup_hks")
        else
            SYSBYHKSGiftPanel.Create()
        end
    else
        GameButtonManager.RunFun({gotoui = "sys_by_pms", data={id = 5}}, "signup_hks")
    end
end

function C:on_finish_gift_shop(id)
    if id == M.GetHKSGiftID() then
        self:MyRefresh()
    end
end