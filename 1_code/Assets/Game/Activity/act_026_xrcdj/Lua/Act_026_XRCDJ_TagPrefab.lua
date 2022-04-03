-- 创建时间:2020-08-13
-- Panel:Act_026_XRCDJ_TagPrefab
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

Act_026_XRCDJ_TagPrefab = basefunc.class()
local C = Act_026_XRCDJ_TagPrefab
C.name = "Act_026_XRCDJ_TagPrefab"

function C.Create(parent_transform, index, call, panelSelf)
	return C.New(parent_transform, index, call, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.RefreshRed)
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

function C:ctor(parent_transform, index, call, panelSelf)
	self.index = index
	self.call = call
	self.panelSelf = panelSelf
	self.config = panelSelf.tag_list[index]

	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.xz_img = self.xz_btn.transform:GetComponent("Image")
	self.xz_outline = self.xz_txt.transform:GetComponent("Outline")
	self:InitUI()
end

function C:InitUI()
	self.xz_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.call then
			self.call(self.panelSelf, self.index)
		end
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self.xz_txt.text = self.config.name
	self:SetSelect(false)
	self:RefreshRed()
end

function C:RefreshRed()
	self.lfl.gameObject:SetActive(Act_026_XRCDJManager.IsCanGetAwardByTag(self.config.id))
end

function C:SetSelect(b)
	if b then
		self.xz_btn.enabled = false
		self.xz_img.sprite = GetTexture("xrcdj_btn_2")
		self.xz_txt.color = Color.New(1, 0.9882353, 0.9137255, 1)
		self.xz_outline.effectColor = Color.New(0.4039216, 0.1372549, 0.1333333, 1)
	else
		self.xz_btn.enabled = true
		self.xz_img.sprite = GetTexture("xrcdj_btn_1")
		self.xz_txt.color = Color.New(0.9333333, 0.9764706, 0.9843137, 1)
		self.xz_outline.effectColor = Color.New(0.1137255, 0.2, 0.5254902, 1)
	end
end
