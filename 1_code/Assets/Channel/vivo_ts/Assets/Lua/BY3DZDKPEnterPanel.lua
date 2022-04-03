-- 创建时间:2020-08-03
-- Panel:BY3DZDKPEnterPanel
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

BY3DZDKPEnterPanel = basefunc.class()
local C = BY3DZDKPEnterPanel
C.name = "BY3DZDKPEnterPanel"
local M = BY3DZDKPManager

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
	self.auto_yes_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnAutoClick(true)
	end)
	self.auto_no_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnAutoClick(false)
	end)

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshAuto()
end

function C:RefreshAuto()
	local userdata = FishingModel.GetPlayerData()
    if userdata.is_auto then
    	self.auto_yes_btn.gameObject:SetActive(false)
    	self.auto_no_btn.gameObject:SetActive(true)
    else
    	self.auto_yes_btn.gameObject:SetActive(true)
    	self.auto_no_btn.gameObject:SetActive(false)
    end
end

function C:OnAutoClick(is_auto)
	self:SetChangeAuto(is_auto)
end

function C:SetChangeAuto(is_auto)
    local userdata = FishingModel.GetPlayerData()
    if is_auto then
        userdata.is_auto = true
        userdata.auto_index = 1
    else
        userdata.is_auto = false
        userdata.auto_index = 1
    end
    self:RefreshAuto()
    Event.Brocast("set_gun_auto_state", { seat_num=FishingModel.GetPlayerSeat() })
end
