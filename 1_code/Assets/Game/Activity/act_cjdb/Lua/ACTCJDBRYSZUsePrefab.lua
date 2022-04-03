-- 创建时间:2021-05-18
-- Panel:ACTCJDBRYSZUsePrefab
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

ACTCJDBRYSZUsePrefab = basefunc.class()
local C = ACTCJDBRYSZUsePrefab
C.name = "ACTCJDBRYSZUsePrefab"

function C.Create(cur_type)
	return C.New(cur_type)
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

function C:ctor(cur_type)
	self.cur_type = cur_type
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
	self.is_xz = false
	self.back_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)

	self.qx_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)

	self.qr_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		--确认操作
		self:OnQrClick()
	end)

	for i=1,6 do
		self["ds"..i.."_btn"].onClick:AddListener(function ()
			self:XzClickToShow(i)
			self.is_xz = true
			self:MyRefresh()
		end)
	end
	self:MyRefresh()
end

function C:MyRefresh()
	self.qx_btn.transform.gameObject:SetActive(not self.is_xz)
	self.qr_btn.transform.gameObject:SetActive(self.is_xz)
end

function C:XzClickToShow(index)
	self.xz_index = index
	for i=1,6 do
		self["xzds"..i].transform.gameObject:SetActive((index and index == i) and true or false)
	end
end

function C:OnQrClick()
	if(self.xz_index) then
		HintPanel.Create(8,"您选择的点数是"..self.xz_index..",确认后将向前前进"..self.xz_index.."步，确认后不可更改，是否确认？",function ()
			--确定事件
			Network.SendRequest("super_treasure_use_renyi_dice",{type = self.cur_type, dot=self.xz_index}, "使用")
			self:MyExit()
		end,function()
		end)
	end
end