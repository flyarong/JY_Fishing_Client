-- 创建时间:2020-07-31
-- Panel:SYSChangeHeadItemBase
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

SYSChangeHeadItemBase = basefunc.class()
local C = SYSChangeHeadItemBase
C.name = "SYSChangeHeadItemBase"
local M = SYSChangeHeadAndNameManager
function C.Create(parent,parent_Panel,config)
	return C.New(parent,parent_Panel,config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["SYSChangeHeadItemBase_Choose_msg"] = basefunc.handler(self,self.on_SYSChangeHeadItemBase_Choose_msg)
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

function C:ctor(parent,parent_Panel,config)
	self.parent_Panel = parent_Panel
	self.config = config
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
	self.choose_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:on_ChooseClick()
	end)
	self.lock_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:on_LockClick()
	end)

	URLImageManager.WWWImage(self.config.url,self.head_img)
	if self.config.vip_permission ~= 0 then
		self.vip_txt.gameObject:SetActive(true)
		self.vip_txt.text = "VIP"..self.config.vip_permission
	else	
		self.vip_txt.gameObject:SetActive(false)
	end

	if self.config.level_permission then
		self.level_txt.text = self.config.level_permission_desc
		local a,b = GameButtonManager.RunFun({gotoui="sys_by_level"}, "GetLevel")
	    if a and b >= self.config.level_permission then
			self.level_txt.gameObject:SetActive(false)
			self.lock_btn.gameObject:SetActive(false)
			self.black.gameObject:SetActive(false)
		else	
			self.level_txt.gameObject:SetActive(true)
			self.lock_btn.gameObject:SetActive(true)
			self.black.gameObject:SetActive(true)
		end
	else
		self.level_txt.gameObject:SetActive(false)
		self.lock_btn.gameObject:SetActive(false)
		self.black.gameObject:SetActive(true)
	end
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_ChooseClick()
	Event.Brocast("SYSChangeHeadItemBase_Choose_msg",self.config.id)
	self.parent_Panel:SetImgType(self.config.id)
end

function C:on_SYSChangeHeadItemBase_Choose_msg(id)
	if id == self.config.id then
		self.light.gameObject:SetActive(true)
	else
		self.light.gameObject:SetActive(false)
	end
end

function C:on_LockClick()
	LittleTips.Create(self.config.level_permission_tips)
end