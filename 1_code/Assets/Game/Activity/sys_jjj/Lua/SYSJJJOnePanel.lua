-- 创建时间:2020-08-14
-- Panel:SYSJJJOnePanel
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

SYSJJJOnePanel = basefunc.class()
local C = SYSJJJOnePanel
local M = SysJJJManager
C.name = "SYSJJJOnePanel"

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
	self.ew_get_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEWGetClick()
	end)
	self.ad_get_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)


	for i=1,#M.goto_ui_condikey do
		local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=M.goto_ui_condikey[i], is_on_hint = true}, "CheckCondition")
		if a and b then
			self.goto_ui = M.goto_ui[i]
			self.btn_tip = M.goto_ui_tip[i]
			break
		end
	end


	self:MyRefresh()
end

function C:MyRefresh()
	local ylq = M.GetAllCount() - M.GetCurCount()
	self.award1_txt.text = "金币 x" .. GAME_Di_Bao_JB
	self.award2_txt.text = "金币 x" .. GAME_Di_Bao_JB_HH
	self.ew_get_txt.text = M.HH_btn_desc
	self.tips_txt.text = M.HH_tips
	self.getted_txt.text = "" .. ylq
	self.remain_txt.text = "" .. M.GetAllCount()
	self.btn_tip_txt.text = self.btn_tip
end

function C:OnGetClick()
	local call = function ()
		Network.SendRequest("free_broke_subsidy", nil, "请求数据",function(data)
	        dump(data, "<color=white>free_broke_subsidy</color>")
	        if data.result == 0 then
	        	if not MainModel.UserInfo.freeSubsidyNum then
	        		Network.SendRequest("query_free_broke_subsidy_num",nil, "请求数据",function(data2)
	        			if data2 and data2.result == 0 then
	        				MainModel.UserInfo.freeSubsidyNum = data2.num
	        				MainModel.UserInfo.freeSubsidyAllNum = data2.all_num
	        				MainModel.UserInfo.freeSubsidyNum = MainModel.UserInfo.freeSubsidyNum - 1
	        				Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
	        			end
	        		end)
				else
					MainModel.UserInfo.freeSubsidyNum = MainModel.UserInfo.freeSubsidyNum - 1
					Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
				end
	        else
	            HintPanel.ErrorMsg(data.result)
	        end
	    end)
	end
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="ljyjcflq_vip_limit", is_on_hint = true}, "CheckCondition")
	if a and b then
		if SYSQXManager.IsNeedWatchAD() then
			AdvertisingManager.RandPlay("jjj", nil, call)
		else
			call()
		end
	else
		call()
	end
    self:MyExit()
end

function C:OnEWGetClick()
	GameManager.GotoUI({gotoui="sys_act_czzk", goto_scene_parm="panel2", ID=self.goto_ui})
	self:MyExit()
end