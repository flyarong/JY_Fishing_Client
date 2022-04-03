-- 创建时间:2020-12-14
-- Panel:VIPYJTZHelpPanel
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

VIPYJTZHelpPanel = basefunc.class()
local C = VIPYJTZHelpPanel
C.name = "VIPYJTZHelpPanel"

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
	self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:MyExit()
    end)
    self.zd_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:MyExit()
    end)
	self:MyRefresh()
end

function C:MyRefresh()
	--　--
	local s1 = "<color=#B98109FF><size=30>需要vip等级达到2级后该活动赢金才开始计算。\n</size></color>"
	local s2 = "<color=#B98109FF><size=30>在游戏中累计赢金达到指定任务要求即可领取奖励。3D捕鱼、街机打鱼赢金数按50%计算。\n</size></color>"
    local channel_type = gameMgr:getMarketPlatform()
    if channel_type == "cjj" then
    	s2 = "<color=#B98109FF><size=30>在游戏中累计赢金达到指定任务要求即可领取奖励。</size></color>"
    end
    self.desc1_txt.text = "<color=#ED8813FF><size=36>\n　　参与条件：\n</size></color>"
    self.desc2_txt.text = s1
    self.desc3_txt.text = "<color=#ED8813FF><size=36>　　玩法介绍：\n</size></color>"
    self.desc4_txt.text = s2
end
