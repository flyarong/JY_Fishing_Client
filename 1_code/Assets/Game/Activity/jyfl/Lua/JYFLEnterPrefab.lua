-- 创建时间:2019-09-25
-- Panel:JYFLEnterPrefab
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

JYFLEnterPrefab = basefunc.class()
local C = JYFLEnterPrefab
C.name = "JYFLEnterPrefab"

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
	self.lister["UpdateHallJYFLRedHint"] = basefunc.handler(self, self.UpdateRedHit)
	self.lister["player_new_change_to_old"] = basefunc.handler(self, self.player_new_change_to_old)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	if self.main_timer then 
		self.main_timer:Stop()
		self.main_timer=nil
	end 
	destroy(self.gameObject)
end

function C:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("jyfl_btn", parent)
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
	self:UpdateRedHit()
	-- self:UpdateImg()
end

function C:OnEnterClick()
	JYFLPanel.Create()
	--TeacherAndPupilPanel.Create()
	--TpEncouragePanel.Create()
end

function C:OnDestroy()
	self:MyExit()
end

function C:UpdateRedHit()
	local state = JYFLManager.GetHintState()
	if state == ACTIVITY_HINT_STATUS_ENUM.AT_Nor or state == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
		if IsEquals(self.LFL) then
			self.LFL.gameObject:SetActive(false)
		end
	else
		if IsEquals(self.LFL) then
			self.LFL.gameObject:SetActive(true)
		end
	end
end

function C:player_new_change_to_old()
	self:MyRefresh()
end

function C:UpdateImg()
	local is_new = MainModel.GetNewPlayer() == PLAYER_TYPE.PT_New
	local str = is_new and "xrfl_btn_xrfl" or "hall_btn_gift48"
	self.icon_img.sprite = GetTexture(str)
end