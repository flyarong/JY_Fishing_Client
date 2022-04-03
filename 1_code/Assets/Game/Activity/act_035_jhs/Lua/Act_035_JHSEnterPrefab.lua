-- 创建时间:2020-10-30
-- Panel:Act_035_JHSEnterPrefab
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
 --]]

local basefunc = require "Game/Common/basefunc"

Act_035_JHSEnterPrefab = basefunc.class()
local C = Act_035_JHSEnterPrefab
C.name = "Act_035_JHSEnterPrefab"
local M = Act_035_JHSManager

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
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.enter_btn.onClick:AddListener(
            	function()
                ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
                PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
                self:MyRefresh()
				if GameGlobalOnOff.ActByWebView then
					GameManager.OpenActByWebView(M.key)
				else
					Act_035_JHSPanel.Create()
				end
            end)
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.Red) then
		return
	end
	local s = M.GetHintState({gotoui= M.key})
	self.Red.gameObject:SetActive(false)
	if s == ACTIVITY_HINT_STATUS_ENUM.AT_Red then 
		self.Red.gameObject:SetActive(true)
	end 
end
