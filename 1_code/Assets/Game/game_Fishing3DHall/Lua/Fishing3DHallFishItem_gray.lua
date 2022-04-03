-- 创建时间:2020-05-12
-- Panel:Fishing3DHallFishItem_gray
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

Fishing3DHallFishItem_gray = basefunc.class()
local C = Fishing3DHallFishItem_gray
C.name = "Fishing3DHallFishItem_gray"

function C.Create(parent, data, panelSelf)
	return C.New(parent, data, panelSelf)
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

function C:ctor(parent, data, panelSelf)
	self.data = data
	dump(self.data, "12321312313123")
	self.panelSelf = panelSelf
	local obj = newObject("Fishing3DHallFishItem_gray", parent)

	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.transform.localPosition = Vector3.zero
	self.bg_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self.panelSelf:OnGDClick(self.data.game_id)
    end)
	self:MyRefresh()
end

function C:MyRefresh()
	for k,v in ipairs(self.data.icon_img) do
		self["icon"..k.."_img"].sprite = GetTexture(v)
	end
end


