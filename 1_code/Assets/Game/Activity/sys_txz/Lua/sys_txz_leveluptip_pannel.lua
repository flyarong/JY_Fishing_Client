-- 创建时间:2021-05-08
-- Panel:sys_txz_leveluptip_pannel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

sys_txz_leveluptip_pannel = basefunc.class()
local C = sys_txz_leveluptip_pannel
C.name = "sys_txz_leveluptip_pannel"

function C.Create(level)
	return C.New(level)
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

function C:ctor(level)
	ExtPanel.ExtMsg(self)
    local parent
    if IsEquals(GameObject.Find("Canvas/LayerLv50")) then
        parent = GameObject.Find("Canvas/LayerLv50").transform
    else
        self:MyExit()
    end
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.level=level
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.tip1_txt.text = "通行证等级已提升到" .. self.level .. "级，有奖励待领取"
	self.cut_downTime=Timer.New(function ()
		if self.cut_downTime then
			self.cut_downTime:Stop()
		end
		self:MyClose()
	end,3,-1)
	self.cut_downTime:Start()
	self:MyRefresh()
end

function C:MyRefresh()
end
