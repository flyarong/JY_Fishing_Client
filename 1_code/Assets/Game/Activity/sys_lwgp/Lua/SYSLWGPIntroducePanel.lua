-- 创建时间:2021-03-04
-- Panel:SYSLWGPIntroducePanel
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

SYSLWGPIntroducePanel = basefunc.class()
local C = SYSLWGPIntroducePanel
C.name = "SYSLWGPIntroducePanel"
local M = SYSLWGPManager

local instance
function C.Create()
	if instance then
        return instance
    end
    instance = C.New()
    return instance
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
	if instance then
		instance = nil
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
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	-- EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.sure_btn.gameObject).onClick = basefunc.handler(self, self.OnSureClick)
	EventTriggerListener.Get(self.notip_btn.gameObject).onClick = basefunc.handler(self, self.OnNoTipClick)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnSureClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:MyExit()
end

function C:OnNoTipClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if PlayerPrefs.GetInt("SYSLWGP"..MainModel.UserInfo.user_id.."notip",0) == 0 then
		PlayerPrefs.SetInt("SYSLWGP"..MainModel.UserInfo.user_id.."notip",os.time())
	else
		PlayerPrefs.SetInt("SYSLWGP"..MainModel.UserInfo.user_id.."notip",0)
	end
	self:RefreshGou()
end

function C:RefreshGou()
	self.gou.gameObject:SetActive(PlayerPrefs.GetInt("SYSLWGP"..MainModel.UserInfo.user_id.."notip",0) ~= 0)
end