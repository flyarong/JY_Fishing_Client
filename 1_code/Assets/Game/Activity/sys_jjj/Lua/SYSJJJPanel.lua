-- 创建时间:2020-04-22
-- Panel:SYSJJJPanel
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

SYSJJJPanel = basefunc.class()
local C = SYSJJJPanel
local M = SysJJJManager
C.name = "SYSJJJPanel"

C.is_opening = nil
function C.Create(back_call)
	if MainModel.cur_myLocation == "game_Login" then
		return
	end
	if C.is_opening then
		return C.is_opening
	else
		C.is_opening = true
		return C.New(back_call)
	end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
function C:OnExitScene()
	self:MyExit()
end
function C:MyExit()
	C.is_opening = false
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(back_call)
	self.back_call = back_call
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	self.close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.back_call then
			self.back_call()
		end
		self:MyExit()
	end)
	self.get_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	self.ad_get_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)

	self:MyRefresh()
end

function C:MyRefresh()
	if SYSQXManager.IsNeedWatchAD() then
		self.ad_get_btn.gameObject:SetActive(true)
		self.get_btn.gameObject:SetActive(false)
	else
		self.ad_get_btn.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(true)
	end

	local ylq = M.GetAllCount() - M.GetCurCount()
	self.award_txt.text = "金币 x" .. GAME_Di_Bao_JB
	self.getted_txt.text = "" .. ylq
	self.remain_txt.text = "" .. M.GetAllCount()
end

function C:OnGetClick()
	local call = function ()
        Network.SendRequest("broke_subsidy", nil, "请求数据", function (data)
        	dump(data, "<color=white>broke_subsidy</color>")
        	if data.result == 0 then
		        MainModel.UserInfo.shareCount = MainModel.UserInfo.shareCount - 1
				Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
				Event.Brocast("sys_exit_ask_refresh_msg")
        	else
        		HintPanel.ErrorMsg(data.result)
        	end
        end)
	end
	if GLC.IsCloseJJJFX then
		call()
	else
		if SYSQXManager.IsNeedWatchAD() then
			AdvertisingManager.RandPlay("jjj", nil, call)
		else
			call()
		end
	end
    self:MyExit()
end

