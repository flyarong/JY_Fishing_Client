-- 创建时间:2021-11-04
-- Panel:ACTZZPWUpGradePanel
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

ACTZZPWUpGradePanel = basefunc.class()
local C = ACTZZPWUpGradePanel
C.name = "ACTZZPWUpGradePanel"
local M = ACTZZPWManager

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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	local cur_rank = M.GetCurRank()
	local config = M.GetConfig()
	local tab = {"zzpw_icon_qt","zzpw_icon_by","zzpw_icon_hj","zzpw_icon_bj","zzpw_icon_zs","zzpw_icon_zz"}
	local index1 = math.ceil(cur_rank / 3)
	local index2 = cur_rank % 3
	if index2 == 0 then
		index2 = 3
	end
	self.xx_node.gameObject:SetActive(cur_rank ~= 16)
	self.grade_img.sprite = GetTexture(tab[index1])
	for i=1,3 do
		self["xx" .. i].gameObject:SetActive(false)
	end
	for i=1,index2 do
		self["xx" .. i].gameObject:SetActive(true)
	end
	self.confirm_btn.onClick:AddListener(function()
		self:MyExit()
	end)
	self.desc_txt.text = "当前段位奖励" .. config[cur_rank].rank_award .. "，段位越高奖励越丰厚"
	self:MyRefresh()
end

function C:MyRefresh()
end
