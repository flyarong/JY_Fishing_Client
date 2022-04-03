-- 创建时间:2019-09-20
-- Panel:XYCJEnterPrefab
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

XYCJEnterPrefab = basefunc.class()
local C = XYCJEnterPrefab
C.name = "XYCJEnterPrefab"
local M = XYCJActivityManager
function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.MyRedState)

end

function C:MyRedState(parm)
	if parm.gotoui==M.key then
		-- body
		self:MyRefresh()
	end
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

function C:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("xycj_btn", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)

	self:MyRefresh()
end
function C:MyRefresh()
	local redState=M.GetHintState()
	-- dump(redState,"幸运转盘入口红点状态：  ")
	if redState== ACTIVITY_HINT_STATUS_ENUM.AT_Red then
		-- body
		self:SetRedState(true)
	elseif redState== ACTIVITY_HINT_STATUS_ENUM.AT_Nor then
		self:SetRedState(false)
	end
end

function C:SetRedState(_isshow)
	-- dump(_isshow,"设置幸运转盘入口红点状态：  ")
	self.xycj_red.gameObject:SetActive(_isshow)
end
function C:OnEnterClick()
	PlayerPrefs.SetString("HallXYCJHintTime" .. MainModel.UserInfo.user_id, os.time())
	self:SetRedState(false)
	GameNewXYCJPanel.Create()
end

function C:OnDestroy()
	self:MyExit()
end
