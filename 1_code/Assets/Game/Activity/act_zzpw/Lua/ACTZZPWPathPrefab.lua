-- 创建时间:2021-05-17
-- Panel:ACTZZPWPathPrefab
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

ACTZZPWPathPrefab = basefunc.class()
local C = ACTZZPWPathPrefab
C.name = "ACTZZPWPathPrefab"
local M = ACTZZPWManager

function C.Create(parent, i, data)
	return C.New(parent, i, data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
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

function C:ctor(parent, i, data)
	self.index = i
	self.data = data
	self.parent = parent
	self.style_type = self.data.style[1]

	local obj
	if self.style_type == 1 then
		obj = newObject("pre_zzpw_begin", parent)
	elseif self.style_type == 2 then
		obj = newObject("pre_zzpw_floor", parent)
	elseif self.style_type == 3 then
		obj = newObject("pre_zzpw_jc", parent)
	else
		obj = newObject("pre_zzpw_floor", parent)
	end
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	if self.style_type == 1 then
		
	elseif self.style_type == 2 then
		self.icon_img.sprite = GetTexture(self.data.style[2])
		self.award_txt.text = "x" .. StringHelper.ToCash(self.data.style[3])
	elseif self.style_type == 3 then
		self.jc_txt.text = StringHelper.ToCash(self.data.style[3])
		self.jc_tip_txt.text = StringHelper.ToCash(self.data.style[3])
		self.isTipShow = false
		self.jc_btn.onClick:AddListener(function()
			self.jc_tip.gameObject:SetActive(not self.isTipShow)
			self.isTipShow = not self.isTipShow	
		end)
	else
		self.award_node.gameObject:SetActive(false)
	end
end

function C:SetSelect(b)
	if self.style_type == 1 then
		
	elseif self.style_type == 2 then
		self.DBObj.gameObject:SetActive(not b)
		self.XZObj.gameObject:SetActive(b)
		self.award_node.gameObject:SetActive(not b)
	elseif self.style_type == 3 then
		self.award_node.gameObject:SetActive(not b)
	else

	end
end
function C:GetPos()
	return self.parent.transform.localPosition
end
