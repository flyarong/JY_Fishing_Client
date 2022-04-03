-- 创建时间:2021-09-26
-- Panel:Act_061_XYHLChild1Panel
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

Act_061_XYHLChild1Panel = basefunc.class()
local C = Act_061_XYHLChild1Panel
C.name = "Act_061_XYHLChild1Panel"
local M = Act_061_XYHLManager
local link_tab = {
    [1] = {
        condi_key = "tthlby_cpl",
        logo = "byam_logo_byam",
        logo_scale = 0.3,
        link = "http://cwww.game3396.com/webpages/hlbyDownload.html?platform=byam&market_channel=byam&pageType=byam&category=1",
    },
    [2] = {
        condi_key = "byam_cpl",
        logo = "zr_icon_logo",
        logo_scale = 0.5,
        link = "http://cwww.game3396.com/webpages/hlbyDownload.html?platform=normal&market_channel=normal&pageType=normal&category=1",
    },
    [3] = {
        condi_key = "cjj_cpl",
        logo = "zr_icon_logo",
        logo_scale = 0.5,
        link = "http://cwww.game3396.com/webpages/hlbyDownload.html?platform=normal&market_channel=normal&pageType=normal&category=1",
    },
}

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
    EventTriggerListener.Get(self.download_btn.gameObject).onClick = basefunc.handler(self, self.OnDownLoadClick)
    for k,v in pairs(link_tab) do
        if M.GetCurKey() == v.condi_key then
            self.config = v
            break
        end
    end
	self:MyRefresh()
end

function C:MyRefresh()
    self.logo_img.sprite = GetTexture(self.config.logo)
    self.logo_img:SetNativeSize()
    self.logo_img.transform.localScale = Vector3(self.config.logo_scale,self.config.logo_scale,1)
end

function C:OnDownLoadClick()
    UnityEngine.Application.OpenURL(self.config.link)
end