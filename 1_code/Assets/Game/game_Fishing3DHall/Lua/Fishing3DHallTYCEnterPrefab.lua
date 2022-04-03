-- 创建时间:2020-07-08
-- Panel:Fishing3DHallTYCEnterPrefab
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

Fishing3DHallTYCEnterPrefab = basefunc.class()
local C = Fishing3DHallTYCEnterPrefab
C.name = "Fishing3DHallTYCEnterPrefab"

function C.Create(parent, parm, panelSelf)
	return C.New(parent, parm, panelSelf)
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

function C:ctor(parent, parm, panelSelf)
	ExtPanel.ExtMsg(self)
	self.panelSelf = panelSelf
	self.parm = parm
	local obj = newObject(self.parm.prefab, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = self.parm.pos

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.enter_btn.onClick:AddListener(function ()
		self.panelSelf:OnItemBtnClick(self.parm.game_id)
	end)
	self.hall_cfg = GameFishing3DManager.GetGameIDToConfig(self.parm.game_id)
	self.enter_txt.text = self:GetEnterText(self.hall_cfg.enter_min, self.hall_cfg.enter_max)

	self:MyRefresh()
end

function C:GetEnterText(min, max)
	if (not min or min < 0) and (not max or max < 0) then
		return "无限制"
	elseif (not min or min < 0) and max > 0 then
		return "" .. StringHelper.ToCash(max) .. "以下"
	elseif min > 0 and (not max or max < 0) then
		return "" .. StringHelper.ToCash(min) .. "以上"
	else
		return "" .. StringHelper.ToCash(min) .. "-" .. StringHelper.ToCash(max)
	end
end
function C:MyRefresh()
end

function C:RefreshSelect(game_id)
	if game_id == self.parm.game_id then
		self.rect_glow_bg.gameObject:SetActive(true)
		self.enter_txt.gameObject:SetActive(true)
		self.name_img.gameObject:SetActive(true)
	else
		self.rect_glow_bg.gameObject:SetActive(false)
		self.enter_txt.gameObject:SetActive(false)
		self.name_img.gameObject:SetActive(false)
	end
end

function C:GetQX()
	return self.qx
end

function C:SetCondition()

end