-- 创建时间:2020-11-03
-- Panel:SYSBY3DJCHDEnterPrefab
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

SYSBY3DJCHDEnterPrefab = basefunc.class()
local C = SYSBY3DJCHDEnterPrefab
C.name = "SYSBY3DJCHDEnterPrefab"
local M = SYSBY3DJCHDManager
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
    self.lister["fishing3dgamepanel_left_ndoe_btn_off_msg"] = basefunc.handler(self,self.on_fishing3dgamepanel_left_ndoe_btn_off_msg)
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
    self.lister["ui_button_state_change_msg"] = basefunc.handler(self,self.on_ui_button_state_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	self:KillTween()
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
end

function C:InitUI()
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterClick)
	
	local btn_map = {}
	btn_map["all"] = {self.btn_node1, self.btn_node2, self.btn_node3, self.btn_node4,self.btn_node5,self.btn_node6}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "jchd_config", self.transform)
	self.game_enter_cfg = GameButtonManager.GetGameEnterCfgByType("jchd_config")
	
	self:MyRefresh()
end

function C:MyRefresh()
	self:MyRefreshLFL()
end

function C:MyRefreshLFL()
	local tab = {}
	-- dump(self.game_enter_cfg["all"],"------------>精彩活动：")
	function CheckIsOpen(condi_key)
		local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = condi_key, is_on_hint = true}, "CheckCondition")
		if a and b then
			return true
		end
		return false
	end
	for k,v in pairs(self.game_enter_cfg["all"]) do
		local itemInfo = GameButtonManager.GetEnterConfig(tonumber(v))
		if  itemInfo.condi_key then
			if CheckIsOpen(itemInfo.condi_key) then
				tab[#tab + 1]=itemInfo
			end
		else
			tab[#tab + 1]=itemInfo
		end
		
	end
	-- dump(tab,"------->tab")
	for k,v in pairs(tab) do
		local parm = {}
		SetTempParm(parm, v.parm)
		if GameManager.GetHintState(parm) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
			self.LFL.gameObject:SetActive(true)
			break
		else
			self.LFL.gameObject:SetActive(false)
		end
	end
end

function C:OnEnterClick()
	if self.is_on then
		self.is_on = false
		self:off_Tween()
	else
		self.is_on = true
		self:on_Tween()
	end
end

function C:on_Tween()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.btn_node_bg.transform:DOLocalMoveX(-500,0.25))
end

function C:off_Tween()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.btn_node_bg.transform:DOLocalMoveX(-1800,0.25))
end

function C:KillTween()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
end

function C:on_fishing3dgamepanel_left_ndoe_btn_off_msg()
	if self.is_on then
		self.is_on = false
		self:off_Tween()
	end
end

function C:on_global_hint_state_change_msg()
	self:MyRefresh()
end

function C:on_ui_button_state_change_msg()
	self:MyRefresh()
end
