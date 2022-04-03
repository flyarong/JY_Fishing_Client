-- 创建时间:2020-08-07
-- Panel:GiftCZLBAwardPrefab
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

GiftCZLBAwardPrefab = basefunc.class()
local C = GiftCZLBAwardPrefab
C.name = "GiftCZLBAwardPrefab"

function C.Create(parent_transform, config, call, panelSelf)
	return C.New(parent_transform, config, call, panelSelf)
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

function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	if self.config.tips then
		PointerEventListener.Get(self.bg_img.gameObject).onDown = function ()
			GameTipsPrefab.ShowDesc(self.config.tips, UnityEngine.Input.mousePosition)
		end
		PointerEventListener.Get(self.bg_img.gameObject).onUp = function ()
			GameTipsPrefab.Hide()
		end
	end

	self:MyRefresh()
end

function C:MyRefresh()
	self.bg_img.sprite = GetTexture(self.config.bg)
	GetTextureExtend(self.icon_img, self.config.icon_img, 1)
	self.award_txt.text = self.config.name

end

function C:SetHigh(b)
	local cc
	if b then
		cc = Color.New(1,1,1,1)
	else
		cc = Color.New(0.62,0.62,0.62,1)
	end
	self.bg_img.color = cc
	self.icon_img.color = cc
	self.award_txt.color = cc
end
