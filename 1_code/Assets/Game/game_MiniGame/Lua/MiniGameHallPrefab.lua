-- 创建时间:2019-05-30
-- Panel:MiniGameHallPrefab
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

MiniGameHallPrefab = basefunc.class()
local C = MiniGameHallPrefab
local tag2img = {
	new = "xxc_icon_xy",
	hot = "xxc_icon_hb",
}
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
    self.lister["client_system_variant_data_change_msg"] = basefunc.handler(self, self.on_lv_change_msg)
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

function C:ctor(parent_transform, config, call, panelSelf)
	ExtPanel.ExtMsg(self)

	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	local str = config.bigpre_name or config.pre_name
	if not GetPrefab(str) then return end
	local obj = newObject(config.bigpre_name or config.pre_name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(obj.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self.HintLock = tran:Find("HintLock")
	self.HintLock_lv = tran:Find("HintLock_lv")
	self.Button = tran:Find("Button"):GetComponent("Button")
	self.Button.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if self.config.is_lock and self.config.is_lock == 1 then
			LittleTips.Create("即将开放")
		else
			self:OnEnterClick(self.config)
		end
	end)
	self:InitUI()
	if self["tag_mr"] then
		self["tag_mr"].gameObject:SetActive(config.tag_mr == 1)
	end 
	if self.config.tag then
		local b = newObject("MiniGameTagPrefab",self.transform)
		b.transform.localPosition = Vector2.New(-153,153)
		b.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(tag2img[self.config.tag])
		b.transform:Find("Image"):GetComponent("Image"):SetNativeSize()
	end
end

function C:InitUI()
	self.tip_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnEnterClick(self.config)
	end)
	if self.config.is_lock and self.config.is_lock == 1 then
		self.HintLock.gameObject:SetActive(true)
	else
		self.HintLock.gameObject:SetActive(false)
	end
	self:IsShowLWCS(self.config)
	self:CheckLock()
	self:InitLockText()
end

function C:SetPosition(pos)
	self.transform.localPosition = pos
end

function C:SetScale(v)
	self.transform.localScale = v
end

function C:MyRefresh()

end

function C:CheckLock()
	local v = self.config
	if not self:CheckPermission(v.codin, true) then
		self.HintLock_lv.gameObject:SetActive(true)		
	else
		self.HintLock_lv.gameObject:SetActive(false)		
	end
end


function C:InitLockText()
	local v = self.config
	if v.conditions_type == 1 and v.conditions_num then
		self.lock_txt.text = "Lv"..v.conditions_num[1].."解锁"
	elseif v.conditions_type == 2 then
		self.lock_txt.text = "VIP"..v.conditions_num[2].."解锁"
	elseif v.conditions_type == 3 then
		self.lock_txt.text = "Lv"..v.conditions_num[1].."且VIP"..v.conditions_num[2].."解锁" 
	elseif v.conditions_type == 4 then
		self.lock_txt.text = "Lv"..v.conditions_num[1].."或VIP"..v.conditions_num[2].."解锁" 
	end
end


function C:on_lv_change_msg()
	
	self:CheckLock()
	self:InitLockText()
end

function C:CheckPermission(key,is_on_hint)
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = key, is_on_hint = is_on_hint}, "CheckCondition")
    if a and not b then
        return
    end
    return true
end

function C:OnEnterClick(config)
	if not self:CheckPermission(config.codin) then
		return
	end
	GameManager.CommonGotoScence({gotoui=config.key})
end

function C:IsShowLWCS(config)
	if config.key ~="lwzb" then return end
	Event.Brocast("lwzb_is_creater_msg",self.transform)
end