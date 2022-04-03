-- 创建时间:2020-07-08
-- Panel:Fishing3DHallEnterPrefab
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

Fishing3DHallEnterPrefab = basefunc.class()
local C = Fishing3DHallEnterPrefab
C.name = "Fishing3DHallEnterPrefab"

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
	self.pre = Fishing3DHallFishItem.Create(self.help_cc, self.parm, self.panelSelf)
	self.pre_gray = Fishing3DHallFishItem_gray.Create(self.help_cc, self.parm, self.panelSelf)	

	self.hall_cfg = GameFishing3DManager.GetGameIDToConfig(self.parm.game_id)

	self.enter_txt.text = self:GetEnterText(self.hall_cfg.enter_min, self.hall_cfg.enter_max)
	self.enter2_txt.text = self:GetEnterText(self.hall_cfg.enter_min, self.hall_cfg.enter_max)
	self.enter_btn.onClick:AddListener(function ()
		self.panelSelf:OnItemBtnClick(self.parm.game_id)
	end)
	self.enter_rect.gameObject.name = "by3d_hall_enter" .. self.hall_cfg.game_id
	if IsEquals(self.condition) then
		self.condition_txt = self.condition:GetComponent("Text")
	end
	if self.parm.game_id == 3 then
		Event.Brocast("game_fishing3dhall_init",self.transform)
	end

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
	if self.parm.game_id == 3 then
		self.condition_txt.text = ""
	elseif self.parm.game_id == 4 then
		self.condition_txt.text = "Lv20或VIP1解锁"
	elseif self.parm.game_id == 5 then
		self.condition_txt.text = "VIP3解锁"
	else
	end
	self.help_cc.gameObject:SetActive(true)
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing3d_"..self.parm.game_id, is_on_hint=true}, "CheckCondition")
	if a and not b then
		self.qx = false
		self.pre_gray.gameObject:SetActive(true)
		self.yes.gameObject:SetActive(false)
		self.no.gameObject:SetActive(true)
	else
		self.qx = true
		self.pre_gray.gameObject:SetActive(false)
		self.yes.gameObject:SetActive(true)
		self.no.gameObject:SetActive(false)
	end

	if GameFishing3DManager.IsGameLockByID(self.parm.game_id) then
		self.suo.gameObject:SetActive(true)
	else
		self.suo.gameObject:SetActive(false)
	end
	if self.parm.game_id==3 then
		Event.Brocast("game_fishing3dhall_gameid3_refresh",self.qx)
	end
end

function C:RefreshSelect(game_id)
	if game_id == self.parm.game_id then
		self.rect_glow_bg.gameObject:SetActive(true)
	else
		self.rect_glow_bg.gameObject:SetActive(false)
	end
end

function C:GetQX()
	return self.qx
end

function C:SetCondition()
	self.condition.gameObject:SetActive(true)
end