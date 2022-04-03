-- 创建时间:2020-07-29
-- Panel:BYTCYXDownPrefab
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

BYTCYXDownPrefab = basefunc.class()
local C = BYTCYXDownPrefab
C.name = "BYTCYXDownPrefab"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["by3d_tcyx_close_down_time_msg"] = basefunc.handler(self,self.MyExit)
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

function C:ctor()
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
	self.update_time = Timer.New(function ()
        self:UpdateCall()
    end, 1, -1, nil, true)
    self.update_time:Start()
    self.down_t = 60
	self:MyRefresh()
end

function C:MyRefresh()
	self.down_txt.text = "由于您五分钟未发子弹，系统将在<color=#ff0000>" .. self.down_t .. "</color>秒后把您踢出房间"
end

function C:StopTime()
    if self.update_time then
        self.update_time:Stop()
        self.update_time = nil
    end
end
function C:UpdateCall()
	self.down_t = self.down_t - 1
	self:MyRefresh()
	if self.down_t <= 0 then
		self:MyExit()
		FishingLogic.quit_game()
	end
end