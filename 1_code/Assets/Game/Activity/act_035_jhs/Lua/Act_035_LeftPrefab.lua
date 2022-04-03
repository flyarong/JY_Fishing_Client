-- 创建时间:2020-10-30
-- Panel:Act_035_LeftPrefab
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

Act_035_LeftPrefab = basefunc.class()
local C = Act_035_LeftPrefab
C.name = "Act_035_LeftPrefab"
local M = Act_035_JHSManager

function C.Create(parent, parentPanel, index, infor)
	return C.New(parent, parentPanel, index, infor)
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

function C:ctor(parent, parentPanel, index, infor)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parentPanel = parentPanel
	self.index = index
	self.infor = infor

	LuaHelper.GeneratingVar(self.transform, self)

	self.price_btn.onClick:AddListener(
            	function()
                ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:GetCurIndex(self.index)
				self.parentPanel:CreateCenterPrefab(self.index)
				self.parentPanel:CreateButtomPrefab(self.index)
            end)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.price_txt.text = self.infor.price.."元"
	self:GetCurIndex()
end


function C:GetCurIndex(index)
	local _index = index or M.GetCurHaveBuyFirstId()
	self.parentPanel:ShowButtomInforByIndex(_index)
end


function C:RefreshSelet(index)
	self.xz_btn.gameObject:SetActive(index == self.index)
end