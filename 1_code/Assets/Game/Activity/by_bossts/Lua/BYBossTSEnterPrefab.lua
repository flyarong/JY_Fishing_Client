-- 创建时间:2020-07-08
-- Panel:BYBossTSEnterPrefab
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

BYBossTSEnterPrefab = basefunc.class()
local C = BYBossTSEnterPrefab
C.name = "BYBossTSEnterPrefab"

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["by_bossts_down_time_change_msg"] = basefunc.handler(self, self.by_bossts_down_time_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopTime()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parm)
	self.parm = parm
	local obj = newObject(C.name, self.parm.parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.transform.localPosition = Vector3.zero
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.update_time = Timer.New(function ()
		self:RefreshTime()
	end, 1, -1, nil, true)

	self:MyRefresh()
end

function C:MyRefresh()
	self.cfg = BYBossTSManager.GetConfigByGameID(FishingModel.game_id)

	self.icon_img.sprite = GetTexture(self.cfg.icon)
	self.name_img.sprite = GetTexture(self.cfg.name)
	self.icon_img:SetNativeSize()
	self.name_img:SetNativeSize()

	self.down = BYBossTSManager.GetDownTime() - os.time()
	self.update_time:Start()
	self:RefreshTime(true)
end

function C:RefreshTime(b)
	if not b then
		self.down = self.down - 1
	end
	self.down_time_txt.text = StringHelper.formatTimeDHMS3(self.down)

	if self.down <= 0 then
	    Event.Brocast("ui_button_state_change_msg")
	end
end

function C:StopTime()
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
end

function C:by_bossts_down_time_change_msg()
	self.down = BYBossTSManager.GetDownTime() - os.time()
	self:RefreshTime(true)
end

