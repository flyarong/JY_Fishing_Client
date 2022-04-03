-- 创建时间:2021-05-17
-- Panel:ACTCJDBPathPrefab
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

ACTCJDBPathPrefab = basefunc.class()
local C = ACTCJDBPathPrefab
C.name = "ACTCJDBPathPrefab"

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
		obj = newObject("pre_begin", parent)
	elseif self.style_type == 2 then
		obj = newObject("pre_floor", parent)
	else
		obj = newObject("pre_key", parent)
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
		self.award_txt.text = self.data.style[3]
	else
		self.icon_img.sprite = GetTexture(self.data.style[2])
	end
end

function C:SetData(data)
	self.data = data
	self:MyRefresh()
end
function C:SetSelect(b)
	if self.style_type == 1 then
		
	elseif self.style_type == 2 then
		self.DBObj.gameObject:SetActive(not b)
		self.XZObj.gameObject:SetActive(b)
		self.award_node.gameObject:SetActive(not b)
	else

	end
end
function C:GetPos()
	return self.parent.transform.localPosition
end
