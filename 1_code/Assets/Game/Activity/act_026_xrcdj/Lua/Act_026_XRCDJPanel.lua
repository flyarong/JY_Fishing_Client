-- 创建时间:2020-08-13
-- Panel:Act_026_XRCDJPanel
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

Act_026_XRCDJPanel = basefunc.class()
local C = Act_026_XRCDJPanel
C.name = "Act_026_XRCDJPanel"
local M = Act_026_XRCDJManager

function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["EnterForeGround"] = basefunc.handler(self, self.OnEnterForeGround)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.OnEnterBackGround)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.backcall then 
		self.backcall()
	end
	self:CloseTagCell()
	self:StopTime()
	self:CloseRightPre()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,backcall)
	self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
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
	self.back_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	self.help_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnHelpClick()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self.tag_list = M.GetTagList()
	self.TagCellList = {}
	for i = 1, #self.tag_list do
		local pre = Act_026_XRCDJ_TagPrefab.Create(self.left_root, i, self.OnSelectClick, self)
		self.TagCellList[#self.TagCellList + 1] = pre
	end
	self.select_index = 1
	self:RefreshXZ()
	self:RefreshTime()
end

function C:CloseTagCell()
	if self.TagCellList then
		for k,v in ipairs(self.TagCellList) do
			v:OnDestroy()
		end
	end
	self.TagCellList = {}
end

function C:RefreshTime()
	self:StopTime()
	self.down_t = M.GetSYTime()
	if self.down_t > 0 then
	    self.timer = Timer.New(function ()
	    	self:UpdateTime(true)
	    end,1,-1,false,true)
	    self.timer:Start()
	    self:UpdateTime()
	else
		self.hint_time_txt.text = "--"
	end
end
function C:UpdateTime(b)
	if b then
		self.down_t = self.down_t - 1
	end
	if self.down_t <= 0 then
		self:StopTime()
	else
		self.hint_time_txt.text = StringHelper.formatTimeDHMS3(self.down_t)
	end
end
function C:StopTime()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
end
function C:OnEnterForeGround()
	self:RefreshTime()
end
function C:OnEnterBackGround()
	self:StopTime()
end

function C:RefreshXZ()
	for k,v in ipairs(self.TagCellList) do
		if k == self.select_index then
			v:SetSelect(true)
		else
			v:SetSelect(false)
		end
	end

	self:CloseRightPre()

	local cfg = self.tag_list[self.select_index]
	if cfg.type == 1 then
		self.right_pre = Act_026_XRCDJ_CJPanel.Create(self.right_root, cfg)
	else
		self.right_pre = Act_026_XRCDJ_DHHFPanel.Create(self.right_root, cfg)
	end
end

function C:CloseRightPre()
	if self.right_pre then
		self.right_pre:OnDestroy()
		self.right_pre = nil
	end
end

function C:OnHelpClick()
	self.introduce_txt.text = "	1.本活动为新人专属福利活动,有效期7天。\
	2.活动期间累计登陆天数解锁转盘,完成任务即可抽奖。\
	3.三个转盘各抽奖1次可额外领取10元话费奖励。\
	4.充值任务仅限游戏商城直充,不包括活动和推荐栏。\
	5.有效时间截止时未领取的奖励,视为放弃。"
	IllustratePanel.Create({ self.introduce_txt }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:OnSelectClick(index)
	if self.select_index == index then
		return
	end
	self.select_index = index
	self:RefreshXZ()
end
