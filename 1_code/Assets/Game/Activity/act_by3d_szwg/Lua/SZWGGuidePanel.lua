-- 创建时间:2020-05-14

local basefunc = require "Game/Common/basefunc"

SZWGGuidePanel = basefunc.class()
local C = SZWGGuidePanel
C.name = "SZWGGuidePanel"
local M = LHDModel

-- 引导步骤
local GuideStepConfig = {
	[1] = {
		id = 1,
		type="GuideStyle1",
		isHideBG=false, 
		isHideSZ = true,
		desc="对手已经有一对Q，不可能是同花顺，\n我们的牌型肯定大过他",
		descPos={x=0, y=-144, z=0},
		headPos={x=0, y=0},
	},
	[2] = {
		id = 2,
		type="GuideStyle1",
		isHideBG=false, 
		isHideSZ = true,
		desc="对手已经有一对Q，不可能是同花顺，\n我们的牌型肯定大过他",
		descPos={x=0, y=-144, z=0},
		headPos={x=0, y=0},
	},
	[3] = {
		id = 3,
		type="GuideStyle1",
		isHideBG=false, 
		isHideSZ = true,
		desc="对手已经有一对Q，不可能是同花顺，\n我们的牌型肯定大过他",
		descPos={x=0, y=-144, z=0},
		headPos={x=0, y=0},
	},
}

function C.Create(panelSelf)
	return C.New(panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["szwg_guide_check"] = basefunc.handler(self, self.CheckGuide)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.OnEnterBackGround)
end
function C:OnEnterBackGround()
	self:StopRunTime()
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.com_guide then
		self.com_guide:MyExit()
		self.com_guide = nil
	end
	self:RemoveListener()
end

function C:ctor(panelSelf)	
	self:MakeLister()
	self:AddMsgListener()

	-- 游戏面板
	self.panelSelf = panelSelf
	self:InitUI()
end

function C:InitUI()
	self.com_guide = ComGuideToolPanel.Create()
end
function C:StopRunTime()
	if self.guide_t then
		self.guide_t:Stop()
	end
	self.guide_t = nil
end

function C:CheckGuide()
	if self.is_bengin_run_guide then
		print("<color=red>引导开始运行中，一帧的延迟启动</color>")
		print(debug.traceback())
		return
	end
	coroutine.start(function ()
		Yield(0)
		self.is_bengin_run_guide = false
	end)
	self:StopRunTime()

	self.is_bengin_run_guide = true
	if not ActBy3dSzwgManager.data.xsyd or ActBy3dSzwgManager.data.xsyd == 0 then
		return
	end

	
end

