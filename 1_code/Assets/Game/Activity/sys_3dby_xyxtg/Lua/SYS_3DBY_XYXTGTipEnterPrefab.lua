-- 创建时间:2021-02-02
-- Panel:SYS_3DBY_XYXTGTipEnterPrefab
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

SYS_3DBY_XYXTGTipEnterPrefab = basefunc.class()
local C = SYS_3DBY_XYXTGTipEnterPrefab
C.name = "SYS_3DBY_XYXTGTipEnterPrefab"
local M = SYS_3DBY_XYXTGManager

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
    self.lister["xyxtg_all_data_had_got_msg"] = basefunc.handler(self,self.on_xyxtg_all_data_had_got_msg)
    self.lister["xyxtg_award_had_got_msg"] = basefunc.handler(self,self.on_xyxtg_award_had_got_msg)
    self.lister["xyxtg_bet_had_cancel_msg"] = basefunc.handler(self,self.on_xyxtg_bet_had_cancel_msg)
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
	ExtPanel.ExtMsg(self)
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
	M.QueryTGData()
end

function C:MyRefresh()
	self.tg_data = M.GetTGData()
	if (self.tg_data.remain_round > 0) or ((self.tg_data.remain_round == 0) and (tonumber(self.tg_data.award_money) > 0)) then
		self.gameObject:SetActive(true)
	else
		self.gameObject:SetActive(false)
	end
	self.statu_txt.text = (self.tg_data.remain_round > 0) and "托管中" or "托管结束"
	self.data_txt.text = (self.tg_data.remain_round > 0) and "赢金"..self.tg_data.award_money or "请取回赢金"
end

function C:OnEnterClick()
	if self.tg_data.remain_round == 0 and tonumber(self.tg_data.award_money) > 0 then
		M.GetAward()
	end
	SYS_3DBY_XYXTGPanel.Create()
end

function C:on_xyxtg_all_data_had_got_msg()
	self:MyRefresh()
end

function C:on_xyxtg_award_had_got_msg()
	self:MyRefresh()
end

function C:on_xyxtg_bet_had_cancel_msg()
	self:MyRefresh()
end